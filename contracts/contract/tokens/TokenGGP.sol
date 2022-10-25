// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;

import "../Base.sol";
import {Storage} from "../Storage.sol";
import {Vault} from "../Vault.sol";
import {ERC20, ERC20Burnable} from "./ERC20Burnable.sol";

import "../rewards/claims/ProtocolDAOClaim.sol";

// GGP Governance and utility token
// Inflationary with rate determined by DAO

contract TokenGGP is Base, ERC20Burnable {
	/**** Properties ***********/

	uint256 private constant TOTAL_INITIAL_SUPPLY = 22500000 ether;

	constructor(Storage storageAddress) Base(storageAddress) ERC20("GoGoPool Protocol", "GGP", 18) {
		version = 1;
		//TODO:shouldnt we mint this to the valut?
		_mint(msg.sender, TOTAL_INITIAL_SUPPLY);
	}
}
