pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OneInchMock {
	constructor() {}

	function getRateToEth(IERC20 srcToken, bool useSrcWrappers) external view returns (uint256 weightedRate) {
		weightedRate = 1.1 ether;
	}
}
