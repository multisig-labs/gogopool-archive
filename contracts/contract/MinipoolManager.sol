pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import {Storage} from "./Storage.sol";
import {Vault} from "./Vault.sol";
import {Oracle} from "./Oracle.sol";
import {ProtocolDAO} from "./dao/ProtocolDAO.sol";
import {MinipoolStatus} from "../types/MinipoolStatus.sol";
import {MultisigManager} from "./MultisigManager.sol";
import {AddressSetStorage} from "./util/AddressSetStorage.sol";
import {NOPClaim} from "./rewards/claims/NOPClaim.sol";
import {TokenggAVAX} from "./tokens/TokenggAVAX.sol";
import {TokenGGP} from "./tokens/TokenGGP.sol";
import {SafeTransferLib} from "@rari-capital/solmate/src/utils/SafeTransferLib.sol";
import {IWithdrawer} from "../interface/IWithdrawer.sol";
import {Staking} from "./Staking.sol";

// TODO might be gotchas here? https://hackernoon.com/beware-the-solidity-enums-9v1qa31b2
import {ERC20, ERC4626} from "@rari-capital/solmate/src/mixins/ERC4626.sol";
import "./Base.sol";

/*
	Data Storage Schema
	(nodeIDs are 20 bytes so can use Solidity 'address' as storage type for them)
	NodeIDs can be added, but never removed. If a nodeID submits another validation request,
	it will overwrite the old one (only allowed for specific statuses).

	minipool.count = Starts at 0 and counts up by 1 after a node is added.
	minipool.index<nodeID> = <index> of nodeID
	minipool.item<index>.nodeID = nodeID used as primary key (NOT the ascii "Node-blah" but the actual 20 bytes)
	minipool.item<index>.status = enum
	minipool.item<index>.duration = requested validation duration in seconds
	minipool.item<index>.owner = owner address
	minipool.item<index>.delegationFee = node operator specified fee (must be between 0 and 1_000_000) 2% is 20_000
	minipool.item<index>.avaxNodeOpAmt = avax deposited by node op (1000 avax for now)
	minipool.item<index>.avaxUserAmt = avax deposited by users (1000 avax for now)
	minipool.item<index>.ggpBondAmt = amt ggp deposited by node op for bond
	minipool.item<index>.multisigAddr = which Rialto multisig is assigned to manage this validation (in future could be multiple)
	// Below are submitted by Rialto oracle
	minipool.item<index>.txID = transaction id of the AddValidatorTx
	minipool.item<index>.startTime = actual time validation was started
	minipool.item<index>.endTime = actual time validation was finished
	minipool.item<index>.avaxTotalRewardAmt = Actual total avax rewards paid by avalanchego to the TSS P-chain addr
	// These are calculated in recordStakingEnd
	minipool.item<index>.avaxNodeOpRewardAmt
	minipool.item<index>.avaxUserRewardAmt
	minipool.item<index>.ggpSlashAmt = amt of ggp bond that was slashed if necessary (expected reward amt = avaxUserAmt * x%/yr / ggpPriceInAvax)
*/

