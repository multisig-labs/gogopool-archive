pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./Base.sol";
import {Storage} from "./Storage.sol";
import {ERC20, ERC20Burnable} from "./tokens/ERC20Burnable.sol";
import {IVault} from "../interface/IVault.sol";
import {IWithdrawer} from "../interface/IWithdrawer.sol";

// AVAX and ggAVAX are stored here to prevent contract upgrades from affecting balances
// The Vault contract must not be upgraded

/// @title AVAX Vault
/// @author Chandler
// based on RocketVault by RocketPool

contract Vault is Base, IVault {
	// Network contract balances
	mapping(string => uint256) private avaxBalances;
	mapping(bytes32 => uint256) private tokenBalances;

	// Events
	event AvaxDeposited(string indexed by, uint256 amount, uint256 time);
	event AvaxWithdrawn(string indexed by, uint256 amount, uint256 time);
	event AvaxTransfer(string indexed from, string indexed to, uint256 amount, uint256 time);
	event TokenDeposited(bytes32 indexed by, address indexed tokenAddress, uint256 amount, uint256 time);
	event TokenWithdrawn(bytes32 indexed by, address indexed tokenAddress, uint256 amount, uint256 time);
	event TokenBurned(bytes32 indexed by, address indexed tokenAddress, uint256 amount, uint256 time);
	event TokenTransfer(bytes32 indexed by, bytes32 indexed to, address indexed tokenAddress, uint256 amount, uint256 time);

	// Construct
	constructor(Storage storageAddress) Base(storageAddress) {
		version = 1;
	}

	// Accept an AVAX deposit from a network contract
	// Only accepts calls from GoGo Pool network contracts
	function depositAvax() external payable override onlyLatestNetworkContract {
		// Valid amount?
		if (msg.value == 0) {
			revert InvalidAmount();
		}
		// Get contract key
		string memory contractName = getContractName(msg.sender);
		// Update contract balance
		avaxBalances[contractName] = avaxBalances[contractName] + msg.value;
		// Emit ether deposited event
		emit AvaxDeposited(contractName, msg.value, block.timestamp);
	}

	// Withdraw an amount of AVAX to a network contract
	// Only accepts calls from GoGo Pool network contracts
	function withdrawAvax(uint256 _amount) external onlyLatestNetworkContract {
		// Valid amount?
		if (_amount == 0) {
			revert InvalidAmount();
		}
		// Get contract key
		string memory contractName = getContractName(msg.sender);
		// Check and update contract balance
		if (avaxBalances[contractName] < _amount) {
			revert InsufficientContractBalance();
		}
		avaxBalances[contractName] = avaxBalances[contractName] - _amount;
		// Withdraw
		IWithdrawer withdrawer = IWithdrawer(msg.sender);
		withdrawer.receiveWithdrawalAVAX{value: _amount}();
		// Emit ether withdrawn event
		emit AvaxWithdrawn(contractName, _amount, block.timestamp);
	}

	// Transfer AVAX from one contract to another
	// No funds actually move, just bookeeping
	// Only accepts calls from Rocket Pool network contracts
	function transferAvax(
		string memory fromContractName,
		string memory toContractName,
		uint256 amount
	) external onlyLatestNetworkContract {
		if (amount == 0) {
			revert InvalidAmount();
		}
		// Make sure the network contract is valid (will throw if not)
		if (getContractAddress(fromContractName) == address(0x0)) {
			revert InvalidNetworkContract();
		}
		if (getContractAddress(toContractName) == address(0x0)) {
			revert InvalidNetworkContract();
		}
		avaxBalances[fromContractName] = avaxBalances[fromContractName] - amount;
		avaxBalances[toContractName] = avaxBalances[toContractName] + amount;
		emit AvaxTransfer(fromContractName, toContractName, amount, block.timestamp);
	}

	// Accept an token deposit and assign its balance to a network contract (saves a large amount of gas this way through not needing a double token transfer via a network contract first)
	function depositToken(
		string memory _networkContractName,
		ERC20 _tokenContract,
		uint256 _amount
	) external {
		// Valid amount?
		if (_amount == 0) {
			revert InvalidAmount();
		}
		// Make sure the network contract is valid (will throw if not)
		if (getContractAddress(_networkContractName) == address(0x0)) {
			revert InvalidNetworkContract();
		}
		// Get contract key
		bytes32 contractKey = keccak256(abi.encodePacked(_networkContractName, address(_tokenContract)));
		// Send the tokens to this contract now

		if (!_tokenContract.transferFrom(msg.sender, address(this), _amount)) {
			revert TokenTransferFailed();
		}

		// Update contract balance
		tokenBalances[contractKey] = tokenBalances[contractKey] + _amount;
		// Emit token transfer
		emit TokenDeposited(contractKey, address(_tokenContract), _amount, block.timestamp);
	}

	// Withdraw an amount of a ERC20 token to an address
	// Only accepts calls from GoGoPool network contracts
	function withdrawToken(
		address _withdrawalAddress,
		ERC20 _tokenAddress,
		uint256 _amount
	) external onlyLatestNetworkContract {
		// Valid amount?
		if (_amount == 0) {
			revert InvalidAmount();
		}
		// Get contract key
		bytes32 contractKey = keccak256(abi.encodePacked(getContractName(msg.sender), _tokenAddress));
		// Update balances
		tokenBalances[contractKey] = tokenBalances[contractKey] - _amount;
		// Get the token ERC20 instance
		ERC20 tokenContract = ERC20(_tokenAddress);
		// Withdraw to the desired address
		if (!tokenContract.transfer(_withdrawalAddress, _amount)) {
			revert VaultTokenWithdrawalFailed();
		}
		// Emit token withdrawn event
		emit TokenWithdrawn(contractKey, address(_tokenAddress), _amount, block.timestamp);
	}

	// Transfer token from one contract to another
	// Only accepts calls from GoGoPool network contracts
	function transferToken(
		string memory _networkContractName,
		ERC20 _tokenAddress,
		uint256 _amount
	) external onlyLatestNetworkContract {
		// Valid amount?
		if (_amount == 0) {
			revert InvalidAmount();
		}
		// Make sure the network contract is valid (will throw if not)
		if (getContractAddress(_networkContractName) == address(0x0)) {
			revert InvalidNetworkContract();
		}
		// Get contract keys
		bytes32 contractKeyFrom = keccak256(abi.encodePacked(getContractName(msg.sender), _tokenAddress));
		bytes32 contractKeyTo = keccak256(abi.encodePacked(_networkContractName, _tokenAddress));
		// Update balances
		tokenBalances[contractKeyFrom] = tokenBalances[contractKeyFrom] - _amount;
		tokenBalances[contractKeyTo] = tokenBalances[contractKeyTo] + _amount;
		// Emit token withdrawn event
		emit TokenTransfer(contractKeyFrom, contractKeyTo, address(_tokenAddress), _amount, block.timestamp);
	}

	// Burns an amount of a token that implements a burn(uint256) method
	// Only accepts calls from network contracts
	// [GGP] The only place this is used in GGP is to fine node ops, and only GGPToken is burnable.
	function burnToken(ERC20Burnable _tokenAddress, uint256 _amount) external onlyLatestNetworkContract {
		// Get contract key
		bytes32 contractKey = keccak256(abi.encodePacked(getContractName(msg.sender), _tokenAddress));
		// Update balances
		tokenBalances[contractKey] = tokenBalances[contractKey] - _amount;
		// Get the token ERC20Burnable instance
		ERC20Burnable tokenContract = ERC20Burnable(_tokenAddress);
		// Burn the tokens
		tokenContract.burn(_amount);
		// Emit token burn event
		emit TokenBurned(contractKey, address(_tokenAddress), _amount, block.timestamp);
	}

	// Get a contract's AVAX balance by address
	function balanceOf(string memory _networkContractName) external view returns (uint256) {
		// Return balance
		return avaxBalances[_networkContractName];
	}

	// Get the balance of a token held by a network contract
	function balanceOfToken(string memory _networkContractName, ERC20 _tokenAddress) external view returns (uint256) {
		// Return balance
		return tokenBalances[keccak256(abi.encodePacked(_networkContractName, _tokenAddress))];
	}
}
