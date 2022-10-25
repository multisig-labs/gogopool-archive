// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;

import "./Base.sol";
import {Storage} from "./Storage.sol";
import {Oracle} from "./Oracle.sol";
import {Vault} from "./Vault.sol";
import {ProtocolDAO} from "./dao/ProtocolDAO.sol";
import {MinipoolStatus} from "../types/MinipoolStatus.sol";
import {MultisigManager} from "./MultisigManager.sol";
import {TokenggAVAX} from "./tokens/TokenggAVAX.sol";
import {TokenGGP} from "./tokens/TokenGGP.sol";
import {IWithdrawer} from "../interface/IWithdrawer.sol";
import {Staking} from "./Staking.sol";

import {ERC20} from "@rari-capital/solmate/src/mixins/ERC4626.sol";
import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";
import {SafeTransferLib} from "@rari-capital/solmate/src/utils/SafeTransferLib.sol";

/*
	Data Storage Schema
	(nodeIDs are 20 bytes so can use Solidity 'address' as storage type for them)
	NodeIDs can be added, but never removed. If a nodeID submits another validation request,
	it will overwrite the old one (only allowed for specific statuses).

	MinipoolManager.TotalAVAXLiquidStakerAmt = total for all active minipools (Prelaunch/Launched/Staking)

	minipool.count = Starts at 0 and counts up by 1 after a node is added.
	minipool.index<nodeID> = <index> of nodeID
	minipool.item<index>.nodeID = nodeID used as primary key (NOT the ascii "Node-blah" but the actual 20 bytes)
	minipool.item<index>.status = enum
	minipool.item<index>.duration = requested validation duration in seconds
	minipool.item<index>.owner = owner address
	minipool.item<index>.delegationFee = node operator specified fee (must be between 0 and 1_000_000) 2% is 20_000
	minipool.item<index>.avaxNodeOpAmt = avax deposited by node op (1000 avax for now)
	minipool.item<index>.avaxLiquidStakerAmt = avax deposited by users (1000 avax for now)
	minipool.item<index>.multisigAddr = which Rialto multisig is assigned to manage this validation (in future could be multiple)
	// Below are submitted by Rialto oracle
	minipool.item<index>.txID = transaction id of the AddValidatorTx
	minipool.item<index>.startTime = actual time validation was started
	minipool.item<index>.endTime = actual time validation was finished
	minipool.item<index>.avaxTotalRewardAmt = Actual total avax rewards paid by avalanchego to the TSS P-chain addr
	minipool.item<index>.errorCode = bytes32 that encodes an error msg if something went wrong during launch of minipool
	// These are calculated in recordStakingEnd
	minipool.item<index>.avaxNodeOpRewardAmt
	minipool.item<index>.avaxLiquidStakerRewardAmt
	minipool.item<index>.ggpSlashAmt = amt of ggp bond that was slashed if necessary (expected reward amt = avaxLiquidStakerAmt * x%/yr / ggpPriceInAvax)
*/

