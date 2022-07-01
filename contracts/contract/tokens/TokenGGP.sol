pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import {ERC20, ERC20Burnable} from "./ERC20Burnable.sol";
import {Vault} from "../Vault.sol";
import "../Base.sol";
import {Storage} from "../Storage.sol";

import "../rewards/claims/ProtocolDAOClaim.sol";

// GGP Governance and utility token
// Inflationary with rate determined by DAO

contract TokenGGP is Base, ERC20Burnable {
	/**** Properties ***********/

	uint256 private constant TOTAL_INITIAL_SUPPLY = 22500000 ether;
	// The GGP inflation interval
	uint256 private constant INFLATION_INTERVAL = 28 days;

	// Timestamp of last block inflation was calculated at
	uint256 private inflationCalcTime = 0;

	// setting namespace
	bytes32 private settingNamespace;

	/**** Events ***********/

	event GGPInflationLog(address sender, uint256 value, uint256 inflationCalcTime);
	event GGPFixedSupplyBurn(address indexed from, uint256 amount, uint256 time);
	event MintGGPToken(address _minter, address _address, uint256 _value);

	constructor(Storage storageAddress) Base(storageAddress) ERC20("GoGoPool Protocol", "GGP", 18) {
		version = 1;
		settingNamespace = keccak256(abi.encodePacked("dao.protocol.setting.", "dao.protocol."));
		_mint(msg.sender, TOTAL_INITIAL_SUPPLY);
	}
}
