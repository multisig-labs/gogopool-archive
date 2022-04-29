pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

interface ILaunchManager {
	// Not used to store any data, but as a struct to return data from view functions
	struct Node {
		address nodeID;
		uint256 duration;
	}

	/**
		@notice Matches AVAX from depositors with minipools, and changes the minipool
		        status to Prelaunch for Rialto to pick up.
						Called from IMinipoolManager.CreateMinipool() and IDepositManager.deposit()
		@dev If the logic in here gets expensive, then we could have Rialto call it instead
	 */
	function assignDeposits() external;

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
