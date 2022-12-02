// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.17;

import "./Base.sol";
import {IWithdrawer} from "../interface/IWithdrawer.sol";
import {Storage} from "./Storage.sol";

import {ERC20} from "@rari-capital/solmate/src/tokens/ERC20.sol";
import {ReentrancyGuard} from "@rari-capital/solmate/src/utils/ReentrancyGuard.sol";
import {SafeTransferLib} from "@rari-capital/solmate/src/utils/SafeTransferLib.sol";

// !!!WARNING!!! The Vault contract must not be upgraded
// AVAX and ggAVAX are stored here to prevent contract upgrades from affecting balances
// based on RocketVault by RocketPool

/// @notice Vault and ledger for AVAX and tokens
contract Vault is Base, ReentrancyGuard {
	using SafeTransferLib for ERC20;
	using SafeTransferLib for address;

	error InsufficientContractBalance();
	error InvalidAmount();
	error InvalidNetworkContract();
	error TokenTransferFailed();
	error VaultTokenWithdrawalFailed();

	event AVAXDeposited(string indexed by, uint256 amount);
	event AVAXTransfer(string indexed from, string indexed to, uint256 amount);
	event AVAXWithdrawn(string indexed by, uint256 amount);
	event TokenDeposited(bytes32 indexed by, address indexed tokenAddress, uint256 amount);
	event TokenTransfer(bytes32 indexed by, bytes32 indexed to, address indexed tokenAddress, uint256 amount);
	event TokenWithdrawn(bytes32 indexed by, address indexed tokenAddress, uint256 amount);

	mapping(string => uint256) private avaxBalances;
	mapping(bytes32 => uint256) private tokenBalances;

	constructor(Storage storageAddress) Base(storageAddress) {
		version = 1;
	}

	/// @notice Accept an AVAX deposit from a network contract
	function depositAVAX() external payable onlyRegisteredNetworkContract {
		// Valid Amount?
		if (msg.value == 0) {
			revert InvalidAmount();
		}
		// Get contract name
		string memory contractName = getContractName(msg.sender);
		// Emit deposit event
		emit AVAXDeposited(contractName, msg.value);
		// Update balances
		avaxBalances[contractName] = avaxBalances[contractName] + msg.value;
	}

	/// @notice Withdraw an amount of AVAX to a network contract
	/// @param amount Amount of AVAX to be withdrawn
	function withdrawAVAX(uint256 amount) external onlyRegisteredNetworkContract nonReentrant {
		// Valid Amount?
		if (amount == 0) {
			revert InvalidAmount();
		}
		// Get the contract name the call is coming from
		string memory contractName = getContractName(msg.sender);
		// Emit the withdrawl event for that contract
		emit AVAXWithdrawn(contractName, amount);
		// Verify there are enough funds
		if (avaxBalances[contractName] < amount) {
			revert InsufficientContractBalance();
		}
		// Update balance
		avaxBalances[contractName] = avaxBalances[contractName] - amount;
		IWithdrawer withdrawer = IWithdrawer(msg.sender);
		withdrawer.receiveWithdrawalAVAX{value: amount}();
	}

	/// @notice Transfer AVAX from one contract to another
	/// @dev No funds actually move, just bookeeping
	/// @param toContractName Name of the contract fucns are being transferred to
	/// @param amount How many AVAX to be transferred
	function transferAVAX(string memory toContractName, uint256 amount) external onlyRegisteredNetworkContract {
		// Valid Amount?
		if (amount == 0) {
			revert InvalidAmount();
		}
		// Make sure the contract is valid, will revert if not
		getContractAddress(toContractName);
		string memory fromContractName = getContractName(msg.sender);
		// Emit transfer event
		emit AVAXTransfer(fromContractName, toContractName, amount);
		// Verify there are enough funds
		if (avaxBalances[fromContractName] < amount) {
			revert InsufficientContractBalance();
		}
		// Update balances
		avaxBalances[fromContractName] = avaxBalances[fromContractName] - amount;
		avaxBalances[toContractName] = avaxBalances[toContractName] + amount;
	}

	/// @notice Accept a token deposit and assign its balance to a network contract
	/// @dev (saves a large amount of gas this way through not needing a double token transfer via a network contract first)
	/// @param networkContractName Name of the contract that the token will be assigned to
	/// @param tokenContract The contract of the token being deposited
	/// @param amount How many tokens being deposited
	function depositToken(
		string memory networkContractName,
		ERC20 tokenContract,
		uint256 amount
	) external guardianOrRegisteredContract {
		// Valid Amount?
		if (amount == 0) {
			revert InvalidAmount();
		}
		// Make sure the network contract is valid (will revert if not)
		getContractAddress(networkContractName);
		// Get contract key
		bytes32 contractKey = keccak256(abi.encodePacked(networkContractName, address(tokenContract)));
		// Emit token transfer event
		emit TokenDeposited(contractKey, address(tokenContract), amount);
		// Send tokens to this address now, safeTransfer will revert if it fails
		tokenContract.safeTransferFrom(msg.sender, address(this), amount);
		// Update balances
		tokenBalances[contractKey] = tokenBalances[contractKey] + amount;
	}

	/// @notice Withdraw an amount of a ERC20 token to an address
	/// @param withdrawalAddress Address that will recieve the token
	/// @param tokenAddress ERC20 token
	/// @param amount Number of tokens to be withdrawn
	function withdrawToken(
		address withdrawalAddress,
		ERC20 tokenAddress,
		uint256 amount
	) external onlyRegisteredNetworkContract nonReentrant {
		// Valid Amount?
		if (amount == 0) {
			revert InvalidAmount();
		}
		// Get contract key
		bytes32 contractKey = keccak256(abi.encodePacked(getContractName(msg.sender), tokenAddress));
		// Emit token withdrawn event
		emit TokenWithdrawn(contractKey, address(tokenAddress), amount);
		// Verify there are enough funds
		if (tokenBalances[contractKey] < amount) {
			revert InsufficientContractBalance();
		}
		// Update balances
		tokenBalances[contractKey] = tokenBalances[contractKey] - amount;
		// Get the toke ERC20 instance
		ERC20 tokenContract = ERC20(tokenAddress);
		// Withdraw to the withdrawal address, , safeTransfer will revert if it fails
		tokenContract.safeTransfer(withdrawalAddress, amount);
	}

	/// @notice Transfer token from one contract to another
	/// @param networkContractName Name of the contract that the token will be transferred to
	/// @param tokenAddress ERC20 token
	/// @param amount Number of tokens to be withdrawn
	function transferToken(
		string memory networkContractName,
		ERC20 tokenAddress,
		uint256 amount
	) external onlyRegisteredNetworkContract {
		// Valid Amount?
		if (amount == 0) {
			revert InvalidAmount();
		}
		// Make sure the network contract is valid (will revert if not)
		getContractAddress(networkContractName);
		// Get contract keys
		bytes32 contractKeyFrom = keccak256(abi.encodePacked(getContractName(msg.sender), tokenAddress));
		bytes32 contractKeyTo = keccak256(abi.encodePacked(networkContractName, tokenAddress));
		// emit token transfer event
		emit TokenTransfer(contractKeyFrom, contractKeyTo, address(tokenAddress), amount);
		// Verify there are enough funds
		if (tokenBalances[contractKeyFrom] < amount) {
			revert InsufficientContractBalance();
		}
		// Update Balances
		tokenBalances[contractKeyFrom] = tokenBalances[contractKeyFrom] - amount;
		tokenBalances[contractKeyTo] = tokenBalances[contractKeyTo] + amount;
	}

	/// @notice Get the AVAX balance held by a network contract
	/// @param networkContractName Name of the contract who's AVAX balance is being requested
	function balanceOf(string memory networkContractName) external view returns (uint256) {
		return avaxBalances[networkContractName];
	}

	/// @notice Get the balance of a token held by a network contract
	/// @param networkContractName Name of the contract who's token balance is being requested
	/// @param tokenAddress address of the ERC20 token
	function balanceOfToken(string memory networkContractName, ERC20 tokenAddress) external view returns (uint256) {
		return tokenBalances[keccak256(abi.encodePacked(networkContractName, tokenAddress))];
	}
}
