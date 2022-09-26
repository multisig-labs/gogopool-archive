pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "../../Base.sol";
import {Storage} from "../../Storage.sol";
import {Vault} from "../../Vault.sol";
import {TokenGGP} from "../../tokens/TokenGGP.sol";
import {RewardsPool} from "../RewardsPool.sol";
import {Staking} from "../../Staking.sol";
import {MinipoolManager} from "../../MinipoolManager.sol";
import {ERC20} from "@rari-capital/solmate/src/mixins/ERC4626.sol";
import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";

// RPL Rewards claiming by the DAO
contract NOPClaim is Base {
	// Libs
	// Construct
	using FixedPointMathLib for uint256;
	event GGPRewardsClaimed(address indexed to, uint256 amount);
	/// @notice There are no rewards for the user to claim
	error NoRewardsToClaim();
	/// @notice Invalid amount requested
	error InvalidAmount();
	ERC20 public immutable ggp;

	uint256 internal constant TENTH = 0.1 ether;

	constructor(Storage storageAddress, ERC20 ggp_) Base(storageAddress) {
		// Version
		version = 1;
		ggp = ggp_;
	} // Get whether the contract is enabled for claims

	function getEnabled() external pure returns (bool) {
		return true;
		// RewardsPool rewardsPool = RewardsPool(getContractAddress("RewardsPool"));
		// return rewardsPool.getClaimingContractEnabled("NOPClaim");
	}

	function getRewardsCycleTotal() public view returns (uint256) {
		return getUint(keccak256("rewards.cycle.total"));
	}

	function setRewardsCycleTotal(uint256 amount) public {
		return setUint(keccak256("rewards.cycle.total"), amount);
	}

	// Get whether a node can make a claim
	// Rialto will call this
	function isEligible(address ownerAddress) public view returns (bool) {
		//rewardsStartTime has to be at least 28 days.
		//Must have at least 10% collatoralized minipool
		Staking staking = Staking(getContractAddress("Staking"));
		uint256 rewardsStartTime = staking.getRewardsStartTime(ownerAddress);
		if (staking.getCollateralizationRatio(ownerAddress) < TENTH) {
			return false;
		}
		uint256 daysDiff = (block.timestamp - rewardsStartTime) / 60 / 60 / 24;
		//TODO get 28 days frpm setting somewhere
		if (daysDiff < 14) {
			return false;
		}
		return true;
	}

	// Get the share of rewards for a node as a fraction of 1 ether
	// Rialto will call this
	//TODO: Set some limitor on this. Right now it can be called and new rewards will be distributed at any time
	function calculateAndDistributeRewards(address ownerAddress, uint256 totalEligibleGGPStaked) public {
		// Load contracts
		Staking staking = Staking(getContractAddress("Staking"));
		//TODO: use their effective stake, not thier total stake
		uint256 ggpStaked = staking.getGGPStake(ownerAddress);
		if (totalEligibleGGPStaked == 0) {
			return;
		}
		//should return how much userGGPstaked / totalEligibleGGPStaked
		uint256 percentage = ggpStaked.divWadDown(totalEligibleGGPStaked);

		uint256 nodesRewardsCycleTotal = getRewardsCycleTotal();

		uint256 rewardsAmt = percentage.mulWadDown(nodesRewardsCycleTotal);

		staking.increaseGGPRewards(ownerAddress, rewardsAmt);

		//check if their rewards time should be reset
		uint256 minipoolCount = staking.getMinipoolCount(ownerAddress);
		if (minipoolCount == 0) {
			staking.setRewardsStartTime(ownerAddress, 0);
		}
	}

	// Make an ggp claim and automatically restake the unclaimed rewards
	function claimAndRestake(uint256 claimAmount) external {
		Staking staking = Staking(getContractAddress("Staking"));
		Vault vault = Vault(getContractAddress("Vault"));

		uint256 ggpRewards = staking.getGGPRewards(msg.sender);
		if (ggpRewards == 0) {
			revert NoRewardsToClaim();
		}
		if (claimAmount > ggpRewards) {
			revert InvalidAmount();
		}

		uint256 restakeAmount = ggpRewards - claimAmount;
		if (restakeAmount > 0) {
			vault.withdrawToken(address(this), ggp, restakeAmount);
			ggp.approve(address(staking), restakeAmount);
			staking.restakeGGP(msg.sender, restakeAmount);
		}

		if (claimAmount > 0) {
			vault.withdrawToken(msg.sender, ggp, claimAmount);
		}

		//reset rewards number
		staking.decreaseGGPRewards(msg.sender, ggpRewards);
		emit GGPRewardsClaimed(msg.sender, claimAmount);
	}
}
