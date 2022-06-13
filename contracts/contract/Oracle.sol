pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import {Storage} from "./Storage.sol";
import "./Base.sol";

/*
	Data Storage Schema
	oracle.ggp.timestamp = block.timestamp of last update to GGP price
	oracle.ggp.price = price of GGP **IN AVAX UNITS**
*/

contract Oracle is Base {
	/// @notice Multisig has not been registered or has been disabled
	error InvalidMultisigDisabled();

	/// @notice Oracle-supplied price of GGP is not set or is zero
	error InvalidGGPPrice();

	error InvalidTimestamp();

	// Events
	event GGPPriceUpdated(uint256 indexed price);

	constructor(IStorage storageAddress) Base(storageAddress) {
		version = 1;
	}

	// TODO modifiers for who can call all these functions (registered/enabled multisigs)
	function getGGP() external view returns (uint256 price, uint256 timestamp) {
		price = getUint(keccak256("oracle.ggp.price"));
		if (price == 0) {
			revert InvalidGGPPrice();
		}
		timestamp = getUint(keccak256("oracle.ggp.timestamp"));
	}

	function setGGP(uint256 price, uint256 timestamp) external {
		uint256 lastTimestamp = getUint(keccak256("oracle.ggp.timestamp"));
		if (timestamp < lastTimestamp || timestamp > block.timestamp) {
			revert InvalidTimestamp();
		}
		if (price == 0) {
			revert InvalidGGPPrice();
		}
		setUint(keccak256("oracle.ggp.price"), price);
		setUint(keccak256("oracle.ggp.timestamp"), timestamp);
		emit GGPPriceUpdated(price);
	}
}
