// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

// [GGP] Switching this to use Rari ERC20
// [GGP] Vault.sol doesnt use burnFrom so skip implementing it for now

pragma solidity 0.8.17;

import "@rari-capital/solmate/src/tokens/ERC20.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is ERC20 {
	/**
	 * @dev Destroys `amount` tokens from the caller.
	 *
	 * See {ERC20-_burn}.
	 */
	function burn(uint256 amount) public virtual {
		_burn(msg.sender, amount);
	}

	/**
	 * @dev Destroys `amount` tokens from `account`, deducting from the caller's
	 * allowance.
	 *
	 * See {ERC20-_burn} and {ERC20-allowance}.
	 *
	 * Requirements:
	 *
	 * - the caller must have allowance for ``accounts``'s tokens of at least
	 * `amount`.
	 */
	// function burnFrom(address account, uint256 amount) public virtual {
	// 	_spendAllowance(account, msg.sender, amount);
	// 	_burn(account, amount);
	// }
}
