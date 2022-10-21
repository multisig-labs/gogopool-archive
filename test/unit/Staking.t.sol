pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/BaseTest.sol";

contract StakingTest is BaseTest {
	using FixedPointMathLib for uint256;

	address private nodeOp1;
	address private nodeOp2;
	address private nodeOp3;
	uint256 internal constant TOTAL_INITIAL_GGP_SUPPLY = 22_500_000 ether;

	function setUp() public override {
		super.setUp();
		nodeOp1 = getActorWithTokens("nodeOp1", MAX_AMT, MAX_AMT);
		vm.prank(nodeOp1);
		ggp.approve(address(staking), MAX_AMT);
		nodeOp2 = getActorWithTokens("nodeOp2", MAX_AMT, MAX_AMT);
		vm.prank(nodeOp2);
		ggp.approve(address(staking), MAX_AMT);
		nodeOp3 = getActorWithTokens("nodeOp3", MAX_AMT, MAX_AMT);
		vm.prank(nodeOp3);
		ggp.approve(address(staking), MAX_AMT);
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

	function testGetTotalGGPStake() public {
		assert(staking.getTotalGGPStake() == 0);
		vm.startPrank(nodeOp1);
		staking.stakeGGP(100 ether);
		assert(staking.getTotalGGPStake() == 100 ether);
		vm.stopPrank();

		vm.prank(nodeOp2);
		staking.stakeGGP(100 ether);
		assert(staking.getTotalGGPStake() == 200 ether);

		vm.prank(nodeOp1);
		staking.withdrawGGP(100 ether);
		assert(staking.getTotalGGPStake() == 100 ether);
	}

	function testGetStakerCount() public {
		assert(staking.getStakerCount() == 0);
		vm.prank(nodeOp1);
		staking.stakeGGP(100 ether);
		assert(staking.getStakerCount() == 1);

		vm.prank(nodeOp2);
		staking.stakeGGP(100 ether);
		assert(staking.getStakerCount() == 2);
	}

	function testGetGGPStake() public {
		vm.prank(nodeOp1);
		staking.stakeGGP(100 ether);
		assert(staking.getGGPStake(address(nodeOp1)) == 100 ether);

		vm.prank(nodeOp2);
		staking.stakeGGP(10.09 ether);
		assert(staking.getGGPStake(address(nodeOp2)) == 10.09 ether);
	}

	function testGetAVAXStake() public {
		vm.startPrank(nodeOp1);
		staking.stakeGGP(100 ether);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		assert(staking.getAVAXStake(address(nodeOp1)) == 1000 ether);
		vm.stopPrank();

		vm.startPrank(nodeOp2);
		staking.stakeGGP(100 ether);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		assert(staking.getAVAXStake(address(nodeOp2)) == 1000 ether);
		vm.stopPrank();
	}

	function testIncreaseAVAXStake() public {
		vm.startPrank(nodeOp1);
		staking.stakeGGP(100 ether);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		vm.stopPrank();
		vm.prank(address(minipoolMgr));
		staking.increaseAVAXStake(address(nodeOp1), 100 ether);
		assert(staking.getAVAXStake(address(nodeOp1)) == 1100 ether);
	}

	function testDecreaseAVAXStake() public {
		vm.startPrank(nodeOp1);
		staking.stakeGGP(100 ether);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		vm.stopPrank();
		vm.prank(address(minipoolMgr));
		staking.decreaseAVAXStake(address(nodeOp1), 10 ether);
		assert(staking.getAVAXStake(address(nodeOp1)) == 990 ether);
	}

	function testGetAVAXAssigned() public {
		vm.startPrank(nodeOp1);
		staking.stakeGGP(100 ether);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		assert(staking.getAVAXAssigned(address(nodeOp1)) == 1000 ether);
		vm.stopPrank();
	}

	function testIncreaseAVAXAssigned() public {
		vm.startPrank(nodeOp1);
		staking.stakeGGP(100 ether);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		vm.stopPrank();

		vm.prank(address(minipoolMgr));
		staking.increaseAVAXAssigned(address(nodeOp1), 100 ether);
		assert(staking.getAVAXAssigned(address(nodeOp1)) == 1100 ether);
	}

	function testDecreaseAVAXAssigned() public {
		vm.startPrank(nodeOp1);
		staking.stakeGGP(100 ether);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		vm.stopPrank();
		vm.prank(address(minipoolMgr));
		staking.decreaseAVAXAssigned(address(nodeOp1), 10 ether);
		assert(staking.getAVAXAssigned(address(nodeOp1)) == 990 ether);
	}

	function testGetMinipoolCount() public {
		vm.startPrank(nodeOp1);
		staking.stakeGGP(200 ether);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		assert(staking.getMinipoolCount(address(nodeOp1)) == 1);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		assert(staking.getMinipoolCount(address(nodeOp1)) == 2);
		vm.stopPrank();
	}

	function testIncreaseMinipoolCount() public {
		vm.startPrank(nodeOp1);
		staking.stakeGGP(100 ether);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		assert(staking.getMinipoolCount(address(nodeOp1)) == 1);
		vm.stopPrank();

		vm.prank(address(minipoolMgr));
		staking.increaseMinipoolCount(address(nodeOp1));
		assert(staking.getMinipoolCount(address(nodeOp1)) == 2);
	}

	function testDecreaseMinipoolCount() public {
		vm.startPrank(nodeOp1);
		staking.stakeGGP(100 ether);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		assert(staking.getMinipoolCount(address(nodeOp1)) == 1);
		vm.stopPrank();

		vm.prank(address(minipoolMgr));
		staking.decreaseMinipoolCount(address(nodeOp1));
		assert(staking.getMinipoolCount(address(nodeOp1)) == 0);
	}

	function testGetRewardsStartTime() public {
		vm.startPrank(nodeOp1);
		staking.stakeGGP(200 ether);
		assert(staking.getRewardsStartTime(address(nodeOp1)) == 0);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		assert(staking.getRewardsStartTime(address(nodeOp1)) != 0);
		vm.stopPrank();
	}

	function testSetRewardsStartTime() public {
		vm.prank(nodeOp1);
		staking.stakeGGP(200 ether);
		assert(staking.getRewardsStartTime(address(nodeOp1)) == 0);

		vm.prank(address(minipoolMgr));
		staking.setRewardsStartTime(address(nodeOp1), 1666291634);
		assert(staking.getRewardsStartTime(address(nodeOp1)) == 1666291634);
	}

	//TODO: failing on transfer token, underflow/overflow
	function testGetGGPRewards() public {
		vm.startPrank(nodeOp1);
		staking.stakeGGP(100 ether);
		assertEq(staking.getGGPRewards(address(nodeOp1)), 0);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		vm.stopPrank();

		vm.expectRevert(RewardsPool.UnableToStartRewardsCycle.selector);
		rewardsPool.startRewardsCycle();
		assertFalse(rewardsPool.canStartRewardsCycle());

		skip(dao.getRewardsCycleSeconds());

		assertEq(rewardsPool.getRewardsCyclesElapsed(), 1);
		assertTrue(rewardsPool.canStartRewardsCycle());
		assertEq(vault.balanceOfToken("NOPClaim", ggp), 0);
		assertEq(vault.balanceOfToken("ProtocolDAOClaim", ggp), 0);

		rewardsPool.startRewardsCycle();

		assertGt(vault.balanceOfToken("NOPClaim", ggp), 0);
		assertGt(vault.balanceOfToken("ProtocolDAOClaim", ggp), 0);
	}

	function testIncreaseGGPRewards() public {
		vm.prank(nodeOp1);
		staking.stakeGGP(100 ether);

		vm.prank(address(nopClaim));
		staking.increaseGGPRewards(address(nodeOp1), 100 ether);
		assert(staking.getGGPRewards(address(nodeOp1)) == 100 ether);
	}

	function testDecreaseGGPRewards() public {
		vm.prank(nodeOp1);
		staking.stakeGGP(100 ether);
		assert(staking.getGGPRewards(address(nodeOp1)) == 0 ether);

		vm.startPrank(address(nopClaim));
		staking.increaseGGPRewards(address(nodeOp1), 100 ether);
		staking.decreaseGGPRewards(address(nodeOp1), 10 ether);
		assert(staking.getGGPRewards(address(nodeOp1)) == 90 ether);
		vm.stopPrank();
	}

	function testGetMinimumGGPStake() public {
		vm.startPrank(nodeOp1);
		staking.stakeGGP(300 ether);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		assert(staking.getMinimumGGPStake(address(nodeOp1)) == 100 ether);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		assert(staking.getMinimumGGPStake(address(nodeOp1)) == 200 ether);
		vm.stopPrank();
	}

	function testGetCollateralizationRatio() public {
		vm.startPrank(nodeOp1);
		staking.stakeGGP(300 ether);
		assert(staking.getCollateralizationRatio(address(nodeOp1)) == type(uint256).max);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		assert(staking.getCollateralizationRatio(address(nodeOp1)) == 0.3 ether);
		vm.stopPrank();
	}

	function testGetEffectiveGGPStaked() public {
		vm.startPrank(nodeOp1);
		staking.stakeGGP(300 ether);
		assert(staking.getEffectiveGGPStaked(address(nodeOp1)) == 0 ether);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		assert(staking.getEffectiveGGPStaked(address(nodeOp1)) == 300 ether);
		staking.stakeGGP(1700 ether);
		assert(staking.getEffectiveGGPStaked(address(nodeOp1)) == 1500 ether);
		vm.stopPrank();
	}

	//TODO: failing on transfer token, underflow/overflow
	// function testRestakeGGP() public {
	// 	vm.startPrank(nodeOp1);
	// 	staking.stakeGGP(300 ether);
	// 	vm.stopPrank();
	// 	dealGGP(address(nopClaim), 1000 ether);
	// 	assert(staking.getGGPStake(address(nodeOp1)) == 300 ether);

	// 	vm.stopPrank();

	// 	vm.startPrank(address(nopClaim));
	// 	staking.restakeGGP(address(nodeOp1), 200 ether);
	// 	assert(staking.getGGPStake(address(nodeOp1)) == 500 ether);
	// }

	function testStakeGGP() public {
		uint256 amt = 100 ether;
		vm.startPrank(nodeOp1, nodeOp1);
		uint256 startingGGPAmt = ggp.balanceOf(nodeOp1);
		staking.stakeGGP(amt);
		assert(ggp.balanceOf(nodeOp1) == startingGGPAmt - amt);
		assert(staking.getGGPStake(nodeOp1) == amt);
		vm.stopPrank();
	}

	function testWithdrawGGP() public {
		uint256 amt = 100 ether;
		vm.startPrank(nodeOp1, nodeOp1);
		uint256 startingGGPAmt = ggp.balanceOf(nodeOp1);
		staking.stakeGGP(amt);
		assert(ggp.balanceOf(nodeOp1) == startingGGPAmt - amt);
		assert(staking.getGGPStake(nodeOp1) == amt);
		staking.withdrawGGP(amt);
		assert(ggp.balanceOf(nodeOp1) == startingGGPAmt);
		vm.expectRevert(Staking.InsufficientBalance.selector);
		staking.withdrawGGP(1 ether);
		vm.stopPrank();
	}

	//TODO: This is left over from before, is it still useful?
	function testStakeScenario() public {
		vm.prank(nodeOp1, nodeOp1);
		staking.stakeGGP(100 ether);
		assert(staking.getTotalGGPStake() == 100 ether);
		assert(staking.getStakerCount() == 1);
		assert(staking.getGGPStake(nodeOp1) == 100 ether);
		assert(staking.getMinimumGGPStake(nodeOp1) == 0 ether);
		assert(staking.getCollateralizationRatio(nodeOp1) == type(uint256).max);

		// Manually assign some AVAX
		vm.prank(address(minipoolMgr));
		staking.increaseAVAXAssigned(nodeOp1, 1000 ether);

		vm.startPrank(nodeOp1, nodeOp1);
		assert(staking.getAVAXAssigned(nodeOp1) == 1000 ether);

		assert(staking.getMinimumGGPStake(nodeOp1) == 100 ether);
		assert(staking.getCollateralizationRatio(nodeOp1) == 0.1 ether);

		staking.stakeGGP(100 ether);
		assert(staking.getTotalGGPStake() == 200 ether);
		assert(staking.getStakerCount() == 1);
		assert(staking.getGGPStake(nodeOp1) == 200 ether);
		assert(staking.getMinimumGGPStake(nodeOp1) == 100 ether);
		assert(staking.getCollateralizationRatio(nodeOp1) == 0.2 ether);

		vm.stopPrank();
		vm.startPrank(address(minipoolMgr));
		staking.increaseAVAXAssigned(nodeOp1, 1000 ether);
		vm.stopPrank();
		vm.startPrank(nodeOp1, nodeOp1);
		assert(staking.getAVAXAssigned(nodeOp1) == 2000 ether);

		assert(staking.getMinimumGGPStake(nodeOp1) == 200 ether);
		assert(staking.getCollateralizationRatio(nodeOp1) == 0.1 ether);

		vm.expectRevert(Staking.CannotWithdrawUnder150CollateralizationRatio.selector);
		staking.withdrawGGP(1 ether);

		vm.expectRevert(Staking.InsufficientBalance.selector);
		staking.withdrawGGP(10_000 ether);

		vm.stopPrank();
	}
}
