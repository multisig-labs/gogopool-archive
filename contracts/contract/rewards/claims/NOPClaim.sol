// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.17;

import "../../Base.sol";
import {MinipoolManager} from "../../MinipoolManager.sol";
import {ProtocolDAO} from "../../dao/ProtocolDAO.sol";
import {RewardsPool} from "../RewardsPool.sol";
import {Staking} from "../../Staking.sol";
import {Storage} from "../../Storage.sol";
import {TokenGGP} from "../../tokens/TokenGGP.sol";
import {Vault} from "../../Vault.sol";

import {ERC20} from "@rari-capital/solmate/src/mixins/ERC4626.sol";
import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";

contract NOPClaim is Base {
	using FixedPointMathLib for uint256;

	error InvalidAmount();
	error NoRewardsToClaim();

	event GGPRewardsClaimed(address indexed to, uint256 amount);

	ERC20 public immutable ggp;

	constructor(Storage storageAddress, ERC20 ggp_) Base(storageAddress) {
		version = 1;
		ggp = ggp_;
	}

	function getRewardsCycleTotal() public view returns (uint256) {
		return getUint(keccak256("NOPClaim.RewardsCycleTotal"));
	}

	function setRewardsCycleTotal(uint256 amount) public onlyLatestContract("RewardsPool", msg.sender) {
		return setUint(keccak256("NOPClaim.RewardsCycleTotal"), amount);
	}

	// Eligiblity: time in protocol (secs) > RewardsEligibilityMinSeconds
	function isEligible(address stakerAddr) external view returns (bool) {
		Staking staking = Staking(getContractAddress("Staking"));
		try staking.getRewardsStartTime(stakerAddr) returns (uint256 rewardsStartTime) {
			uint256 elapsedSecs = (block.timestamp - rewardsStartTime);
			ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
			return (rewardsStartTime != 0 && elapsedSecs >= dao.getRewardsEligibilityMinSeconds());
		} catch {
			return false;
		}
	}

	// Get the share of rewards for a node as a fraction of 1 ether
	// Rialto will call this
	//TODO: Set some limitor on this. Right now it can be called and new rewards will be distributed at any time
	function calculateAndDistributeRewards(address stakerAddr, uint256 totalEligibleGGPStaked) external {
		Staking staking = Staking(getContractAddress("Staking"));
		uint256 ggpEffectiveStaked = staking.getEffectiveGGPStaked(stakerAddr);
		uint256 percentage = ggpEffectiveStaked.divWadDown(totalEligibleGGPStaked);
		uint256 rewardsCycleTotal = getRewardsCycleTotal();
		uint256 rewardsAmt = percentage.mulWadDown(rewardsCycleTotal);
		if (rewardsAmt > rewardsCycleTotal) {
			revert InvalidAmount();
		}

		staking.resetAVAXAssignedHighWater(stakerAddr);
		staking.increaseGGPRewards(stakerAddr, rewardsAmt);

		//check if their rewards time should be reset
		uint256 minipoolCount = staking.getMinipoolCount(stakerAddr);
		if (minipoolCount == 0) {
			staking.setRewardsStartTime(stakerAddr, 0);
		}
	}

	// Make an ggp claim and automatically restake the unclaimed rewards
	function claimAndRestake(uint256 claimAmount) external {
		Staking staking = Staking(getContractAddress("Staking"));
		uint256 ggpRewards = staking.getGGPRewards(msg.sender);
		if (ggpRewards == 0) {
			revert NoRewardsToClaim();
		}
		if (claimAmount > ggpRewards) {
			revert InvalidAmount();
		}

		Vault vault = Vault(getContractAddress("Vault"));
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
