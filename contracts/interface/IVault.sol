pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import {ERC20, ERC20Burnable} from "../contract/tokens/ERC20Burnable.sol";

interface IVault {
	/// @notice amount was not valid
	error InvalidAmount();

	/// @notice Insufficient contract balance
	error InsufficientContractBalance();

	/// @notice not a valid network contract
	error InvalidNetworkContract();

	/// @notice token transfer failed
	error TokenTransferFailed();

	/// @notice Vault token withdrawal failed
	error VaultTokenWithdrawalFailed();

	function depositAvax() external payable;

	function withdrawAvax(uint256 amount) external;

	function depositToken(
		string memory networkContractName,
		ERC20 tokenAddress,
		uint256 amount
	) external;

	function transferToken(
		string memory networkContractName,
		ERC20 tokenAddress,
		uint256 amount
	) external;

	function withdrawToken(
		address withdrawalAddress,
		ERC20 tokenAddress,
		uint256 amount
	) external;

	function burnToken(ERC20Burnable tokenAddress, uint256 amount) external;

	function balanceOf(string memory networkContractName) external view returns (uint256);

	function balanceOfToken(string memory networkContractName, ERC20 tokenAddress) external view returns (uint256);
}
