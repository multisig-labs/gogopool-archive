pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "../interface/IStorage.sol";
import "../interface/IMultisigManager.sol";
import "../interface/IVault.sol";
import "./tokens/TokenGGP.sol";
// TODO might be gotchas here? https://hackernoon.com/beware-the-solidity-enums-9v1qa31b2
import "../types/MinipoolStatus.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
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
	minipool.item<index>.delegationFee = node operator specified fee
	minipool.item<index>.avaxAmt = avax deposited by node op (1000 avax for now)
	minipool.item<index>.avaxUserAmt = avax deposited by users (1000 avax for now)
	minipool.item<index>.ggpBondAmt = amt ggp deposited by node op for bond
	minipool.item<index>.multisigAddr = which Rialto multisig is assigned to manage this validation (in future could be multiple)
	// Below are submitted by Rialto oracle
	minipool.item<index>.startTime = actual time validation was started
	minipool.item<index>.endTime = actual time validation was finished
	minipool.item<index>.avaxRewardAmt = Actual total avax rewards paid by avalanchego to the TSS P-chain addr
*/

contract MinipoolManager is Base {
	// Used for signature verifying of Rialto multisig to prevent replay attacks
	mapping(address => uint256) private nonces;

	ERC20 public immutable ggp;

	/// @notice A minipool with this nodeid has already been registered
	error MinipoolAlreadyRegistered();

	/// @notice A minipool with this nodeid has not been registered
	error MinipoolNotFound();

	/// @notice Invalid state transition
	error InvalidStateTransition();

	/// @notice Validation end time must be after start time
	error InvalidEndTime();

	/// @notice Only minipool owners can cancel a minipool before validation starts
	error OnlyOwnerCanCancel();

	/// @notice Only the multisig assigned to a minipool can interact with it
	error InvalidMultisigAddress();

	/// @notice Invalid signature from the multisig
	error InvalidMultisigSignature();

	/// @notice An error occured when attempting to issue a validation tx for the nodeID
	error ErrorIssuingValidationTx();

	error MinipoolMustBeInitialised();

	error ErrorSendingAvax();

	event MinipoolStatusChanged(address indexed nodeID, MinipoolStatus indexed status);

	constructor(IStorage storageAddress, ERC20 ggp_) Base(storageAddress) {
		version = 1;
		ggp = ggp_;
	}

	// Accept deposit from node operator
	function createMinipool(
		address nodeID,
		uint256 duration,
		uint256 delegationFee,
		uint256 ggpBondAmt
	) external payable {
		// TODO check for max node count from dao
		// TODO check for valid AVAX and GGP bond amount (1000 AVAX to start?)

		// All funds AVAX and GGP will be stored in the Vault contract
		IVault vault = IVault(getContractAddress("Vault"));

		if (ggpBondAmt > 0) {
			// Move the GGP funds (assume allowance has been set properly beforehand by the front end)
			// TODO switch to error objects
			require(ggp.transferFrom(msg.sender, address(this), ggpBondAmt), "Could not transfer GGP to MiniPool contract");
			require(ggp.approve(address(vault), ggpBondAmt), "Could not approve vault GGP deposit");
			// depositToken reverts if not successful
			vault.depositToken("MinipoolManager", ggp, ggpBondAmt);
		}

		// TODO if (vault.balanceOf("MinipoolManager").add(msg.value) <= some setting ), "The deposit pool size after depositing exceeds the maximum size");
		vault.depositAvax{value: msg.value}();

		// If nodeID exists, only allow overwriting if node is finished or canceled
		// (completed its validation period and all rewards paid and processing is complete)
		uint256 index;
		// getIndexOf returns -1 if node does not exist, so have to use signed type int256 here
		int256 i = getIndexOf(nodeID);
		if (i != -1) {
			// Existing nodeID
			requireValidStateTransition(i, MinipoolStatus.Initialised);
			index = uint256(i);
			// Zero out any left over data from a previous validation
			setUint(keccak256(abi.encodePacked("minipool.item", index, ".startTime")), 0);
			setUint(keccak256(abi.encodePacked("minipool.item", index, ".endTime")), 0);
			setUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxRewardAmt")), 0);
		} else {
			// new nodeID
			index = getUint(keccak256("minipool.count"));
		}

		// Get a Rialto multisig to assign for this minipool
		IMultisigManager multisigManager = IMultisigManager(getContractAddress("MultisigManager"));
		address multisig = multisigManager.getNextActiveMultisig();

		// Save the attrs individually in the k/v store
		setAddress(keccak256(abi.encodePacked("minipool.item", index, ".nodeID")), nodeID);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".status")), uint256(MinipoolStatus.Initialised));
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".duration")), duration);
		setAddress(keccak256(abi.encodePacked("minipool.item", index, ".multisigAddr")), multisig);
		setAddress(keccak256(abi.encodePacked("minipool.item", index, ".owner")), msg.sender);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxAmt")), msg.value);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".delegationFee")), delegationFee);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".ggpBondAmt")), ggpBondAmt);

		// NOTE the index is actually 1 more than where it is actually stored. The 1 is subtracted in getIndexOf().
		// Copied from RP, probably so they can use "-1" to signify that something doesnt exist
		setUint(keccak256(abi.encodePacked("minipool.index", nodeID)), index + 1);
		addUint(keccak256("minipool.count"), 1);
		emit MinipoolStatusChanged(nodeID, MinipoolStatus.Initialised);
	}

	// This forces minipool into a state. Do we need this? For tests?
	function updateMinipoolStatus(address nodeID, MinipoolStatus status) external {
		int256 index = getIndexOf(nodeID);
		if (index == -1) {
			revert MinipoolNotFound();
		}
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".status")), uint256(status));
	}

	//
	// RIALTO FUNCTIONS
	//

	// Owner of a node can call this to cancel the minipool
	function cancelMinipool(address nodeID) external {
		int256 index = getIndexOf(nodeID);
		if (index == -1) {
			revert MinipoolNotFound();
		}
		address owner = getAddress(keccak256(abi.encodePacked("minipool.item", index, ".owner")));
		if (msg.sender != owner) {
			revert OnlyOwnerCanCancel();
		}
		_cancelMinipoolAndReturnFunds(index);
	}

	// TODO Do we allow Rialto to also cancel a minipool using this func?
	function cancelMinipool(address nodeID, bytes memory sig) external {
		int256 index = requireValidMultisig(nodeID, sig);
		_cancelMinipoolAndReturnFunds(index);
	}

	function _cancelMinipoolAndReturnFunds(int256 index) private {
		requireValidStateTransition(index, MinipoolStatus.Canceled);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".status")), uint256(MinipoolStatus.Canceled));
		IVault vault = IVault(getContractAddress("Vault"));
		address owner = getAddress(keccak256(abi.encodePacked("minipool.item", index, ".owner")));
		uint256 ggpBondAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".ggpBondAmt")));
		if (ggpBondAmt > 0) {
			vault.withdrawToken(owner, ggp, ggpBondAmt);
		}
		uint256 avaxAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxAmt")));
		if (avaxAmt > 0) {
			vault.withdrawAvax(avaxAmt);
			(bool sent, ) = payable(owner).call{value: avaxAmt}("");
			if (!sent) {
				revert ErrorSendingAvax();
			}
		}
	}

	// TODO implement the modifiers
	function receiveVaultWithdrawalAVAX() external payable {} // onlyThisLatestContract onlyLatestContract("rocketVault", msg.sender) {}

	// If correct multisig calls this, xfer funds from vault to their address
	function claimAndInitiateStaking(address nodeID, bytes memory sig) external {
		requireValidMultisig(nodeID, sig);
		// TODO xfer funds
	}

	// Rialto calls this after a successful minipool launch
	function recordStakingStart(
		address nodeID,
		bytes memory sig,
		uint256 startTime
	) external {
		int256 index = requireValidMultisig(nodeID, sig);
		requireValidStateTransition(index, MinipoolStatus.Staking);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".status")), uint256(MinipoolStatus.Staking));
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".startTime")), startTime);
		// emit StakingStartEvent
	}

	// Rialto calls this when validation period ends
	// Rialto will also xfer back all avax + avax rewards to vault
	// TODO is this payable then? accept all funds here and distribute?
	function recordStakingEnd(
		address nodeID,
		bytes memory sig,
		uint256 endTime,
		uint256 avaxRewardAmt
	) external {
		int256 index = requireValidMultisig(nodeID, sig);
		requireValidStateTransition(index, MinipoolStatus.Withdrawable);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".status")), uint256(MinipoolStatus.Withdrawable));

		uint256 startTime = getUint(keccak256(abi.encodePacked("minipool.item", index, ".startTime")));
		if (endTime <= startTime) {
			revert InvalidEndTime();
		}
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".endTime")), endTime);

		setUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxRewardAmt")), avaxRewardAmt);
		// emit StakingEndEvent
	}

	function recordStakingError(
		address nodeID,
		bytes memory sig,
		uint256 endTime,
		string calldata message
	) external {
		// TODO
	}

	function getNonce(address signer) public view returns (uint256) {
		return nonces[signer];
	}

	// The index of an item
	// Returns -1 if the value is not found
	function getIndexOf(address nodeID) public view returns (int256) {
		return int256(getUint(keccak256(abi.encodePacked("minipool.index", nodeID)))) - 1;
	}

	function getMinipool(int256 index)
		public
		view
		returns (
			address nodeID,
			uint256 status,
			uint256 duration,
			uint256 delegationFee,
			uint256 ggpBondAmt
		)
	{
		nodeID = getAddress(keccak256(abi.encodePacked("minipool.item", index, ".nodeID")));
		status = getUint(keccak256(abi.encodePacked("minipool.item", index, ".status")));
		duration = getUint(keccak256(abi.encodePacked("minipool.item", index, ".duration")));
		delegationFee = getUint(keccak256(abi.encodePacked("minipool.item", index, ".delegationFee")));
		ggpBondAmt = getUint(keccak256(abi.encodePacked("minipool.item", index, ".ggpBondAmt")));
	}

	// Given a signer addr, return the hash that should be signed to claim a nodeID
	// SECURITY the client should not depend on this func to know what to sign, they should always do it themselves
	function formatClaimMessageHash(address signer) private view returns (bytes32) {
		return ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(this, signer, nonces[signer])));
	}

	// Verify that signer is an enabled multisig, and signature is valid for current nonce value, and bump nonce
	function requireValidSigAndUpdateNonce(address signer, bytes memory sig) private {
		bytes32 msgHash = formatClaimMessageHash(signer);
		nonces[signer] += 1;
		IMultisigManager multisigManager = IMultisigManager(getContractAddress("MultisigManager"));
		multisigManager.requireValidSignature(signer, msgHash, sig);
	}

	function requireValidMultisig(address nodeID, bytes memory sig) private returns (int256) {
		int256 index = getIndexOf(nodeID);
		if (index == -1) {
			revert MinipoolNotFound();
		}

		address assignedMultisig = getAddress(keccak256(abi.encodePacked("minipool.item", index, ".multisigAddr")));
		if (msg.sender != assignedMultisig) {
			revert InvalidMultisigAddress();
		}
		requireValidSigAndUpdateNonce(assignedMultisig, sig);
		return index;
	}

	// TODO how to handle error when Rialto is issuing validation tx? error status? or set to withdrawable with an error note or something?
	function requireValidStateTransition(int256 index, MinipoolStatus to) private view {
		bytes32 statusKey = keccak256(abi.encodePacked("minipool.item", index, ".status"));
		MinipoolStatus currentStatus = MinipoolStatus(getUint(statusKey));
		bool isValid;

		if (currentStatus == MinipoolStatus.Initialised) {
			isValid = (to == MinipoolStatus.Prelaunch || to == MinipoolStatus.Canceled);
		} else if (currentStatus == MinipoolStatus.Prelaunch) {
			isValid = (to == MinipoolStatus.Staking || to == MinipoolStatus.Canceled);
		} else if (currentStatus == MinipoolStatus.Staking) {
			isValid = (to == MinipoolStatus.Withdrawable);
		} else if (currentStatus == MinipoolStatus.Withdrawable) {
			isValid = (to == MinipoolStatus.Finished);
		} else if (currentStatus == MinipoolStatus.Finished || currentStatus == MinipoolStatus.Canceled) {
			// Once a node is finished or canceled, if they re-validate they go back to beginning state
			isValid = (to == MinipoolStatus.Initialised);
		} else {
			isValid = false;
		}

		if (!isValid) {
			revert InvalidStateTransition();
		}
	}
}
