pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/BaseTest.sol";
import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";

contract ScenariosTest is BaseTest {
	using FixedPointMathLib for uint256;
	uint128 internal constant ONE_K = 1_000 ether;
	uint256 internal constant TOTAL_INITIAL_GGP_SUPPLY = 22_500_000 ether;

	address private nodeOp1;
	address private nodeOp2;
	address private liqStaker1;
	address private liqStaker2;

	function setUp() public override {
		super.setUp();
		nodeOp1 = getActorWithTokens("nodeOp1", ONE_K, ONE_K);
		nodeOp2 = getActorWithTokens("nodeOp2", ONE_K, ONE_K);
		liqStaker1 = getActorWithTokens("liqStaker1", ONE_K, 0);
		liqStaker2 = getActorWithTokens("liqStaker2", ONE_K, 0);

		distributeInitialGGPSupply();
		oracle.setGGPPrice(1 ether, block.timestamp);
	}

	function distributeInitialGGPSupply() public {
		// note: guardian is minted 100% of the supply
		vm.startPrank(guardian);
		uint256 companyAllocation = (TOTAL_INITIAL_GGP_SUPPLY * .32 ether) / 1 ether;
		uint256 pDaoAllo = (TOTAL_INITIAL_GGP_SUPPLY * .3233 ether) / 1 ether;
		uint256 seedInvestorAllo = (TOTAL_INITIAL_GGP_SUPPLY * .1567 ether) / 1 ether;
		uint256 rewardsPoolAllo = (TOTAL_INITIAL_GGP_SUPPLY * .20 ether) / 1 ether;

		// approve vault deposits for all tokens that won't be in company wallet
		ggp.approve(address(vault), TOTAL_INITIAL_GGP_SUPPLY - companyAllocation);

		// 33% to the pDAO wallet
		vault.depositToken("ProtocolDAO", ggp, pDaoAllo);

		// TODO make an actual vesting contract
		// 15.67% to vesting smart contract
		vault.depositToken("ProtocolDAO", ggp, seedInvestorAllo);

		// 20% to staking rewards contract
		vault.depositToken("RewardsPool", ggp, rewardsPoolAllo);
		vm.stopPrank();
	}

	// For this test we wont do lots of intermediate asserts, just focus on end results
	function testFullCycleHappyPath() public {
		uint256 duration = 2 weeks;
		uint256 depositAmt = 1000 ether;
		uint128 ggpStakeAmt = 200 ether;

		// Liq Stakers deposit all their AVAX and get ggAVAX in return
		vm.prank(liqStaker1);
		ggAVAX.depositAVAX{value: ONE_K}();

		vm.prank(liqStaker2);
		ggAVAX.depositAVAX{value: ONE_K}();

		vm.startPrank(nodeOp1);
		ggp.approve(address(staking), ggpStakeAmt);
		staking.stakeGGP(ggpStakeAmt);
		MinipoolManager.Minipool memory mp = createMinipool(depositAmt, depositAmt, duration);
		vm.stopPrank();

		// Cannot unstake GGP at this point
		vm.expectRevert(Staking.CannotWithdrawUnder150CollateralizationRatio.selector);
		vm.prank(nodeOp1);
		staking.withdrawGGP(ggpStakeAmt);

		// Rialto will process and skip time, then we reload the mp
		mp = rialtoProcessMinipoolToSuccessWithRewards(mp.nodeID);

		// test that the node op can withdraw the funds they are due
		uint256 priorBalance_nodeOp1 = nodeOp1.balance;
		vm.prank(nodeOp1);
		minipoolMgr.withdrawMinipoolFunds(mp.nodeID);
		assertEq((nodeOp1.balance - priorBalance_nodeOp1), mp.avaxNodeOpAmt + mp.avaxNodeOpRewardAmt);

		// Skip forward 2 cycles so all rewards are available
		rewardsPool.startCycle();
		skip(ggAVAX.rewardsCycleLength());
		ggAVAX.syncRewards();
		skip(ggAVAX.rewardsCycleLength());
		ggAVAX.syncRewards();

		rialtoProcessGGPRewards();

		// nopeOp1 can claim and restake GGP rewards
		assertBoolEq(nopClaim.isEligible(nodeOp1), true);
		uint256 ggpRewards = staking.getGGPRewards(nodeOp1);
		// Not testing if the rewards are "correct", depends on elapsed time too much
		// So just restake it all
		vm.prank(nodeOp1);
		nopClaim.claimAndRestake(0);
		assertEq(staking.getGGPStake(nodeOp1), ggpStakeAmt + ggpRewards);

		// liqStaker1 can withdraw all their funds
		uint256 amt = ggAVAX.balanceOf(liqStaker1);
		vm.prank(liqStaker1);
		ggAVAX.redeemAVAX(amt);
		uint256 expectedTotal = ONE_K + (mp.avaxLiquidStakerRewardAmt / 2);
		assertEq(liqStaker1.balance, expectedTotal);

		// liqStaker2 can not withdraw all because of the float
		assertEq(ggAVAX.maxWithdraw(liqStaker2), expectedTotal);
		amt = ggAVAX.amountAvailableForStaking();
		vm.prank(liqStaker2);
		ggAVAX.withdrawAVAX(amt);
		assertEq(liqStaker2.balance, amt);

		//
	}

	// Simulates Rialto launching/finalizing minipool, and returns a mp with current data
	function rialtoProcessMinipoolToSuccessWithRewards(address nodeID) public returns (MinipoolManager.Minipool memory) {
		vm.startPrank(rialto);
		bool canClaim = minipoolMgr.canClaimAndInitiateStaking(nodeID);
		assertTrue(canClaim);
		MinipoolManager.Minipool memory mp = minipoolMgr.getMinipoolByNodeID(nodeID);
		assertEq(mp.nodeID, nodeID);
		minipoolMgr.claimAndInitiateStaking(nodeID);
		bytes32 txID = randHash();
		minipoolMgr.recordStakingStart(nodeID, txID, block.timestamp);
		skip(mp.duration);
		uint256 totalAvax = mp.avaxNodeOpAmt + mp.avaxLiquidStakerAmt;
		uint256 rewards = minipoolMgr.expectedRewardAmt(mp.duration, totalAvax);
		// console.log("expectedRewards", format.parseEther(rewards));
		deal(rialto, rialto.balance + rewards);
		minipoolMgr.recordStakingEnd{value: totalAvax + rewards}(mp.nodeID, block.timestamp, rewards);
		vm.stopPrank();
		mp = minipoolMgr.getMinipoolByNodeID(mp.nodeID);
		return mp;
	}

	function rialtoProcessMinipoolToSuccessWithNoRewards(address nodeID) public returns (MinipoolManager.Minipool memory) {
		vm.startPrank(rialto);
		bool canClaim = minipoolMgr.canClaimAndInitiateStaking(nodeID);
		assertTrue(canClaim);
		MinipoolManager.Minipool memory mp = minipoolMgr.getMinipoolByNodeID(nodeID);
		assertEq(mp.nodeID, nodeID);
		minipoolMgr.claimAndInitiateStaking(nodeID);
		bytes32 txID = randHash();
		minipoolMgr.recordStakingStart(nodeID, txID, block.timestamp);
		skip(mp.duration);
		uint256 totalAvax = mp.avaxNodeOpAmt + mp.avaxLiquidStakerAmt;
		uint256 rewards = 0;
		minipoolMgr.recordStakingEnd{value: totalAvax + rewards}(mp.nodeID, block.timestamp, rewards);
		vm.stopPrank();
		mp = minipoolMgr.getMinipoolByNodeID(mp.nodeID);
		return mp;
	}

	// Simulate what Rialto would do
	function rialtoProcessGGPRewards() public {
		rewardsPool.startCycle();

		Staking.Staker[] memory allStakers = staking.getStakers(0, 0);
		uint256 totalEligibleStakedGGP = 0;

		for (uint256 i = 0; i < allStakers.length; i++) {
			bool b = nopClaim.isEligible(allStakers[i].stakerAddr);
			if (b) {
				totalEligibleStakedGGP = totalEligibleStakedGGP + allStakers[i].ggpStaked;
			}
		}

		for (uint256 i = 0; i < allStakers.length; i++) {
			if (nopClaim.isEligible(allStakers[i].stakerAddr)) {
				nopClaim.calculateAndDistributeRewards(allStakers[i].stakerAddr, totalEligibleStakedGGP);
			}
		}
	}
}