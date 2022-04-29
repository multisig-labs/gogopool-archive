pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

interface IVault {
	function balanceOf(string memory _networkContractName) external view returns (uint256);

	function depositAvax() external payable;

	function withdrawAvax(uint256 _amount) external;

	function depositToken(
		string memory _networkContractName,
		IERC20 _tokenAddress,
		uint256 _amount
	) external;

	function withdrawToken(
		address _withdrawalAddress,
		IERC20 _tokenAddress,
		uint256 _amount
	) external;

	function balanceOfToken(string memory _networkContractName, IERC20 _tokenAddress) external view returns (uint256);

	function transferToken(
		string memory _networkContractName,
		IERC20 _tokenAddress,
		uint256 _amount
	) external;

	function burnToken(ERC20Burnable _tokenAddress, uint256 _amount) external;
}
