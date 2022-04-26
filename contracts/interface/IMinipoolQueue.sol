pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

interface IMinipoolQueue {
	function enqueue(
		bytes32 nodeID,
		uint256 duration,
		address owner
	) external;

	// function getCapacity() external view returns (uint256);
	// function dequeue() external returns (bytes32 minipoolID);
	// function getLength() external view returns (uint256);
}
