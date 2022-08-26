pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "../../Base.sol";
import "../../Vault.sol";
import "../../tokens/TokenGGP.sol";
import "../RewardsPool.sol";
import "../../Storage.sol";
import {Staking} from "../../Staking.sol";
import {MinipoolManager} from "../../MinipoolManager.sol";
import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";

// RPL Rewards claiming by the DAO
contract NOPClaim is Base {
	// Libs
	// Construct
	using FixedPointMathLib for uint256;

	constructor(Storage storageAddress) Base(storageAddress) {
		// Version
		version = 1;
	} // Get whether the contract is enabled for claims

	function getEnabled() external view returns (bool) {
		return true;
		// RewardsPool rewardsPool = RewardsPool(getContractAddress("RewardsPool"));
		// return rewardsPool.getClaimingContractEnabled("NOPClaim");
	}

	// Get whether a node can make a claim
	// TODO include onlyRegisteredNode modifer
	function getClaimPossible(address ownerAddress) public view returns (bool) {
		// Load contracts
		RewardsPool rewardsPool = RewardsPool(getContractAddress("RewardsPool"));
		Staking staking = Staking(getContractAddress("Staking"));
		// Return claim possible status
		return (rewardsPool.getClaimingContractUserCanClaim("NOPClaim", ownerAddress) &&
			staking.getUserGGPStake(ownerAddress) >= staking.getUserMinimumGGPStake(ownerAddress));
	}

	// Get the share of rewards for a node as a fraction of 1 ether
	function getClaimRewardsPerc(address ownerAddress) public view returns (uint256) {
		// Check node can claim
		if (!getClaimPossible(ownerAddress)) {
			return 0;
		}
		// Load contracts
		Staking staking = Staking(getContractAddress("Staking"));
		// Calculate and return share

		// TODO: Maybe make this come from storage rather than calc each time. See MinipoolManager for details
		uint256 totalGgpStake = staking.getTotalEffectiveGGPStake(); //should return the amoutn of ggp that is staked in the protocol up to the 150% collat ratio
		if (totalGgpStake == 0) {
			return 0;
		}
		//should return how much userGGPstaked / totalGGPStaked
		return staking.getUserEffectiveGGPStake(ownerAddress).divWadDown(totalGgpStake);
	}

	// Front end call probably
	// Get the amount of rewards for a node for the reward period
	function getClaimRewardsAmount(address ownerAddress) external view returns (uint256) {
		RewardsPool rewardsPool = RewardsPool(getContractAddress("RewardsPool"));
		return rewardsPool.getClaimAmount("NOPClaim", ownerAddress, getClaimRewardsPerc(ownerAddress));
	}

	// Register or deregister a node for GGP claims
	// Only accepts calls from the RocketNodeManager contract
	function register(address ownerAddress, bool enable) external {
		RewardsPool rewardsPool = RewardsPool(getContractAddress("RewardsPool"));
		rewardsPool.registerClaimer(ownerAddress, enable);
	}

	// Make an RPL claim
	// Only accepts calls from registered nodes
	function claim() external {
		// Check that the node can claim
		// TODO require(getClaimPossible(msg.sender), "The node is currently unable to claim");

		// Get node withdrawal address
		// Get user's wallet address
		// TODO setup withdrawal address for nodes, for now just using msg.sender
		// https://github.com/multisig-labs/gogopool-contracts/issues/88
		address nodeWithdrawalAddress = msg.sender;
		// address nodeWithdrawalAddress = gogoStorage.getNodeWithdrawalAddress(msg.sender);
		// Claim RPL
		RewardsPool rewardsPool = RewardsPool(getContractAddress("RewardsPool"));
		rewardsPool.claim(msg.sender, nodeWithdrawalAddress, getClaimRewardsPerc(msg.sender));
	}
}
