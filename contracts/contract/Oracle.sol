pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./Base.sol";
import {Storage} from "./Storage.sol";
import {IOneInch} from "../interface/IOneInch.sol";
import {TokenGGP} from "./tokens/TokenGGP.sol";

/*
	Data Storage Schema
	Oracle.oneinch = address of the One Inch price aggregator contract
	Oracle.ggp.timestamp = block.timestamp of last update to GGP price
	Oracle.ggp.price = price of GGP **IN AVAX UNITS**
*/

contract Oracle is Base {
	error InvalidGGPPrice();
	error InvalidOrDisabledMultisig();
	error InvalidTimestamp();

	event GGPPriceUpdated(uint256 indexed price);

	constructor(Storage storageAddress) Base(storageAddress) {
		version = 1;
		// TODO initialize the price here?
	}

	// Set the address of the One Inch price aggregator contract
	function setOneInch(address addr) public onlyGuardian {
		setAddress("Oracle.OneInch", addr);
	}

	// Get an aggregated price from the 1Inch contract.
	// NEVER call this on-chain, only rialto should call, then
	// send a setGGPPrice tx
	function getGGPPriceFromOneInch() public view returns (uint256 price, uint256 timestamp) {
		TokenGGP ggp = TokenGGP(getContractAddress("TokenGGP"));
		address addr = getAddress("Oracle.OneInch");
		IOneInch oneinch = IOneInch(addr);
		price = oneinch.getRateToEth(ggp, false);
		timestamp = block.timestamp;
	}

	function getGGPPrice() external view returns (uint256 price, uint256 timestamp) {
		price = getUint(keccak256("Oracle.GGPPrice"));
		if (price == 0) {
			revert InvalidGGPPrice();
		}
		timestamp = getUint(keccak256("Oracle.GGPTimestamp"));
	}

	function setGGPPrice(uint256 price, uint256 timestamp) external onlyMultisig {
		uint256 lastTimestamp = getUint(keccak256("Oracle.GGPTimestamp"));
		if (timestamp < lastTimestamp || timestamp > block.timestamp) {
			revert InvalidTimestamp();
		}
		if (price == 0) {
			revert InvalidGGPPrice();
		}
		setUint(keccak256("Oracle.GGPPrice"), price);
		setUint(keccak256("Oracle.GGPTimestamp"), timestamp);
		emit GGPPriceUpdated(price);
	}
}
