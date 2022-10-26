// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;

import "./Base.sol";
import {Storage} from "./Storage.sol";
import {ERC20, ERC20Burnable} from "./tokens/ERC20Burnable.sol";
import {IWithdrawer} from "../interface/IWithdrawer.sol";

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
		avaxBalances[contractName] = avaxBalances[contractName] + msg.value;
		emit AVAXDeposited(contractName, msg.value);
	}

	// Withdraw an amount of AVAX to a network contract
	function withdrawAVAX(uint256 amount) external onlyLatestNetworkContract {
		if (amount == 0) {
			revert InvalidAmount();
		}
		string memory contractName = getContractName(msg.sender);
		if (avaxBalances[contractName] < amount) {
			revert InsufficientContractBalance();
		}
		avaxBalances[contractName] = avaxBalances[contractName] - amount;
		IWithdrawer withdrawer = IWithdrawer(msg.sender);
		withdrawer.receiveWithdrawalAVAX{value: amount}();
		emit AVAXWithdrawn(contractName, amount);
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
		// Make sure the contracts are valid, will revert if not
		getContractAddress(fromContractName);
		getContractAddress(toContractName);

		avaxBalances[fromContractName] = avaxBalances[fromContractName] - amount;
		avaxBalances[toContractName] = avaxBalances[toContractName] + amount;
		emit AVAXTransfer(fromContractName, toContractName, amount);
	}

	// Accept a token deposit and assign its balance to a network contract
	// (saves a large amount of gas this way through not needing a double token transfer via a network contract first)
	function depositToken(
		string memory _networkContractName,
		ERC20 _tokenContract,
		uint256 _amount
	) external {
		if (_amount == 0) {
			revert InvalidAmount();
		}
		// Make sure the network contract is valid (will revert if not)
		getContractAddress(_networkContractName);
		bytes32 contractKey = keccak256(abi.encodePacked(_networkContractName, address(_tokenContract)));
		if (!_tokenContract.transferFrom(msg.sender, address(this), _amount)) {
			revert TokenTransferFailed();
		}
		tokenBalances[contractKey] = tokenBalances[contractKey] + _amount;
		emit TokenDeposited(contractKey, address(_tokenContract), _amount);
	}

	// Withdraw an amount of a ERC20 token to an address
	function withdrawToken(
		address _withdrawalAddress,
		ERC20 _tokenAddress,
		uint256 _amount
	) external onlyLatestNetworkContract {
		if (_amount == 0) {
			revert InvalidAmount();
		}
		bytes32 contractKey = keccak256(abi.encodePacked(getContractName(msg.sender), _tokenAddress));
		tokenBalances[contractKey] = tokenBalances[contractKey] - _amount;
		ERC20 tokenContract = ERC20(_tokenAddress);
		if (!tokenContract.transfer(_withdrawalAddress, _amount)) {
			revert VaultTokenWithdrawalFailed();
		}
		emit TokenWithdrawn(contractKey, address(_tokenAddress), _amount);
	}

	// Transfer token from one contract to another
	function transferToken(
		string memory _networkContractName,
		ERC20 _tokenAddress,
		uint256 _amount
	) external onlyLatestNetworkContract {
		if (_amount == 0) {
			revert InvalidAmount();
		}
		// Make sure the network contract is valid (will revert if not)
		getContractAddress(_networkContractName);

		bytes32 contractKeyFrom = keccak256(abi.encodePacked(getContractName(msg.sender), _tokenAddress));
		bytes32 contractKeyTo = keccak256(abi.encodePacked(_networkContractName, _tokenAddress));

		tokenBalances[contractKeyFrom] = tokenBalances[contractKeyFrom] - _amount;
		tokenBalances[contractKeyTo] = tokenBalances[contractKeyTo] + _amount;

		emit TokenTransfer(contractKeyFrom, contractKeyTo, address(_tokenAddress), _amount);
	}

	// Burns an amount of a token that implements a burn(uint256) method
	function burnToken(ERC20Burnable _tokenAddress, uint256 _amount) external onlyLatestNetworkContract {
		bytes32 contractKey = keccak256(abi.encodePacked(getContractName(msg.sender), _tokenAddress));
		tokenBalances[contractKey] = tokenBalances[contractKey] - _amount;
		ERC20Burnable tokenContract = ERC20Burnable(_tokenAddress);
		tokenContract.burn(_amount);
		emit TokenBurned(contractKey, address(_tokenAddress), _amount);
	}

	// Get a contract's AVAX balance by address
	function balanceOf(string memory _networkContractName) external view returns (uint256) {
		return avaxBalances[_networkContractName];
	}

	// Get the balance of a token held by a network contract
	function balanceOfToken(string memory _networkContractName, ERC20 _tokenAddress) external view returns (uint256) {
		return tokenBalances[keccak256(abi.encodePacked(_networkContractName, _tokenAddress))];
	}
}
