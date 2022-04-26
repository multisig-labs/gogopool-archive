// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

interface IProtocolDAO {
	function initialize() external;

	function getInflationIntervalRate() external view returns (uint256);

	function getInflationIntervalStartTime() external view returns (uint256);
}
