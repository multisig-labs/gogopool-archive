// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.17;

import {Storage} from "../Storage.sol";
import {ERC20} from "@rari-capital/solmate/src/tokens/ERC20.sol";

// GGP Governance and Utility Token
// Inflationary with rate determined by DAO

contract TokenGGP is ERC20 {
	uint256 private constant INITIAL_SUPPLY = 18_000_000 ether;
	uint256 private constant MAX_SUPPLY = 22_500_000 ether;

	error MaximumTokensReached();
	error InvalidOrOutdatedContract();

	Storage internal gogoStorage;

	constructor(Storage storageAddress) ERC20("GoGoPool Protocol", "GGP", 18) {
		gogoStorage = Storage(storageAddress);
		_mint(msg.sender, INITIAL_SUPPLY);
	}

	function mint(uint256 amount) external {
		if (msg.sender != gogoStorage.getAddress(keccak256(abi.encodePacked("contract.address", "RewardsPool")))) {
			revert InvalidOrOutdatedContract();
		}

		if (totalSupply + amount > MAX_SUPPLY) {
			revert MaximumTokensReached();
		}
		_mint(msg.sender, amount);
	}
}
