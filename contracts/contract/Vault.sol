// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;

import "./Base.sol";
import {ERC20, ERC20Burnable} from "./tokens/ERC20Burnable.sol";
import {IWithdrawer} from "../interface/IWithdrawer.sol";
import {Storage} from "./Storage.sol";

// !!!WARNING!!! The Vault contract must not be upgraded
// AVAX and ggAVAX are stored here to prevent contract upgrades from affecting balances
// based on RocketVault by RocketPool

contract Vault is Base {
	error InsufficientContractBalance();
	error InvalidAmount();
	error InvalidNetworkContract();
	error TokenTransferFailed();
	error VaultTokenWithdrawalFailed();

	event AVAXDeposited(string indexed by, uint256 amount);
	event AVAXTransfer(string indexed from, string indexed to, uint256 amount);
	event AVAXWithdrawn(string indexed by, uint256 amount);
	event TokenBurned(bytes32 indexed by, address indexed tokenAddress, uint256 amount);
	event TokenDeposited(bytes32 indexed by, address indexed tokenAddress, uint256 amount);
	event TokenTransfer(bytes32 indexed by, bytes32 indexed to, address indexed tokenAddress, uint256 amount);
	event TokenWithdrawn(bytes32 indexed by, address indexed tokenAddress, uint256 amount);

	mapping(string => uint256) private avaxBalances;
	mapping(bytes32 => uint256) private tokenBalances;

	// Construct
	constructor(Storage storageAddress) Base(storageAddress) {
		version = 1;
	}

	// Accept an AVAX deposit from a network contract
	function depositAVAX() external payable onlyLatestNetworkContract {
		// Valid amount?
		if (msg.value == 0) {
			revert InvalidAmount();
		}

		string memory contractName = getContractName(msg.sender);

		emit AVAXDeposited(contractName, msg.value);

		avaxBalances[contractName] = avaxBalances[contractName] + msg.value;
	}

	// Withdraw an amount of AVAX to a network contract
	function withdrawAVAX(uint256 amount) external onlyLatestNetworkContract {
		if (amount == 0) {
			revert InvalidAmount();
		}

		string memory contractName = getContractName(msg.sender);

		emit AVAXWithdrawn(contractName, amount);

		if (avaxBalances[contractName] < amount) {
			revert InsufficientContractBalance();
		}
		avaxBalances[contractName] = avaxBalances[contractName] - amount;
		IWithdrawer withdrawer = IWithdrawer(msg.sender);
		withdrawer.receiveWithdrawalAVAX{value: amount}();
	}

	// Transfer AVAX from one contract to another
	// No funds actually move, just bookeeping
	function transferAVAX(
		string memory fromContractName,
		string memory toContractName,
		uint256 amount
	) external onlyLatestNetworkContract {
		if (amount == 0) {
			revert InvalidAmount();
		}

		emit AVAXTransfer(fromContractName, toContractName, amount);

		// Make sure the contracts are valid, will revert if not
		getContractAddress(fromContractName);
		getContractAddress(toContractName);

		avaxBalances[fromContractName] = avaxBalances[fromContractName] - amount;
		avaxBalances[toContractName] = avaxBalances[toContractName] + amount;
	}

	// Accept a token deposit and assign its balance to a network contract
	// (saves a large amount of gas this way through not needing a double token transfer via a network contract first)
	function depositToken(
		string memory networkContractName,
		ERC20 tokenContract,
		uint256 amount
	) external {
		if (amount == 0) {
			revert InvalidAmount();
		}
		// Make sure the network contract is valid (will revert if not)
		getContractAddress(networkContractName);
		bytes32 contractKey = keccak256(abi.encodePacked(networkContractName, address(tokenContract)));

		emit TokenDeposited(contractKey, address(tokenContract), amount);

		if (!tokenContract.transferFrom(msg.sender, address(this), amount)) {
			revert TokenTransferFailed();
		}
		tokenBalances[contractKey] = tokenBalances[contractKey] + amount;
	}

	// Withdraw an amount of a ERC20 token to an address
	function withdrawToken(
		address withdrawalAddress,
		ERC20 tokenAddress,
		uint256 amount
	) external onlyLatestNetworkContract {
		if (amount == 0) {
			revert InvalidAmount();
		}

		bytes32 contractKey = keccak256(abi.encodePacked(getContractName(msg.sender), tokenAddress));

		emit TokenWithdrawn(contractKey, address(tokenAddress), amount);

		tokenBalances[contractKey] = tokenBalances[contractKey] - amount;
		ERC20 tokenContract = ERC20(tokenAddress);
		if (!tokenContract.transfer(withdrawalAddress, amount)) {
			revert VaultTokenWithdrawalFailed();
		}
	}

	// Transfer token from one contract to another
	function transferToken(
		string memory networkContractName,
		ERC20 tokenAddress,
		uint256 amount
	) external onlyLatestNetworkContract {
		if (amount == 0) {
			revert InvalidAmount();
		}
		// Make sure the network contract is valid (will revert if not)
		getContractAddress(networkContractName);

		bytes32 contractKeyFrom = keccak256(abi.encodePacked(getContractName(msg.sender), tokenAddress));
		bytes32 contractKeyTo = keccak256(abi.encodePacked(networkContractName, tokenAddress));

		emit TokenTransfer(contractKeyFrom, contractKeyTo, address(tokenAddress), amount);

		tokenBalances[contractKeyFrom] = tokenBalances[contractKeyFrom] - amount;
		tokenBalances[contractKeyTo] = tokenBalances[contractKeyTo] + amount;
	}

	// Burns an amount of a token that implements a burn(uint256) method
	function burnToken(ERC20Burnable tokenAddress, uint256 amount) external onlyLatestNetworkContract {
		bytes32 contractKey = keccak256(abi.encodePacked(getContractName(msg.sender), tokenAddress));

		emit TokenBurned(contractKey, address(tokenAddress), amount);

		tokenBalances[contractKey] = tokenBalances[contractKey] - amount;
		ERC20Burnable tokenContract = ERC20Burnable(tokenAddress);
		tokenContract.burn(amount);
	}

	// Get a contract's AVAX balance by address
	function balanceOf(string memory networkContractName) external view returns (uint256) {
		return avaxBalances[networkContractName];
	}

	// Get the balance of a token held by a network contract
	function balanceOfToken(string memory networkContractName, ERC20 tokenAddress) external view returns (uint256) {
		return tokenBalances[keccak256(abi.encodePacked(networkContractName, tokenAddress))];
	}
}
