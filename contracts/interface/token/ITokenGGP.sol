// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITokenGGP is IERC20 {
	function getInflationCalcTime() external view returns (uint256);

	function getInflationIntervalTime() external pure returns (uint256);

	function getInflationIntervalRate() external view returns (uint256);

	function getInflationIntervalsPassed() external view returns (uint256);

	function getInflationIntervalStartTime() external view returns (uint256);

	function getInflationRewardsContractAddress() external view returns (address);

	function inflationCalculate() external view returns (uint256);

	function inflationMintTokens() external returns (uint256);
}
