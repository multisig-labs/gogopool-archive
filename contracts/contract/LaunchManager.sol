pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import {ILaunchManager} from "../interface/ILaunchManager.sol";
import {IMinipoolQueue} from "../interface/IMinipoolQueue.sol";
import {IStorage} from "../interface/IStorage.sol";
import {IVault} from "../interface/IVault.sol";
import {MinipoolStatus} from "../types/MinipoolStatus.sol";
import {Base} from "./Base.sol";

contract LaunchManager is Base, ILaunchManager {
	constructor(IStorage storageAddress) Base(storageAddress) {
		version = 1;
	}

	function assignDeposits() external {
		// Whatever checks we need
		// Mint ggAVAX to user
		// RocketTokenRETHInterface rocketTokenRETH = RocketTokenRETHInterface(getContractAddress("rocketTokenRETH"));
		// rocketTokenRETH.mint(msg.value, msg.sender);
		// // Emit deposit received event
		// emit DepositReceived(msg.sender, msg.value, block.timestamp);
		// rocketVault.depositEther{value: msg.value}();
		// assign deposits
	}

	// Get nodes ready for Rialto to process (limit=0 means get everything)
	function getPrelaunchMinipools(uint256 offset, uint256 limit) external view returns (Node[] memory nodes) {
		address nodeID;
		uint256 status;
		uint256 duration;
		uint256 delegationFee;

		uint256 totalMinipools = getUint(keccak256("minipool.count"));
		uint256 max = offset + limit;
		if (max > totalMinipools || limit == 0) {
			max = totalMinipools;
		}
		nodes = new Node[](max - offset);
		uint256 total = 0;
		for (uint256 i = offset; i < max; i++) {
			(nodeID, status, duration, delegationFee) = getMinipool(i);
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

	// Get the number of minipools in each status.
	function getMinipoolCountPerStatus(uint256 offset, uint256 limit)
		external
		view
		returns (
			uint256 initialisedCount,
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
			uint256 status;
			// Get the minipool at index i
			(, status, , ) = getMinipool(i);
			// Get the minipool's status, and update the appropriate counter
			if (status == uint256(MinipoolStatus.Initialised)) {
				initialisedCount++;
			} else if (status == uint256(MinipoolStatus.Prelaunch)) {
				prelaunchCount++;
			} else if (status == uint256(MinipoolStatus.Launched)) {
				launchedCount++;
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

	// TODO Maybe stuff like the below goes in a library

	// The index of an item
	// Returns -1 if the value is not found
	function getIndexOf(address nodeID) public view returns (int256) {
		return int256(getUint(keccak256(abi.encodePacked("minipool.index", nodeID)))) - 1;
	}

	function getMinipool(uint256 index)
		public
		view
		returns (
			address nodeID,
			uint256 status,
			uint256 duration,
			uint256 delegationFee
		)
	{
		nodeID = getAddress(keccak256(abi.encodePacked("minipool.item", index, ".nodeID")));
		status = getUint(keccak256(abi.encodePacked("minipool.item", index, ".status")));
		duration = getUint(keccak256(abi.encodePacked("minipool.item", index, ".duration")));
		delegationFee = getUint(keccak256(abi.encodePacked("minipool.item", index, ".delegationFee")));
	}
}
