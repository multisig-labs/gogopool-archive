pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

interface IWAVAX {
	function deposit() external payable;

	function transfer(address to, uint256 value) external returns (bool);

	function approve(address spender, uint256 amount) external returns (bool);

	function transferFrom(
		address from,
		address to,
		uint256 amount
	) external returns (bool);

	function balanceOf(address owner) external view returns (uint256);

	function withdraw(uint256) external;
}
