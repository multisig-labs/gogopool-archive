pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "@rari-capital/solmate/src/tokens/ERC20.sol";

interface IOneInch {
	function getRateToEth(ERC20 srcToken, bool useSrcWrappers) external view returns (uint256 weightedRate);
}
