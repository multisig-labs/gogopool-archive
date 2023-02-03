// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.17;

import "../BaseAbstract.sol";
import {ERC20} from "@rari-capital/solmate/src/tokens/ERC20.sol";

// GGP Governance and Utility Token
// Inflationary with rate determined by DAO

contract TokenGGP is ERC20, BaseAbstract {
	uint256 private constant INITIAL_SUPPLY = 18_000_000 ether;
	uint256 private constant MAX_SUPPLY = 22_500_000 ether;

	error MaximumTokensReached();

	constructor() ERC20("GoGoPool Protocol", "GGP", 18) {
		_mint(msg.sender, INITIAL_SUPPLY);
	}

	function mint(address to, uint256 amount) external onlySpecificRegisteredContract("RewardsPool", msg.sender) {
		if (totalSupply + amount > MAX_SUPPLY) {
			revert MaximumTokensReached();
		}
		_mint(to, amount);
	}
}