contract MinipoolManager is Base, IWithdrawer {
	using FixedPointMathLib for uint256;
	using SafeTransferLib for address;
	using SafeTransferLib for ERC20;

	error ErrorSendingAVAX();
	error InsufficientGGPCollateralization();
	error InsufficientAVAXForMinipoolCreation();
	error InvalidAmount();
	error InvalidAVAXAssignmentRequest();
	error InvalidEndTime();
	error InvalidMultisigAddress();
	error InvalidNodeID();
	error InvalidStateTransition();
	error MinipoolNotFound();
	error OnlyOwnerCanCancel();
	error OnlyOwnerCanWithdraw();
	error OnlyOwner();

	event GGPSlashed(address indexed nodeID, uint256 ggp);
	event MinipoolStatusChanged(address indexed nodeID, MinipoolStatus indexed status);

	ERC20 public immutable ggp;
	TokenggAVAX public immutable ggAVAX;

	// Not used for storage, just for returning data from view functions
	struct Minipool {
		int256 index;
		address nodeID;
		uint256 status;
		uint256 duration;
		uint256 startTime;
		uint256 endTime;
		uint256 delegationFee;
		uint256 ggpSlashAmt;
		uint256 avaxNodeOpAmt;
		uint256 avaxLiquidStakerAmt;
		uint256 avaxTotalRewardAmt;
		uint256 avaxNodeOpRewardAmt;
		uint256 avaxLiquidStakerRewardAmt;
		bytes32 errorCode;
		address owner;
		address multisigAddr;
		bytes32 txID;
	}

	//
	// GUARDS
	//
	function onlyOwner(int256 minipoolIndex) private view returns (address) {
		address owner = getAddress(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".owner")));
		if (msg.sender != owner) {
			revert OnlyOwner();
		}
		return owner;
	}

	/// @dev Returns index of a minipool only if nodeID exists and msg.sender is assigned to it. Reverts otherwise.
	function onlyValidMultisig(address nodeID) private view returns (int256) {
		int256 minipoolIndex = requireValidMinipool(nodeID);

		address assignedMultisig = getAddress(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".multisigAddr")));
		if (msg.sender != assignedMultisig) {
			revert InvalidMultisigAddress();
		}
		return minipoolIndex;
	}

	/// @dev Returns index of a minipool or reverts if nodeID is not found
	function requireValidMinipool(address nodeID) private view returns (int256) {
		int256 minipoolIndex = getIndexOf(nodeID);
		if (minipoolIndex == -1) {
			revert MinipoolNotFound();
		}

		return minipoolIndex;
	}

	/// @param minipoolIndex A valid minipool index
	/// @param to The status we are trying to move to
	function requireValidStateTransition(int256 minipoolIndex, MinipoolStatus to) private view {
		bytes32 statusKey = keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status"));
		MinipoolStatus currentStatus = MinipoolStatus(getUint(statusKey));
		bool isValid;

		if (currentStatus == MinipoolStatus.Prelaunch) {
			isValid = (to == MinipoolStatus.Launched || to == MinipoolStatus.Canceled);
		} else if (currentStatus == MinipoolStatus.Launched) {
			isValid = (to == MinipoolStatus.Staking || to == MinipoolStatus.Error);
		} else if (currentStatus == MinipoolStatus.Staking) {
			isValid = (to == MinipoolStatus.Withdrawable || to == MinipoolStatus.Error);
		} else if (currentStatus == MinipoolStatus.Withdrawable || currentStatus == MinipoolStatus.Error) {
			isValid = (to == MinipoolStatus.Finished);
		} else if (currentStatus == MinipoolStatus.Finished || currentStatus == MinipoolStatus.Canceled) {
			// Once a node is finished/canceled, if they re-validate they go back to beginning state
			isValid = (to == MinipoolStatus.Prelaunch);
		} else {
			isValid = false;
		}

		if (!isValid) {
			revert InvalidStateTransition();
		}
	}

	constructor(
		Storage storageAddress,
		ERC20 ggp_,
		TokenggAVAX ggAVAX_
	) Base(storageAddress) {
		version = 1;
		ggp = ggp_;
		ggAVAX = ggAVAX_;
	}

	//
	// OWNER FUNCTIONS
	//
	// Accept deposit from node operator
	function createMinipool(
		address nodeID,
		uint256 duration,
		uint256 delegationFee,
		uint256 avaxAssignmentRequest
	) external payable whenNotPaused {
		if (nodeID == address(0)) {
			revert InvalidNodeID();
		}

		// TODO validate duration (force 14 days?) and delegation fee (force 2%?)

		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		if (
			// Current rule is funds must be 1:1 nodeOp:LiqStaker
			msg.value != avaxAssignmentRequest ||
			avaxAssignmentRequest > dao.getMinipoolMaxAVAXAssignment() ||
			avaxAssignmentRequest < dao.getMinipoolMinAVAXAssignment()
		) {
			revert InvalidAVAXAssignmentRequest();
		}

		if (msg.value + avaxAssignmentRequest < dao.getMinipoolMinStakingAmount()) {
			revert InsufficientAVAXForMinipoolCreation();
		}

		// All AVAX will be stored in the Vault contract
		Vault vault = Vault(getContractAddress("Vault"));
		vault.depositAVAX{value: msg.value}();

		Staking staking = Staking(getContractAddress("Staking"));
		staking.increaseAVAXStake(msg.sender, msg.value);
		staking.increaseAVAXAssigned(msg.sender, avaxAssignmentRequest);
		staking.increaseMinipoolCount(msg.sender);
		uint256 ratio = staking.getCollateralizationRatio(msg.sender);
		if (ratio < dao.getMinCollateralizationRatio()) {
			revert InsufficientGGPCollateralization();
		}

		// If nodeID exists, only allow overwriting if node is finished or canceled
		// (completed its validation period and all rewards paid and processing is complete)
		// getIndexOf returns -1 if node does not exist, so have to use signed type int256 here
		int256 minipoolIndex = getIndexOf(nodeID);
		if (minipoolIndex != -1) {
			requireValidStateTransition(minipoolIndex, MinipoolStatus.Prelaunch);
			resetMinipoolData(minipoolIndex);
		} else {
			minipoolIndex = int256(getUint(keccak256("minipool.count")));
			// NOTE the minipoolIndex is actually 1 more than where it is actually stored. The 1 is subtracted in getIndexOf().
			// Copied from RP, probably so they can use "-1" to signify that something doesnt exist
			setUint(keccak256(abi.encodePacked("minipool.index", nodeID)), uint256(minipoolIndex + 1));
			setAddress(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".nodeID")), nodeID);
			addUint(keccak256("minipool.count"), 1);
		}

		// Get a Rialto multisig to assign for this minipool
		MultisigManager multisigManager = MultisigManager(getContractAddress("MultisigManager"));
		address multisig = multisigManager.requireNextActiveMultisig();

		// Save the attrs individually in the k/v store
		setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Prelaunch));
		setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".duration")), duration);
		setAddress(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".multisigAddr")), multisig);
		setAddress(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".owner")), msg.sender);
		setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".avaxNodeOpAmt")), msg.value);
		setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".avaxLiquidStakerAmt")), avaxAssignmentRequest);
		setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".delegationFee")), delegationFee);

		emit MinipoolStatusChanged(nodeID, MinipoolStatus.Prelaunch);
	}

	// Owner of a node can call this to cancel the (prelaunch) minipool
	// TODO Should DAO also be able to cancel? Or guardian? or Rialto?
	function cancelMinipool(address nodeID) external {
		int256 index = requireValidMinipool(nodeID);
		onlyOwner(index);
		_cancelMinipoolAndReturnFunds(nodeID, index);
	}

	// Node op calls this to withdraw all AVAX funds they are due (orig, plus any rewards)
	// we want this to be pausable if there was some error that changes how much an owner can withdraw
	function withdrawMinipoolFunds(address nodeID) external {
		int256 minipoolIndex = requireValidMinipool(nodeID);
		address owner = onlyOwner(minipoolIndex);
		requireValidStateTransition(minipoolIndex, MinipoolStatus.Finished);
		setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Finished));

		Vault vault = Vault(getContractAddress("Vault"));

		uint256 avaxNodeOpAmt = getUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".avaxNodeOpAmt")));
		uint256 avaxNodeOpRewardAmt = getUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".avaxNodeOpRewardAmt")));
		uint256 totalAvax = avaxNodeOpAmt + avaxNodeOpRewardAmt;

		Staking staking = Staking(getContractAddress("Staking"));
		staking.decreaseAVAXStake(owner, avaxNodeOpAmt);

		vault.withdrawAVAX(totalAvax);
		// TODO should we be using safeTransferETH here?
		(bool sent, ) = payable(owner).call{value: totalAvax}("");
		if (!sent) {
			revert ErrorSendingAVAX();
		}
	}

	//
	// RIALTO FUNCTIONS
	//
	// Rialto calls this to see if a claim would succeed. Does not change state.
	function canClaimAndInitiateStaking(address nodeID) external view returns (bool) {
		int256 minipoolIndex = onlyValidMultisig(nodeID);
		requireValidStateTransition(minipoolIndex, MinipoolStatus.Launched);

		// Make sure we have enough liq staker funds
		uint256 avaxLiquidStakerAmt = getUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".avaxLiquidStakerAmt")));
		if (avaxLiquidStakerAmt > ggAVAX.amountAvailableForStaking()) {
			return false;
		}
		return true;
	}

	// If correct multisig calls this, xfer nodeOp + LiqStaker funds from vault to msg.sender
	function claimAndInitiateStaking(address nodeID) external {
		int256 minipoolIndex = onlyValidMultisig(nodeID);
		requireValidStateTransition(minipoolIndex, MinipoolStatus.Launched);
		Vault vault = Vault(getContractAddress("Vault"));

		uint256 avaxNodeOpAmt = getUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".avaxNodeOpAmt")));
		uint256 avaxLiquidStakerAmt = getUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".avaxLiquidStakerAmt")));

		// Transfer the user funds to this contract
		ggAVAX.withdrawForStaking(avaxLiquidStakerAmt);
		increaseTotalAVAXLiquidStakerAmt(avaxLiquidStakerAmt);
		vault.withdrawAVAX(avaxNodeOpAmt);

		// We know we have correct amounts since createMinipool enforces that
		uint256 totalAvaxAmt = avaxNodeOpAmt + avaxLiquidStakerAmt;

		setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Launched));
		emit MinipoolStatusChanged(nodeID, MinipoolStatus.Launched);
		msg.sender.safeTransferETH(totalAvaxAmt);
	}

	// Rialto calls this after a successful minipool launch
	function recordStakingStart(
		address nodeID,
		bytes32 txID,
		uint256 startTime
	) external {
		int256 minipoolIndex = onlyValidMultisig(nodeID);

		requireValidStateTransition(minipoolIndex, MinipoolStatus.Staking);
		setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Staking));
		setBytes32(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".txID")), txID);
		setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".startTime")), startTime);
		emit MinipoolStatusChanged(nodeID, MinipoolStatus.Staking);
	}

	// Rialto calls this when validation period ends
	// Rialto will also xfer back all avax + avax rewards to vault
	// Also handles the slashing of node ops GGP bond
	function recordStakingEnd(
		address nodeID,
		uint256 endTime,
		uint256 avaxTotalRewardAmt
	) external payable {
		int256 minipoolIndex = onlyValidMultisig(nodeID);
		requireValidStateTransition(minipoolIndex, MinipoolStatus.Withdrawable);

		uint256 startTime = getUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".startTime")));
		if (endTime <= startTime || endTime > block.timestamp) {
			revert InvalidEndTime();
		}

		uint256 avaxNodeOpAmt = getUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".avaxNodeOpAmt")));
		uint256 avaxLiquidStakerAmt = getUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".avaxLiquidStakerAmt")));
		uint256 totalAvaxAmt = avaxNodeOpAmt + avaxLiquidStakerAmt;
		if (msg.value != totalAvaxAmt + avaxTotalRewardAmt) {
			revert InvalidAmount();
		}

		Vault vault = Vault(getContractAddress("Vault"));
		Staking staking = Staking(getContractAddress("Staking"));
		address owner = getAddress(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".owner")));

		setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Withdrawable));
		setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".endTime")), endTime);
		setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".avaxTotalRewardAmt")), avaxTotalRewardAmt);

		// Calculate rewards splits (these will all be zero if no rewards were recvd)
		uint256 avaxHalfRewards = avaxTotalRewardAmt / 2;

		// we are giving node operators an additional 15% commission fee
		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		uint256 avaxLiquidStakerRewardAmt = avaxHalfRewards - avaxHalfRewards.mulWadDown(dao.getMinipoolNodeCommissionFeePct());
		uint256 avaxNodeOpRewardAmt = avaxTotalRewardAmt - avaxLiquidStakerRewardAmt;

		setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".avaxNodeOpRewardAmt")), avaxNodeOpRewardAmt);
		setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".avaxLiquidStakerRewardAmt")), avaxLiquidStakerRewardAmt);

		// No rewards means validation period failed, must slash node op.
		if (avaxTotalRewardAmt == 0) {
			slash(minipoolIndex);
		}

		// Send the nodeOps AVAX + rewards to vault so they can claim later
		vault.depositAVAX{value: avaxNodeOpAmt + avaxNodeOpRewardAmt}();
		// Return Liq stakers funds + rewards
		ggAVAX.depositFromStaking{value: avaxLiquidStakerAmt + avaxLiquidStakerRewardAmt}(avaxLiquidStakerAmt, avaxLiquidStakerRewardAmt);
		staking.decreaseAVAXAssigned(owner, avaxLiquidStakerAmt);
		decreaseTotalAVAXLiquidStakerAmt(avaxLiquidStakerAmt);
		staking.decreaseMinipoolCount(owner);

		emit MinipoolStatusChanged(nodeID, MinipoolStatus.Withdrawable);
	}

	// Rialto was unable to start the validation period, so cancel and refund all monies
	function recordStakingError(address nodeID, bytes32 errorCode) external payable {
		int256 minipoolIndex = onlyValidMultisig(nodeID);
		requireValidStateTransition(minipoolIndex, MinipoolStatus.Error);

		address owner = getAddress(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".owner")));
		uint256 avaxNodeOpAmt = getUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".avaxNodeOpAmt")));
		uint256 avaxLiquidStakerAmt = getUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".avaxLiquidStakerAmt")));

		if (msg.value != (avaxNodeOpAmt + avaxLiquidStakerAmt)) {
			revert InvalidAmount();
		}

		Vault vault = Vault(getContractAddress("Vault"));
		Staking staking = Staking(getContractAddress("Staking"));

		setBytes32(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".errorCode")), errorCode);
		setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Error));
		setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".avaxTotalRewardAmt")), 0);
		setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".avaxNodeOpRewardAmt")), 0);
		setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".avaxLiquidStakerRewardAmt")), 0);

		// Send the nodeOps AVAX to vault so they can claim later
		vault.depositAVAX{value: avaxNodeOpAmt}();
		// Return Liq stakers funds
		ggAVAX.depositFromStaking{value: avaxLiquidStakerAmt}(avaxLiquidStakerAmt, 0);
		staking.decreaseAVAXAssigned(owner, avaxLiquidStakerAmt);
		decreaseTotalAVAXLiquidStakerAmt(avaxLiquidStakerAmt);

		emit MinipoolStatusChanged(nodeID, MinipoolStatus.Error);
	}

	// Multisig can cancel a minipool if a problem was encountered *before* claimAndInitiateStaking() was called
	function cancelMinipoolByMultisig(address nodeID, bytes32 errorCode) external {
		int256 minipoolIndex = onlyValidMultisig(nodeID);
		setBytes32(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".errorCode")), errorCode);
		_cancelMinipoolAndReturnFunds(nodeID, minipoolIndex);
	}

	//
	// VIEW FUNCTIONS
	//
	/* TOTAL AVAX AMOUNT */
	// Get/set the total AVAX *actually* withdrawn from ggAVAX and sent to Rialto
	function getTotalAVAXLiquidStakerAmt() external view returns (uint256) {
		return getUint(keccak256("minipool.TotalAVAXLiquidStakerAmt"));
	}

	function increaseTotalAVAXLiquidStakerAmt(uint256 amount) private {
		addUint(keccak256("minipool.TotalAVAXLiquidStakerAmt"), amount);
	}

	function decreaseTotalAVAXLiquidStakerAmt(uint256 amount) private {
		subUint(keccak256("minipool.TotalAVAXLiquidStakerAmt"), amount);
	}

	// Given a duration and an avax amt, calculate how much avax should be earned via staking rewards
	function expectedAVAXRewardsAmt(uint256 duration, uint256 avaxAmt) public view returns (uint256) {
		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		uint256 rate = dao.getExpectedAVAXRewardsRate();
		return (avaxAmt.mulWadDown(rate) * duration) / 365 days;
	}

	// The index of an item
	// Returns -1 if the value is not found
	function getIndexOf(address nodeID) public view returns (int256) {
		return int256(getUint(keccak256(abi.encodePacked("minipool.index", nodeID)))) - 1;
	}

	function getMinipool(int256 index) public view returns (Minipool memory mp) {
		mp.index = index;
		mp.nodeID = getAddress(keccak256(abi.encodePacked("minipool.item", index, ".nodeID")));
		mp.status = getUint(keccak256(abi.encodePacked("minipool.item", index, ".status")));
		mp.duration = getUint(keccak256(abi.encodePacked("minipool.item", index, ".duration")));
		mp.txID = getBytes32(keccak256(abi.encodePacked("minipool.item", index, ".txID")));
		mp.startTime = getUint(keccak256(abi.encodePacked("minipool.item", index, ".startTime")));
		mp.endTime = getUint(keccak256(abi.encodePacked("minipool.item", index, ".endTime")));
		mp.delegationFee = getUint(keccak256(abi.encodePacked("minipool.item", index, ".delegationFee")));
		mp.ggpSlashAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".ggpSlashAmt")));
		mp.avaxNodeOpAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxNodeOpAmt")));
		mp.avaxLiquidStakerAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxLiquidStakerAmt")));
		mp.avaxTotalRewardAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxTotalRewardAmt")));
		mp.avaxNodeOpRewardAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxNodeOpRewardAmt")));
		mp.avaxLiquidStakerRewardAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxLiquidStakerRewardAmt")));
		mp.multisigAddr = getAddress(keccak256(abi.encodePacked("minipool.item", index, ".multisigAddr")));
		mp.owner = getAddress(keccak256(abi.encodePacked("minipool.item", index, ".owner")));
		mp.errorCode = getBytes32(keccak256(abi.encodePacked("minipool.item", index, ".errorCode")));
	}

	function getMinipoolByNodeID(address nodeID) public view returns (Minipool memory mp) {
		int256 index = getIndexOf(nodeID);
		return getMinipool(index);
	}

	// Get minipools in a certain status (limit=0 means no pagination)
	function getMinipools(
		MinipoolStatus status,
		uint256 offset,
		uint256 limit
	) external view returns (Minipool[] memory minipools) {
		uint256 totalMinipools = getUint(keccak256("minipool.count"));
		uint256 max = offset + limit;
		if (max > totalMinipools || limit == 0) {
			max = totalMinipools;
		}
		minipools = new Minipool[](max - offset);
		uint256 total = 0;
		for (uint256 i = offset; i < max; i++) {
			Minipool memory mp = getMinipool(int256(i));
			if (mp.status == uint256(status)) {
				minipools[total] = mp;
				total++;
			}
		}
		// Dirty hack to cut unused elements off end of return value (from RP)
		// solhint-disable-next-line no-inline-assembly
		assembly {
			mstore(minipools, total)
		}
	}

	function getMinipoolCount() external view returns (uint256) {
		return getUint(keccak256("minipool.count"));
	}

	//
	// PRIVATE FUNCTIONS
	//

	// This func could be called by owner or maybe guardian/DAO/etc
	// NOTE At this point we dont have any liq staker funds withdrawn from ggAVAX so no need to return them
	function _cancelMinipoolAndReturnFunds(address nodeID, int256 index) private {
		requireValidStateTransition(index, MinipoolStatus.Canceled);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".status")), uint256(MinipoolStatus.Canceled));

		address owner = getAddress(keccak256(abi.encodePacked("minipool.item", index, ".owner")));
		uint256 avaxNodeOpAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxNodeOpAmt")));
		uint256 avaxLiquidStakerAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxLiquidStakerAmt")));

		Staking staking = Staking(getContractAddress("Staking"));
		staking.decreaseAVAXStake(owner, avaxNodeOpAmt);
		staking.decreaseAVAXAssigned(owner, avaxLiquidStakerAmt);
		staking.decreaseMinipoolCount(owner);

		Vault vault = Vault(getContractAddress("Vault"));
		vault.withdrawAVAX(avaxNodeOpAmt);
		// TODO should we be using safeTransferETH here?
		(bool sent, ) = payable(owner).call{value: avaxNodeOpAmt}("");
		if (!sent) {
			revert ErrorSendingAVAX();
		}

		emit MinipoolStatusChanged(nodeID, MinipoolStatus.Canceled);
	}

	// Extracted this because of "stack too deep" errors.
	function slash(int256 index) private {
		address nodeID = getAddress(keccak256(abi.encodePacked("minipool.item", index, ".nodeID")));
		address owner = getAddress(keccak256(abi.encodePacked("minipool.item", index, ".owner")));
		uint256 duration = getUint(keccak256(abi.encodePacked("minipool.item", index, ".duration")));
		uint256 avaxLiquidStakerAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxLiquidStakerAmt")));
		uint256 expectedAmt = expectedAVAXRewardsAmt(duration, avaxLiquidStakerAmt);
		uint256 slashAmt = calculateSlashAmt(expectedAmt);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".ggpSlashAmt")), slashAmt);
		Staking staking = Staking(getContractAddress("Staking"));
		staking.slashGGP(owner, slashAmt);
		emit GGPSlashed(nodeID, slashAmt);
	}

	// Calculate how much GGP should be slashed given an expectedRewardAmt
	function calculateSlashAmt(uint256 avaxRewardAmt) public view returns (uint256) {
		Oracle oracle = Oracle(getContractAddress("Oracle"));
		(uint256 ggpPriceInAvax, ) = oracle.getGGPPrice();
		return avaxRewardAmt.divWadDown(ggpPriceInAvax);
	}

	function resetMinipoolData(int256 index) private {
		// Zero out any left over data from a previous validation
		setBytes32(keccak256(abi.encodePacked("minipool.item", index, ".txID")), 0);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".startTime")), 0);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".endTime")), 0);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxTotalRewardAmt")), 0);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxNodeOpRewardAmt")), 0);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxLiquidStakerRewardAmt")), 0);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".ggpSlashAmt")), 0);
		setBytes32(keccak256(abi.encodePacked("minipool.item", index, ".errorCode")), 0);
	}

	function increaseTotalAvaxLiquidStakerAmt(uint256 amount) private {
		addUint(keccak256("minipool.total.avaxLiquidStakerAmt"), amount);
	}

	function decreaseTotalAvaxLiquidStakerAmt(uint256 amount) private {
		subUint(keccak256("minipool.total.avaxLiquidStakerAmt"), amount);
	}

	function receiveWithdrawalAVAX() external payable {}
}