contract MinipoolManager is Base, IWithdrawer {
	using SafeTransferLib for ERC20;
	using SafeTransferLib for address;

	ERC20 public immutable ggp;
	TokenggAVAX public immutable ggAVAX;

	uint256 public immutable MIN_STAKING_AMT = 2000 ether;
	bytes32 public immutable MINIPOOL_QUEUE_KEY = keccak256("minipoolQueue");

	// Not used for storage, just for returning data from view functions
	struct Minipool {
		address nodeID;
		uint256 status;
		uint256 duration;
		uint256 startTime;
		uint256 endTime;
		uint256 delegationFee;
		uint256 ggpBondAmt;
		uint256 ggpSlashAmt;
		uint256 avaxNodeOpAmt;
		uint256 avaxUserAmt;
		uint256 avaxTotalRewardAmt;
		uint256 avaxNodeOpRewardAmt;
		uint256 avaxUserRewardAmt;
		address owner;
		address multisigAddr;
		bytes32 txID;
	}

	/// @notice A minipool with this nodeid has already been registered
	error MinipoolAlreadyRegistered();

	/// @notice A minipool with this nodeid has not been registered
	error MinipoolNotFound();

	/// @notice Invalid state transition
	error InvalidStateTransition();

	/// @notice Validation end time must be after start time
	error InvalidEndTime();

	error InvalidAmount();

	/// @notice Only minipool owners can cancel a minipool before validation starts
	error OnlyOwnerCanCancel();

	/// @notice Only minipool owners can withdraw minipool funds
	error OnlyOwnerCanWithdraw();

	/// @notice Only the multisig assigned to a minipool can interact with it
	error InvalidMultisigAddress();

	/// @notice Invalid signature from the multisig
	error InvalidMultisigSignature();

	/// @notice An error occured when attempting to issue a validation tx for the nodeID
	error ErrorIssuingValidationTx();

	error MinipoolMustBeInitialised();

	error ErrorSendingAvax();

	error InsufficientAvaxForStaking();

	error InsufficientGgpCollateralization();

	error InsufficientAvaxVaultBalance();

	event MinipoolStatusChanged(address indexed nodeID, MinipoolStatus indexed status);

	event ZeroRewardsReceived(address indexed nodeID);

	constructor(
		Storage storageAddress,
		ERC20 ggp_,
		TokenggAVAX ggAVAX_
	) Base(storageAddress) {
		version = 1;
		ggp = ggp_;
		ggAVAX = ggAVAX_;
	}

	// Accept deposit from node operator
	function createMinipool(
		address nodeID,
		uint256 duration,
		uint256 delegationFee
	) external payable {
		// All funds AVAX and GGP will be stored in the Vault contract
		Vault vault = Vault(getContractAddress("Vault"));

		require(msg.value >= 1000 ether, "Must create a minipool with at least 1000 AVAX");

		Oracle oracle = Oracle(getContractAddress("Oracle"));
		(uint256 ggpPriceInAvax, ) = oracle.getGGPPrice();

		Staking staking = Staking(getContractAddress("Staking"));
		// maybe use mulDivDown?
		if ((((staking.getNodeGGPStake(msg.sender) * ggpPriceInAvax * 100) / 1 ether) / (getTotalAvaxStakedByUser(msg.sender) + msg.value)) < 10) {
			revert InsufficientGgpCollateralization();
		}

		vault.depositAvax{value: msg.value}();

		// If nodeID exists, only allow overwriting if node is finished or canceled
		// (completed its validation period and all rewards paid and processing is complete)
		// getIndexOf returns -1 if node does not exist, so have to use signed type int256 here
		int256 index = getIndexOf(nodeID);
		if (index != -1) {
			requireValidStateTransition(index, MinipoolStatus.Prelaunch);
			// Zero out any left over data from a previous validation
			setBytes32(keccak256(abi.encodePacked("minipool.item", index, ".txID")), 0);
			setUint(keccak256(abi.encodePacked("minipool.item", index, ".startTime")), 0);
			setUint(keccak256(abi.encodePacked("minipool.item", index, ".endTime")), 0);
			setUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxUserAmt")), 0);
			setUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxTotalRewardAmt")), 0);
			setUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxNodeOpRewardAmt")), 0);
			setUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxUserRewardAmt")), 0);
			setUint(keccak256(abi.encodePacked("minipool.item", index, ".ggpSlashAmt")), 0);
		} else {
			index = int256(getUint(keccak256("minipool.count")));
		}

		// Get a Rialto multisig to assign for this minipool
		MultisigManager multisigManager = MultisigManager(getContractAddress("MultisigManager"));
		address multisig = multisigManager.getNextActiveMultisig();
		if (multisig == address(0)) {
			revert InvalidMultisigAddress();
		}
		// Save the attrs individually in the k/v store
		setAddress(keccak256(abi.encodePacked("minipool.item", index, ".nodeID")), nodeID);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".status")), uint256(MinipoolStatus.Prelaunch));
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".duration")), duration);
		setAddress(keccak256(abi.encodePacked("minipool.item", index, ".multisigAddr")), multisig);
		setAddress(keccak256(abi.encodePacked("minipool.item", index, ".owner")), msg.sender);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxNodeOpAmt")), msg.value);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".delegationFee")), delegationFee);

		// NOTE the index is actually 1 more than where it is actually stored. The 1 is subtracted in getIndexOf().
		// Copied from RP, probably so they can use "-1" to signify that something doesnt exist
		setUint(keccak256(abi.encodePacked("minipool.index", nodeID)), uint256(index + 1));
		addUint(keccak256("minipool.count"), 1);
		if (!isUserRegistered(msg.sender)) {
			registerUser(msg.sender);
		}

		emit MinipoolStatusChanged(nodeID, MinipoolStatus.Prelaunch);
	}

	function isUserRegistered(address userAddress) internal view returns (bool) {
		AddressSetStorage addressSetStorage = AddressSetStorage(getContractAddress("AddressSetStorage"));
		return addressSetStorage.getIndexOf(keccak256(abi.encodePacked("nodes.index")), userAddress) != -1;
	}

	// Save owner address, set as withdrawal address for easy lookup later
	// Also register them as a claimaint in the GGP rewards system
	function registerUser(address userAddress) internal {
		// Initialise node data
		setBool(keccak256(abi.encodePacked("node.exists", msg.sender)), true);
		// setString(keccak256(abi.encodePacked("node.timezone.location", msg.sender)), _timezoneLocation);
		// Add node to index
		AddressSetStorage addressSetStorage = AddressSetStorage(getContractAddress("AddressSetStorage"));
		addressSetStorage.addItem(keccak256(abi.encodePacked("nodes.index")), userAddress);

		// Register node for GGP claims
		// TODO add if statement to handle registration of investor / rialto nodes
		NOPClaim nopClaim = NOPClaim(getContractAddress("NOPClaim"));
		nopClaim.register(userAddress, true);

		// set withdrawal address
		// gogoStorage.setWithdrawalAddress(userAddress, userAddress, true);

		// Emit node registered event
		// emit NodeRegistered(msg.sender, block.timestamp);
		// emit MinipoolStatusChanged(nodeID, MinipoolStatus.Prelaunch);
	}

	// TODO This forces a minipool into a specific state. Do we need this? For tests? For guardian?
	function updateMinipoolStatus(address nodeID, MinipoolStatus status) external {
		int256 index = getIndexOf(nodeID);
		if (index == -1) {
			revert MinipoolNotFound();
		}
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".status")), uint256(status));
	}

	// Node op calls this to withdraw all funds they are due (orig, plus any rewards, minus any slashing)
	function withdrawMinipoolFunds(address nodeID) external {
		int256 index = getIndexOf(nodeID);
		if (index == -1) {
			revert MinipoolNotFound();
		}
		address owner = getAddress(keccak256(abi.encodePacked("minipool.item", index, ".owner")));
		if (msg.sender != owner) {
			revert OnlyOwnerCanWithdraw();
		}
		requireValidStateTransition(index, MinipoolStatus.Finished);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".status")), uint256(MinipoolStatus.Finished));

		Vault vault = Vault(getContractAddress("Vault"));
		Staking staking = Staking(getContractAddress("Staking"));

		uint256 ggpBondAmt = staking.getNodeGGPStake(nodeID);
		uint256 ggpSlashAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".ggpSlashAmt")));

		uint256 ggpAmtDue = ggpBondAmt - ggpSlashAmt;

		if (ggpAmtDue > 0) {
			vault.withdrawToken(owner, ggp, ggpAmtDue);
		}

		uint256 avaxNodeOpAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxNodeOpAmt")));
		uint256 avaxNodeOpRewardAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxNodeOpRewardAmt")));
		uint256 totalAvax = avaxNodeOpAmt + avaxNodeOpRewardAmt;
		vault.withdrawAvax(totalAvax);
		// TODO should we be using safeTransferETH here?
		(bool sent, ) = payable(owner).call{value: totalAvax}("");
		if (!sent) {
			revert ErrorSendingAvax();
		}
	}

	// Owner of a node can call this to cancel the minipool
	// TODO Should DAO also be able to cancel? Or guardian? or Rialto?
	// TODO Should also return staked GGP?
	function cancelMinipool(address nodeID) external {
		int256 index = getIndexOf(nodeID);
		if (index == -1) {
			revert MinipoolNotFound();
		}
		address owner = getAddress(keccak256(abi.encodePacked("minipool.item", index, ".owner")));
		if (msg.sender != owner) {
			revert OnlyOwnerCanCancel();
		}
		_cancelMinipoolAndReturnFunds(nodeID, index);
	}

	function _cancelMinipoolAndReturnFunds(address nodeID, int256 index) private {
		requireValidStateTransition(index, MinipoolStatus.Canceled);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".status")), uint256(MinipoolStatus.Canceled));

		Vault vault = Vault(getContractAddress("Vault"));
		address owner = getAddress(keccak256(abi.encodePacked("minipool.item", index, ".owner")));

		uint256 avaxNodeOpAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxNodeOpAmt")));
		if (avaxNodeOpAmt > 0) {
			vault.withdrawAvax(avaxNodeOpAmt);
			// TODO should we be using safeTransferETH here?
			(bool sent, ) = payable(owner).call{value: avaxNodeOpAmt}("");
			if (!sent) {
				revert ErrorSendingAvax();
			}
		}
		emit MinipoolStatusChanged(nodeID, MinipoolStatus.Canceled);
	}

	function receiveWithdrawalAVAX() external payable {}

	//
	// RIALTO FUNCTIONS
	//

	// Rialto calls this to see if a claim would succeed. Does not change state.
	function canClaimAndInitiateStaking(address nodeID) external view returns (bool) {
		// TODO Ugh is this OK for the front end if we revert instead of returning false?
		int256 index = requireValidMultisig(nodeID);
		requireValidStateTransition(index, MinipoolStatus.Launched);

		uint256 avaxUserAmt;
		uint256 avaxNodeOpAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxNodeOpAmt")));
		if (avaxNodeOpAmt < MIN_STAKING_AMT) {
			avaxUserAmt = MIN_STAKING_AMT - avaxNodeOpAmt;
		}
		// Make sure we have enough liq staker funds
		if (avaxUserAmt > ggAVAX.amountAvailableForStaking()) {
			return false;
		}
		return true;
	}

	// If correct multisig calls this, xfer funds from vault to msg.sender
	function claimAndInitiateStaking(address nodeID) external {
		int256 index = requireValidMultisig(nodeID);
		requireValidStateTransition(index, MinipoolStatus.Launched);
		Vault vault = Vault(getContractAddress("Vault"));

		uint256 avaxUserAmt;
		uint256 avaxNodeOpAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxNodeOpAmt")));
		// TODO Do we let folks request *more* user funds than the min? How to handle GGP bond if thats the case?
		if (avaxNodeOpAmt < MIN_STAKING_AMT) {
			avaxUserAmt = MIN_STAKING_AMT - avaxNodeOpAmt;
		}

		if (avaxUserAmt > 0) {
			setUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxUserAmt")), avaxUserAmt);
			// Transfer the user funds to this contract
			ggAVAX.withdrawForStaking(avaxUserAmt);
		}
		vault.withdrawAvax(avaxNodeOpAmt);

		uint256 totalAvaxAmt = avaxNodeOpAmt + avaxUserAmt;
		// TODO also get MAX_STAKING_AMT from DAO setting?
		if (totalAvaxAmt < MIN_STAKING_AMT) {
			revert InsufficientAvaxForStaking();
		}

		setUint(keccak256(abi.encodePacked("minipool.item", index, ".status")), uint256(MinipoolStatus.Launched));
		emit MinipoolStatusChanged(nodeID, MinipoolStatus.Launched);
		msg.sender.safeTransferETH(totalAvaxAmt);
	}

	// Rialto calls this after a successful minipool launch
	// TODO Is it worth it to validate startTime? Or just depend on rialto to do the right thing?
	function recordStakingStart(
		address nodeID,
		bytes32 txID,
		uint256 startTime
	) external {
		int256 index = requireValidMultisig(nodeID);

		requireValidStateTransition(index, MinipoolStatus.Staking);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".status")), uint256(MinipoolStatus.Staking));
		setBytes32(keccak256(abi.encodePacked("minipool.item", index, ".txID")), txID);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".startTime")), startTime);
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
		int256 index = requireValidMultisig(nodeID);
		requireValidStateTransition(index, MinipoolStatus.Withdrawable);

		uint256 startTime = getUint(keccak256(abi.encodePacked("minipool.item", index, ".startTime")));
		if (endTime <= startTime || endTime > block.timestamp) {
			revert InvalidEndTime();
		}

		uint256 avaxNodeOpAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxNodeOpAmt")));
		uint256 avaxUserAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxUserAmt")));
		uint256 totalAvaxAmt = avaxNodeOpAmt + avaxUserAmt;
		if (msg.value != totalAvaxAmt + avaxTotalRewardAmt) {
			revert InvalidAmount();
		}

		Vault vault = Vault(getContractAddress("Vault"));

		setUint(keccak256(abi.encodePacked("minipool.item", index, ".status")), uint256(MinipoolStatus.Withdrawable));
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".endTime")), endTime);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxTotalRewardAmt")), avaxTotalRewardAmt);

		// No rewards means validation period failed. Must slash node op (which means just update storage for bookeeping)
		if (avaxTotalRewardAmt == 0) {
			uint256 duration = getUint(keccak256(abi.encodePacked("minipool.item", index, ".duration")));
			uint256 expectedAmt = expectedRewardAmt(duration, avaxUserAmt);
			uint256 slashAmt = calculateSlashAmt(expectedAmt);
			setUint(keccak256(abi.encodePacked("minipool.item", index, ".ggpSlashAmt")), slashAmt);
			ggAVAX.depositFromStaking{value: avaxUserAmt}(avaxUserAmt, 0);
			// Send the nodeOps AVAX to vault so they can claim later
			vault.depositAvax{value: avaxNodeOpAmt}();
		} else {
			uint256 avaxUserRewardAmt;
			uint256 avaxHalfRewards;
			if (avaxUserAmt > 0) {
				avaxHalfRewards = avaxTotalRewardAmt / 2;
				avaxUserRewardAmt = avaxHalfRewards - ((avaxHalfRewards * 15) / 100); // we are giving node operators an additional 15% commission fee
				ggAVAX.depositFromStaking{value: avaxUserAmt + avaxUserRewardAmt}(avaxUserAmt, avaxUserRewardAmt);
			}
			// If no user funds were used, nodeop gets the whole reward
			uint256 avaxNodeOpRewardAmt = avaxTotalRewardAmt - avaxUserRewardAmt;

			setUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxNodeOpRewardAmt")), avaxNodeOpRewardAmt);
			setUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxUserRewardAmt")), avaxUserRewardAmt);

			// Send the nodeOps AVAX + rewards to vault so they can claim later
			vault.depositAvax{value: avaxNodeOpAmt + avaxNodeOpRewardAmt}();
		}

		emit MinipoolStatusChanged(nodeID, MinipoolStatus.Withdrawable);
	}

	// Calculate how much GGP should be slashed given an expectedRewardAmt
	function calculateSlashAmt(uint256 avaxRewardAmt) public view returns (uint256) {
		Oracle oracle = Oracle(getContractAddress("Oracle"));
		(uint256 ggpPriceInAvax, ) = oracle.getGGPPrice();
		return (1 ether * avaxRewardAmt) / ggpPriceInAvax;
	}

	// Given a duration and an avax amt, calculate how much avax should be earned via staking rewards
	function expectedRewardAmt(uint256 duration, uint256 avaxAmt) public view returns (uint256) {
		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		uint256 rate = dao.getExpectedRewardRate();
		return (avaxAmt * ((duration * rate) / 365 days)) / 1 ether;
	}

	// Rialto was for some reason unable to start the validation period, so cancel and refund all monies?
	// Should prob be payable and send all funds back to here?
	function recordStakingError(address nodeID, string calldata message) external {
		// TODO
	}

	// The index of an item
	// Returns -1 if the value is not found
	// TODO I dont love this. Maybe split into getIndexOf that reverts if not found, and maybeGetIndexOf which would return -1 if not found?
	function getIndexOf(address nodeID) public view returns (int256) {
		return int256(getUint(keccak256(abi.encodePacked("minipool.index", nodeID)))) - 1;
	}

	function getMinipool(int256 index) public view returns (Minipool memory mp) {
		mp.nodeID = getAddress(keccak256(abi.encodePacked("minipool.item", index, ".nodeID")));
		mp.status = getUint(keccak256(abi.encodePacked("minipool.item", index, ".status")));
		mp.duration = getUint(keccak256(abi.encodePacked("minipool.item", index, ".duration")));
		mp.txID = getBytes32(keccak256(abi.encodePacked("minipool.item", index, ".txID")));
		mp.startTime = getUint(keccak256(abi.encodePacked("minipool.item", index, ".startTime")));
		mp.endTime = getUint(keccak256(abi.encodePacked("minipool.item", index, ".endTime")));
		mp.delegationFee = getUint(keccak256(abi.encodePacked("minipool.item", index, ".delegationFee")));
		mp.ggpSlashAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".ggpSlashAmt")));
		mp.avaxNodeOpAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxNodeOpAmt")));
		mp.avaxUserAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxUserAmt")));
		mp.avaxTotalRewardAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxTotalRewardAmt")));
		mp.avaxNodeOpRewardAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxNodeOpRewardAmt")));
		mp.avaxUserRewardAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxUserRewardAmt")));
		mp.multisigAddr = getAddress(keccak256(abi.encodePacked("minipool.item", index, ".multisigAddr")));
		mp.owner = getAddress(keccak256(abi.encodePacked("minipool.item", index, ".owner")));
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

	// Get the number of minipools in each status.
	// TODO probably remove this method, off chain actors can grab all minipools and count themselves.
	function getMinipoolCountPerStatus(uint256 offset, uint256 limit)
		external
		view
		returns (
			uint256 prelaunchCount,
			uint256 launchedCount,
			uint256 stakingCount,
			uint256 withdrawableCount,
			uint256 finishedCount,
			uint256 canceledCount
		)
	{
		// Iterate over the requested minipool range
		uint256 totalMinipools = getUint(keccak256("minipool.count"));
		uint256 max = offset + limit;
		if (max > totalMinipools || limit == 0) {
			max = totalMinipools;
		}
		for (uint256 i = offset; i < max; i++) {
			// Get the minipool at index i
			Minipool memory mp = getMinipool(int256(i));
			// Get the minipool's status, and update the appropriate counter
			if (mp.status == uint256(MinipoolStatus.Prelaunch)) {
				prelaunchCount++;
			} else if (mp.status == uint256(MinipoolStatus.Launched)) {
				launchedCount++;
			} else if (mp.status == uint256(MinipoolStatus.Staking)) {
				stakingCount++;
			} else if (mp.status == uint256(MinipoolStatus.Withdrawable)) {
				withdrawableCount++;
			} else if (mp.status == uint256(MinipoolStatus.Finished)) {
				finishedCount++;
			} else if (mp.status == uint256(MinipoolStatus.Canceled)) {
				canceledCount++;
			}
		}
	}

	function requireValidMultisig(address nodeID) private view returns (int256) {
		int256 index = getIndexOf(nodeID);
		if (index == -1) {
			revert MinipoolNotFound();
		}

		address assignedMultisig = getAddress(keccak256(abi.encodePacked("minipool.item", index, ".multisigAddr")));
		if (msg.sender != assignedMultisig) {
			revert InvalidMultisigAddress();
		}
		return index;
	}

	// TODO how to handle error when Rialto is issuing validation tx? error status? or set to withdrawable with an error note or something?
	function requireValidStateTransition(int256 index, MinipoolStatus to) private view {
		bytes32 statusKey = keccak256(abi.encodePacked("minipool.item", index, ".status"));
		MinipoolStatus currentStatus = MinipoolStatus(getUint(statusKey));
		bool isValid;

		if (currentStatus == MinipoolStatus.Prelaunch) {
			isValid = (to == MinipoolStatus.Launched || to == MinipoolStatus.Canceled);
		} else if (currentStatus == MinipoolStatus.Launched) {
			isValid = (to == MinipoolStatus.Staking || to == MinipoolStatus.Canceled);
		} else if (currentStatus == MinipoolStatus.Staking) {
			isValid = (to == MinipoolStatus.Withdrawable);
		} else if (currentStatus == MinipoolStatus.Withdrawable) {
			isValid = (to == MinipoolStatus.Finished);
		} else if (currentStatus == MinipoolStatus.Finished || currentStatus == MinipoolStatus.Canceled) {
			// Once a node is finished or canceled, if they re-validate they go back to beginning state
			isValid = (to == MinipoolStatus.Prelaunch);
		} else {
			isValid = false;
		}

		if (!isValid) {
			revert InvalidStateTransition();
		}
	}

	function getNodeEffectiveGGPStake(address _nodeAddress) public view returns (uint256) {
		// TODO include the DelegationManager inside of this to count up how much avax (if any) the user put up thru the DM?
		// ^ not sure if this is a thing
		Oracle oracle = Oracle(getContractAddress("Oracle"));
		(uint256 ggpPriceInAvax, ) = oracle.getGGPPrice();

		Staking staking = Staking(getContractAddress("Staking"));
		uint256 nodeGGPStaked = staking.getNodeGGPStake(_nodeAddress);

		uint256 totalMinipools = getUint(keccak256("minipool.count"));

		uint256 maxGGPStakedInAvax = 0;
		for (uint256 i = 0; i < totalMinipools; i++) {
			Minipool memory mp = getMinipool(int256(i));

			// TODO Sum up total avax principle in minipools. is there a way to iterate though a nodeops minipools?
			if (mp.owner == _nodeAddress) {
				uint256 maxGgp = (1.5 ether * mp.avaxNodeOpAmt) / 1 ether;
				maxGGPStakedInAvax += maxGgp;
			}
		}

		return minimumInGGP(nodeGGPStaked, maxGGPStakedInAvax, ggpPriceInAvax);
	}

	function getTotalEffectiveGGPStake() public view returns (uint256) {
		// TODO include the DelegationManager inside of this to count up how much avax (if any) the user put up thru the DM?
		// ^ not sure if this is a thing
		// TODO is this a potentially unbounded loop? If so we should call this off chain?
		// that's what rocetpool says, that it's an unbounded loop that they call offchain
		// https://github.com/rocket-pool/rocketpool/blob/3d6df4c87401f303f6acbdd249bdcb182e8827f3/contracts/contract/node/RocketNodeStaking.sol#L72
		// if this is the case, call this function off chain and save it as a setting i nthe sotrage contract (and add a getter for the setting that other functions can cal)

		uint256 totalMinipools = getUint(keccak256("minipool.count"));

		Oracle oracle = Oracle(getContractAddress("Oracle"));
		(uint256 ggpPriceInAvax, ) = oracle.getGGPPrice();

		Staking staking = Staking(getContractAddress("Staking"));
		uint256 totalGGPStaked = staking.getTotalGGPStake();

		uint256 maxGgpStakeInAvax = 0;
		for (uint256 i = 0; i < totalMinipools; i++) {
			Minipool memory mp = getMinipool(int256(i));
			maxGgpStakeInAvax += (1.5 ether * mp.avaxNodeOpAmt) / 1 ether;
		}

		uint256 totalGgpStakeInAvax = (totalGGPStaked * ggpPriceInAvax) / 1 ether;

		return minimumInGGP(totalGgpStakeInAvax, maxGgpStakeInAvax, ggpPriceInAvax);
	}

	function minimumInGGP(
		uint256 amt,
		uint256 max,
		uint256 priceInAvax
	) internal pure returns (uint256) {
		uint256 effective = 0;
		if (amt < max) {
			effective = amt;
		} else {
			effective = max;
		}

		uint256 effectiveInGGP = (effective / priceInAvax) * 1 ether;

		return effectiveInGGP;
	}

	function getTotalAvaxStakedByUser(address _nodeAddress) public view returns (uint256) {
		// TODO include the DelegationManager inside of this to count up how much avax (if any) the user put up thru the DM?
		// ^ not sure if this is a thing
		uint256 totalMinipools = getUint(keccak256("minipool.count"));
		uint256 totalAvaxStaked = 0;
		for (uint256 i = 0; i < totalMinipools; i++) {
			Minipool memory mp = getMinipool(int256(i));
			// ToDo consider what MinipoolStatus should count as staked
			if (address(mp.owner) == _nodeAddress && mp.status != uint256(MinipoolStatus.Canceled)) {
				totalAvaxStaked = totalAvaxStaked + mp.avaxNodeOpAmt;
			}
		}
		return totalAvaxStaked;
	}
}
