pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import {Storage} from "./Storage.sol";
import {IOneInch} from "../interface/IOneInch.sol";
import {TokenGGP} from "./tokens/TokenGGP.sol";
import "./Base.sol";

/*
	Data Storage Schema
	oracle.ggp.oneinch = address of the One Inch price aggregator contract
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

	// Set the address of the One Inch price aggregator contract
	// TODO security, only guardian/DAO should be able to do this
	function setOneInch(address addr) public {
		setAddress("oracle.ggp.oneinch", addr);
	}

	// Get an aggregated price from the 1Inch contract.
	// NEVER call this on-chain, only rialto should call, then
	// send a setGGPPrice tx
	function getGGPPriceFromOneInch() public view returns (uint256 price, uint256 timestamp) {
		TokenGGP ggp = TokenGGP(getContractAddress("TokenGGP"));
		address addr = getAddress("oracle.ggp.oneinch");
		IOneInch oneinch = IOneInch(addr);
		price = oneinch.getRateToEth(ggp, false);
		timestamp = block.timestamp;
	}

	// TODO modifiers for who can call all these functions (registered/enabled multisigs)
	function getGGPPrice() external view returns (uint256 price, uint256 timestamp) {
		price = getUint(keccak256("oracle.ggp.price"));
		if (price == 0) {
			revert InvalidGGPPrice();
		}
		timestamp = getUint(keccak256("oracle.ggp.timestamp"));
	}

	function setGGPPrice(uint256 price, uint256 timestamp) external {
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
