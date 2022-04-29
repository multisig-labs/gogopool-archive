pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

interface IMinipoolQueue {
	/// @notice Add nodeID to the queue
	// We only store the nodeID, the rest of the data is in the minipool data structure.
	function enqueue(bytes32 nodeID) external;

	// Pop nodeID off the queue. The logic for which nodeID gets selected could include GGP bond, etc.
	function dequeue() external returns (bytes32 nodeID);
}
