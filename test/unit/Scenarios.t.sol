// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;

import "./utils/BaseTest.sol";
import {RialtoSimulator} from "../../contracts/contract/utils/RialtoSimulator.sol";
import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";

contract ScenariosTest is BaseTest {
	using FixedPointMathLib for uint256;
	uint128 internal constant ONE_K = 1_000 ether;
	uint256 internal constant TOTAL_INITIAL_GGP_SUPPLY = 22_500_000 ether;

	RialtoSimulator private rialtoSim;

	address private nodeOp1;
	address private nodeOp2;
	address private liqStaker1;
	address private liqStaker2;

	function setUp() public override {
		super.setUp();

		// Create a simulated Rialto multisig. By registering the contract addr as a
		// valid multisig, then no matter who calls the contract fns they will work, no prank necessary
		rialtoSim = new RialtoSimulator(minipoolMgr, nopClaim, rewardsPool, staking);
		vm.startPrank(guardian);
		multisigMgr.disableMultisig(address(rialto));
		multisigMgr.registerMultisig(address(rialtoSim));
		multisigMgr.enableMultisig(address(rialtoSim));
		vm.stopPrank();

		// Give Rialto sim some funds to pay simulated validator rewards
		vm.deal(address(rialtoSim), ONE_K);

		nodeOp1 = getActorWithTokens("nodeOp1", ONE_K, ONE_K);
		nodeOp2 = getActorWithTokens("nodeOp2", ONE_K, ONE_K);
		liqStaker1 = getActorWithTokens("liqStaker1", ONE_K, 0);
		liqStaker2 = getActorWithTokens("liqStaker2", ONE_K, 0);

		fundGGPRewardsPool();
	}

	function fundGGPRewardsPool() public {
		// guardian is minted 100% of the supply
		vm.startPrank(guardian);
		uint256 rewardsPoolAmt = TOTAL_INITIAL_GGP_SUPPLY.mulWadDown(.20 ether);
		ggp.approve(address(vault), rewardsPoolAmt);
		vault.depositToken("RewardsPool", ggp, rewardsPoolAmt);
		vm.stopPrank();
	}

	// For this test we wont do lots of intermediate asserts, just focus on end results
	function testFullCycleHappyPath() public {
		uint256 duration = 2 weeks;
		uint256 depositAmt = dao.getMinipoolMinAVAXAssignment();
		uint256 ggpStakeAmt = depositAmt.mulWadDown(dao.getMinCollateralizationRatio());
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

		mp = rialtoSim.processMinipoolStart(mp.nodeID);
		skip(mp.duration);
		mp = rialtoSim.processMinipoolEndWithRewards(mp.nodeID);

		// test that the node op can withdraw the funds they are due
		uint256 nodeOp1PriorBalance = nodeOp1.balance;
		vm.prank(nodeOp1);
		minipoolMgr.withdrawMinipoolFunds(mp.nodeID);
		assertEq((nodeOp1.balance - nodeOp1PriorBalance), mp.avaxNodeOpAmt + mp.avaxNodeOpRewardAmt);

		skip(block.timestamp - rewardsPool.getRewardsCycleStartTime());
		assertTrue(rewardsPool.canStartRewardsCycle());
		assertTrue(nopClaim.isEligible(nodeOp1), "isEligible");
		rialtoSim.processGGPRewards();

		// Not testing if the rewards are "correct", depends on elapsed time too much
		// So just restake it all
		uint256 ggpRewards = staking.getGGPRewards(nodeOp1);
		vm.prank(nodeOp1);
		nopClaim.claimAndRestake(0);
		assertEq(staking.getGGPStake(nodeOp1), ggpStakeAmt + ggpRewards);

		// Skip forward 2 cycles to ensure all ggAVAX rewards are available
		skip(ggAVAX.rewardsCycleLength());
		ggAVAX.syncRewards();
		skip(ggAVAX.rewardsCycleLength());
		ggAVAX.syncRewards();

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
	}

	function testFullCycleNoRewards() public {
		uint256 duration = 2 weeks;
		uint256 depositAmt = dao.getMinipoolMinAVAXAssignment();
		uint256 ggpStakeAmt = depositAmt.mulWadDown(dao.getMinCollateralizationRatio());

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

		mp = rialtoSim.processMinipoolStart(mp.nodeID);
		skip(mp.duration);
		mp = rialtoSim.processMinipoolEndWithoutRewards(mp.nodeID);

		// test that the node op can withdraw the funds they are due
		uint256 priorBalance_nodeOp1 = nodeOp1.balance;
		vm.prank(nodeOp1);
		minipoolMgr.withdrawMinipoolFunds(mp.nodeID);
		assertEq((nodeOp1.balance - priorBalance_nodeOp1), mp.avaxNodeOpAmt + mp.avaxNodeOpRewardAmt);

		// nodeOp1 should have been slashed
		uint256 expectedAvaxRewardsAmt = minipoolMgr.getExpectedAVAXRewardsAmt(mp.duration, depositAmt);
		uint256 slashedGGPAmt = minipoolMgr.calculateGGPSlashAmt(expectedAvaxRewardsAmt);
		assertEq(staking.getGGPStake(nodeOp1), ggpStakeAmt - slashedGGPAmt);

		skip(block.timestamp - rewardsPool.getRewardsCycleStartTime());
		assertTrue(rewardsPool.canStartRewardsCycle());
		// nopeOp1 is still "eligible" even though they were slashed
		assertTrue(nopClaim.isEligible(nodeOp1), "isEligible");
		rialtoSim.processGGPRewards();

		// Not testing if the rewards are "correct", depends on elapsed time too much
		// So just restake it all
		uint256 ggpRewards = staking.getGGPRewards(nodeOp1);
		vm.prank(nodeOp1);
		nopClaim.claimAndRestake(0);
		assertEq(staking.getGGPStake(nodeOp1), ggpStakeAmt + ggpRewards - slashedGGPAmt);

		// Skip forward 2 cycles so all rewards are available
		skip(ggAVAX.rewardsCycleLength());
		ggAVAX.syncRewards();
		skip(ggAVAX.rewardsCycleLength());
		ggAVAX.syncRewards();

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
	}
}
