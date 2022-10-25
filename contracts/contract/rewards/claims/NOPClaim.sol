// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;

import "../../Base.sol";
import {Storage} from "../../Storage.sol";
import {Vault} from "../../Vault.sol";
import {TokenGGP} from "../../tokens/TokenGGP.sol";
import {RewardsPool} from "../RewardsPool.sol";
import {Staking} from "../../Staking.sol";
import {MinipoolManager} from "../../MinipoolManager.sol";
import {ProtocolDAO} from "../../dao/ProtocolDAO.sol";
import {ERC20} from "@rari-capital/solmate/src/mixins/ERC4626.sol";
import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";

contract NOPClaim is Base {
	using FixedPointMathLib for uint256;

	error NoRewardsToClaim();
	error InvalidAmount();

	event GGPRewardsClaimed(address indexed to, uint256 amount);

	ERC20 public immutable ggp;
	uint256 internal constant TENTH = 0.1 ether;

	constructor(Storage storageAddress, ERC20 ggp_) Base(storageAddress) {
		// Version
		version = 1;
		ggp = ggp_;
	}

	function getRewardsCycleTotal() public view returns (uint256) {
		return getUint(keccak256("NOPClaim.RewardsCycleTotal"));
	}

	function setRewardsCycleTotal(uint256 amount) public {
		return setUint(keccak256("NOPClaim.RewardsCycleTotal"), amount);
	}

	// Get whether a node can make a claim
	// Rialto will call this
	function isEligible(address ownerAddress) external view returns (bool) {
		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		Staking staking = Staking(getContractAddress("Staking"));

		try staking.getRewardsStartTime(ownerAddress) returns (uint256 rewardsStartTime) {
			//Must have at least 10% collatoralized minipool
			if (staking.getCollateralizationRatio(ownerAddress) < TENTH) {
				return false;
			}
			//rewardsStartTime has to be at least the min length.
			uint256 daysDiff = (block.timestamp - rewardsStartTime) / 60 / 60 / 24;
			uint256 minEligibleLength = dao.getRewardsEligibilityMinSeconds();
			if (daysDiff < minEligibleLength) {
				return false;
			}
		} catch {
			return false;
		}

		return true;
	}

	// Get the share of rewards for a node as a fraction of 1 ether
	// Rialto will call this
	//TODO: Set some limitor on this. Right now it can be called and new rewards will be distributed at any time
	function calculateAndDistributeRewards(address ownerAddress, uint256 totalEligibleGGPStaked) external {
		// Load contracts
		Staking staking = Staking(getContractAddress("Staking"));

		// uint256 ggpEffectiveStaked = staking.getEffectiveGGPStaked(ownerAddress);
		if (totalEligibleGGPStaked == 0) {
			return;
		}

		//should return how much userGGPstaked / totalEligibleGGPStaked
		//TODO: uncomment below when alpha is done
		// uint256 percentage = ggpEffectiveStaked.divWadDown(totalEligibleGGPStaked);

		// uint256 nodesRewardsCycleTotal = getRewardsCycleTotal();

		// uint256 rewardsAmt = percentage.mulWadDown(nodesRewardsCycleTotal);

		// if (rewardsAmt > nodesRewardsCycleTotal) {
		// 	revert InvalidAmount();
		// }

		// staking.increaseGGPRewards(ownerAddress, rewardsAmt);

		//TODO: Remove below when alpha is done
		uint256 percentage = 0.1 ether;
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
