pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

interface IDepositManager {
	event DepositReceived(address indexed from, uint256 amount);

	/**
		@notice Main entry point for liquid stakers to deposit AVAX
	 */
	function deposit() external payable;

	/**
		@notice Used to enforce a minimum hold time for users
	 */
	function getUserLastDepositTime(address addr) external view returns (uint256);
}
