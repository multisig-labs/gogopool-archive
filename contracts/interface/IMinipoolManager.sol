pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "../types/MinipoolStatus.sol";

interface IMinipoolManager {
	// Not used to store any data, but as a struct to return from some funcs
	struct Node {
		address nodeID;
		uint256 duration;
	}

	function getIndexOf(address _nodeID) external view returns (int256);

	function getMinipool(uint256 _index)
		external
		view
		returns (
			address nodeID,
			uint256 status,
			uint256 duration
		);

	function addMinipool(address _nodeID, uint256 _duration) external;

	function cancelMinipool(address _nodeID) external;

	function updateMinipoolStatus(address _nodeID, MinipoolStatus status) external;

	function getPrelaunchMinipools(uint256 offset, uint256 limit) external view returns (Node[] memory nodes);

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
		);

}
