pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./Base.sol";
import "../interface/IStorage.sol";
import "../interface/IMinipoolManager.sol";
import "../interface/IMultisigManager.sol";
// TODO might be gotchas here? https://hackernoon.com/beware-the-solidity-enums-9v1qa31b2
import "../types/MinipoolStatus.sol";

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
	minipool.item<index>.withdrawalAddr = an allowed withdrawalAddress (overrides owner if set?)
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

contract MinipoolManager is Base, IMinipoolManager {
	// Used for signature verifying of Rialto multisig to prevent replay attacks
	mapping(address => uint256) private _nonces;

	constructor(IStorage _storageAddress) Base(_storageAddress) {
		version = 1;
	}

	function registerMinipool(address _nodeID, uint256 _duration) external {
		// TODO check for max node count from dao

		// If nodeID exists, only allow overwriting if node is finished or canceled
		// (completed its validation period and all rewards paid and processing is complete)
		int256 index = getIndexOf(_nodeID);
		if (index != -1) {
			requireValidStateTransition(index, MinipoolStatus.Initialised);
		}

		// Get a Rialto multisig to assign for this minipool
		IMultisigManager multisigManager = IMultisigManager(getContractAddress("MultisigManager"));
		address multisig = multisigManager.getNextActiveMultisig();

		uint256 count = getUint(keccak256("minipool.count"));
		// Save the attrs individually in the k/v store
		setAddress(keccak256(abi.encodePacked("minipool.item", count, ".nodeID")), _nodeID);
		setUint(keccak256(abi.encodePacked("minipool.item", count, ".status")), uint256(MinipoolStatus.Initialised));
		setUint(keccak256(abi.encodePacked("minipool.item", count, ".duration")), _duration);
		setAddress(keccak256(abi.encodePacked("minipool.item", count, ".multisigAddr")), multisig);
		setAddress(keccak256(abi.encodePacked("minipool.item", count, ".owner")), msg.sender);

		// NOTE the index is actually 1 more than where it is actually stored. The 1 is subtracted in getIndexOf().
		// Copied from RP, probably so they can use "-1" to signify that something doesnt exist
		setUint(keccak256(abi.encodePacked("minipool.index", _nodeID)), count + 1);
		addUint(keccak256("minipool.count"), 1);
		emit RegisteredMinipool(_nodeID);
	}

	// TODO This forces minipool into a state. Do we need this? For tests?
	function updateMinipoolStatus(address _nodeID, MinipoolStatus status) external {
		int256 index = getIndexOf(_nodeID);
		if (index == -1) {
			revert MinipoolNotFound();
		}
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".status")), uint256(status));
	}

	//
	// RIALTO FUNCTIONS
	//

	// Owner of a node can call this to cancel the minipool
	function cancelMinipool(address _nodeID) external {
		int256 index = getIndexOf(_nodeID);
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
	function cancelMinipool(address _nodeID, bytes memory _sig) external {
		int256 index = requireValidMultisig(_nodeID, _sig);
		_cancelMinipoolAndReturnFunds(index);
	}

	function _cancelMinipoolAndReturnFunds(int256 _index) private {
		requireValidStateTransition(_index, MinipoolStatus.Canceled);
		setUint(keccak256(abi.encodePacked("minipool.item", _index, ".status")), uint256(MinipoolStatus.Canceled));
		// TODO return funds
	}

	// If correct multisig calls this, xfer funds from vault to their address
	function claimAndInitiateStaking(address _nodeID, bytes memory _sig) external {
		requireValidMultisig(_nodeID, _sig);
		// TODO xfer funds
	}

	// Rialto calls this after a successful minipool launch
	function recordStakingStart(
		address _nodeID,
		bytes memory _sig,
		uint256 _startTime
	) external {
		int256 index = requireValidMultisig(_nodeID, _sig);
		requireValidStateTransition(index, MinipoolStatus.Staking);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".status")), uint256(MinipoolStatus.Staking));
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".startTime")), _startTime);
		// emit StakingStartEvent
	}

	// Rialto calls this when validation period ends
	// Rialto will also xfer back all avax + avax rewards to vault
	// TODO is this payable then? accept all funds here and distribute?
	function recordStakingEnd(
		address _nodeID,
		bytes memory _sig,
		uint256 _endTime,
		uint256 _avaxRewardAmt
	) external {
		int256 index = requireValidMultisig(_nodeID, _sig);
		requireValidStateTransition(index, MinipoolStatus.Withdrawable);
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".status")), uint256(MinipoolStatus.Withdrawable));

		uint256 startTime = getUint(keccak256(abi.encodePacked("minipool.item", index, ".startTime")));
		if (_endTime <= startTime) {
			revert InvalidEndTime();
		}
		setUint(keccak256(abi.encodePacked("minipool.item", index, ".endTime")), _endTime);

		setUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxRewardAmt")), _avaxRewardAmt);
		// emit StakingEndEvent
	}

	// Get the number of minipools in each status.
	function getMinipoolCountPerStatus(uint256 offset, uint256 limit)
		external
		view
		returns (
			uint256 initialisedCount,
			uint256 prelaunchCount,
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
			uint256 status;
			// Get the minipool at index i
			(, status, ) = getMinipool(i);
			// Get the minipool's status, and update the appropriate counter
			if (status == uint256(MinipoolStatus.Initialised)) {
				initialisedCount++;
			} else if (status == uint256(MinipoolStatus.Prelaunch)) {
				prelaunchCount++;
			} else if (status == uint256(MinipoolStatus.Staking)) {
				stakingCount++;
			} else if (status == uint256(MinipoolStatus.Withdrawable)) {
				withdrawableCount++;
			} else if (status == uint256(MinipoolStatus.Finished)) {
				finishedCount++;
			} else if (status == uint256(MinipoolStatus.Canceled)) {
				canceledCount++;
			}
		}
	}

	// Get nodes ready for Rialto to process (limit=0 means get everything)
	function getPrelaunchMinipools(uint256 offset, uint256 limit) external view returns (Node[] memory nodes) {
		address nodeID;
		uint256 status;
		uint256 duration;

		uint256 totalMinipools = getUint(keccak256("minipool.count"));
		uint256 max = offset + limit;
		if (max > totalMinipools || limit == 0) {
			max = totalMinipools;
		}
		nodes = new Node[](max - offset);
		uint256 total = 0;
		for (uint256 i = offset; i < max; i++) {
			(nodeID, status, duration) = getMinipool(i);
			if (status == uint256(MinipoolStatus.Prelaunch)) {
				nodes[total] = Node(nodeID, duration);
				total++;
			}
		}
		// Dirty hack to cut unused elements off end of return value (from RP)
		// solhint-disable-next-line no-inline-assembly
		assembly {
			mstore(nodes, total)
		}
	}

	// The index of an item
	// Returns -1 if the value is not found
	function getIndexOf(address _nodeID) public view returns (int256) {
		return int256(getUint(keccak256(abi.encodePacked("minipool.index", _nodeID)))) - 1;
	}

	function getNonce(address _signer) public view returns (uint256) {
		return _nonces[_signer];
	}

	function getMinipool(uint256 _index)
		public
		view
		returns (
			address nodeID,
			uint256 status,
			uint256 duration
		)
	{
		nodeID = getAddress(keccak256(abi.encodePacked("minipool.item", _index, ".nodeID")));
		status = getUint(keccak256(abi.encodePacked("minipool.item", _index, ".status")));
		duration = getUint(keccak256(abi.encodePacked("minipool.item", _index, ".duration")));
	}

	// Given a signer addr, return the hash that should be signed to claim a nodeID
	// SECURITY the client should not depend on this func to know what to sign, they should always do it themselves
	function formatClaimMessageHash(address _signer) private view returns (bytes32) {
		return ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(this, _signer, _nonces[_signer])));
	}

	// Verify that _signer is an enabled multisig, and signature is valid for current nonce value, and bump nonce
	function requireValidSigAndUpdateNonce(address _signer, bytes memory _sig) private {
		bytes32 msgHash = formatClaimMessageHash(_signer);
		_nonces[_signer] += 1;
		IMultisigManager multisigManager = IMultisigManager(getContractAddress("MultisigManager"));
		multisigManager.requireValidSignature(_signer, msgHash, _sig);
	}

	function requireValidMultisig(address _nodeID, bytes memory _sig) private returns (int256) {
		int256 index = getIndexOf(_nodeID);
		if (index == -1) {
			revert MinipoolNotFound();
		}

		address assignedMultisig = getAddress(keccak256(abi.encodePacked("minipool.item", index, ".multisigAddr")));
		if (msg.sender != assignedMultisig) {
			revert InvalidMultisigAddress();
		}
		requireValidSigAndUpdateNonce(assignedMultisig, _sig);
		return index;
	}

	function requireValidStateTransition(int256 _index, MinipoolStatus _to) private view {
		bytes32 statusKey = keccak256(abi.encodePacked("minipool.item", _index, ".status"));
		MinipoolStatus currentStatus = MinipoolStatus(getUint(statusKey));
		bool isValid;

		if (currentStatus == MinipoolStatus.Initialised) {
			isValid = (_to == MinipoolStatus.Prelaunch || _to == MinipoolStatus.Canceled);
		} else if (currentStatus == MinipoolStatus.Prelaunch) {
			isValid = (_to == MinipoolStatus.Staking || _to == MinipoolStatus.Canceled);
		} else if (currentStatus == MinipoolStatus.Staking) {
			isValid = (_to == MinipoolStatus.Withdrawable);
		} else if (currentStatus == MinipoolStatus.Withdrawable) {
			isValid = (_to == MinipoolStatus.Finished);
		} else if (currentStatus == MinipoolStatus.Finished || currentStatus == MinipoolStatus.Canceled) {
			// Once a node is finished or cancelled, if they re-validate they go back to beginning state
			isValid = (_to == MinipoolStatus.Initialised);
		} else {
			isValid = false;
		}

		if (!isValid) {
			revert InvalidStateTransition();
		}
	}
}
