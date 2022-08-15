pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import {Storage} from "./Storage.sol";
import {MinipoolManager} from "./MinipoolManager.sol";
import {Vault} from "./Vault.sol";
import {TokenGGP} from "./tokens/TokenGGP.sol";
import {SafeTransferLib} from "@rari-capital/solmate/src/utils/SafeTransferLib.sol";
import {Oracle} from "./Oracle.sol";

import {ERC20, ERC4626} from "@rari-capital/solmate/src/mixins/ERC4626.sol";
import "./Base.sol";

contract Staking is Base {
	using SafeTransferLib for ERC20;
	using SafeTransferLib for address;

	ERC20 public immutable ggp;

	event GGPStaked(address indexed from, uint256 amount, uint256 time);
	event GGPWithdrawn(address indexed to, uint256 amount, uint256 time);
	event GGPSlashed(address indexed node, uint256 amount, uint256 ethValue, uint256 time);

	constructor(Storage storageAddress, ERC20 _ggp) Base(storageAddress) {
		version = 1;
		ggp = _ggp;
	}

	// Get/set the total GGP stake amount
	function getTotalGGPStake() external view returns (uint256) {
		return getUint(keccak256("ggp.staked.total.amount"));
	}

	function increaseTotalGGPStake(uint256 _amount) private {
		addUint(keccak256("ggp.staked.total.amount"), _amount);
	}

	function decreaseTotalGGPStake(uint256 _amount) private {
		subUint(keccak256("ggp.staked.total.amount"), _amount);
	}

	function getNodeGGPStake(address _nodeAddress) public view returns (uint256) {
		return getUint(keccak256(abi.encodePacked("ggp.staked.node.amount", _nodeAddress)));
	}

	function increaseNodeGGPStake(address _nodeAddress, uint256 _amount) private {
		addUint(keccak256(abi.encodePacked("ggp.staked.node.amount", _nodeAddress)), _amount);
	}

	function decreaseNodeGGPStake(address _nodeAddress, uint256 _amount) private {
		subUint(keccak256(abi.encodePacked("ggp.staked.node.amount", _nodeAddress)), _amount);
	}

	function getNodeGGPStakedTime(address _nodeAddress) public view returns (uint256) {
		return getUint(keccak256(abi.encodePacked("ggp.staked.node.time", _nodeAddress)));
	}

	function setNodeGGPStakedTime(address _nodeAddress, uint256 _time) private {
		setUint(keccak256(abi.encodePacked("ggp.staked.node.time", _nodeAddress)), _time);
	}

	// Get a node's minimum ggp stake to collateralize their minipools
	function getNodeMinimumGGPStake(address _nodeAddress) external view returns (uint256) {
		MinipoolManager minipoolManager = MinipoolManager(getContractAddress("MinipoolManager"));
		Oracle oracle = Oracle(getContractAddress("Oracle"));
		(uint256 ggpPriceInAvax, ) = oracle.getGGPPrice();

		return minipoolManager.getTotalAvaxStakedByUser(_nodeAddress) / ggpPriceInAvax / 10;
	}

	function getTotalEffectiveGGPStake() external view returns (uint256) {
		MinipoolManager minipoolManager = MinipoolManager(getContractAddress("MinipoolManager"));
		return minipoolManager.getTotalEffectiveGGPStake();
	}

	// Accept a GGP stake
	// user must approve the transfer request for amount first
	// TODO Only accepts calls from registered nodes
	function stakeGGP(uint256 _amount) external {
		// Load contracts
		Vault vault = Vault(getContractAddress("Vault"));

		// Transfer GGP tokens
		require(ggp.transferFrom(msg.sender, address(this), _amount), "Could not transfer GGP to staking contract");

		// Deposit GGP tokens to vault
		require(ggp.approve(address(vault), _amount), "Could not approve vault GGP deposit");
		vault.depositToken("Staking", ggp, _amount);

		// uint256 ggpStake = getNodeGGPStake(msg.sender);

		// Update GGP stake amounts & node GGP staked block
		increaseTotalGGPStake(_amount);
		increaseNodeGGPStake(msg.sender, _amount);
		// updateTotalEffectiveGGPStake(msg.sender, ggpStake, ggpStake.add(_amount));
		setNodeGGPStakedTime(msg.sender, block.timestamp);
		// Emit GGP staked event
		emit GGPStaked(msg.sender, _amount, block.timestamp);
	}
}
