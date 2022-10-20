pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/BaseTest.sol";

contract StakingTest is BaseTest {
	using FixedPointMathLib for uint256;

	address private nodeOp;

	function setUp() public override {
		super.setUp();
		nodeOp = getActorWithTokens("nodeOp", MAX_AMT, MAX_AMT);
		vm.startPrank(nodeOp);
		ggp.approve(address(staking), MAX_AMT);
		vm.stopPrank();
	}

	function testStake() public {
		vm.startPrank(nodeOp, nodeOp);
		staking.stakeGGP(100 ether);
		assertEq(staking.getTotalGGPStake(), 100 ether);
		assertEq(staking.getStakerCount(), 1);
		assertEq(staking.getGGPStake(nodeOp), 100 ether);
		assertEq(staking.getMinimumGGPStake(nodeOp), 0 ether);
		assertEq(staking.getCollateralizationRatio(nodeOp), type(uint256).max);

		// Manually assign some AVAX
		vm.stopPrank();
		vm.prank(address(minipoolMgr));
		staking.increaseAVAXAssigned(nodeOp, 1000 ether);
		vm.startPrank(nodeOp, nodeOp);
		assertEq(staking.getAVAXAssigned(nodeOp), 1000 ether);

		assertEq(staking.getMinimumGGPStake(nodeOp), 100 ether);
		assertEq(staking.getCollateralizationRatio(nodeOp), 0.1 ether);

		staking.stakeGGP(100 ether);
		assertEq(staking.getTotalGGPStake(), 200 ether);
		assertEq(staking.getStakerCount(), 1);
		assertEq(staking.getGGPStake(nodeOp), 200 ether);
		assertEq(staking.getMinimumGGPStake(nodeOp), 100 ether);
		assertEq(staking.getCollateralizationRatio(nodeOp), 0.2 ether);

		vm.stopPrank();
		vm.prank(address(minipoolMgr));
		staking.increaseAVAXAssigned(nodeOp, 1000 ether);
		vm.startPrank(nodeOp, nodeOp);
		assertEq(staking.getAVAXAssigned(nodeOp), 2000 ether);

		assertEq(staking.getMinimumGGPStake(nodeOp), 200 ether);
		assertEq(staking.getCollateralizationRatio(nodeOp), 0.1 ether);

		vm.expectRevert(Staking.CannotWithdrawUnder150CollateralizationRatio.selector);
		staking.withdrawGGP(1 ether);

		vm.expectRevert(Staking.InsufficientBalance.selector);
		staking.withdrawGGP(10_000 ether);

		vm.stopPrank();
	}

	function testUnstake() public {
		uint256 amt = 100 ether;
		vm.startPrank(nodeOp, nodeOp);
		uint256 startingGGPAmt = ggp.balanceOf(nodeOp);
		staking.stakeGGP(amt);
		assertEq(ggp.balanceOf(nodeOp), startingGGPAmt - amt);
		assertEq(staking.getGGPStake(nodeOp), amt);
		staking.withdrawGGP(amt);
		assertEq(ggp.balanceOf(nodeOp), startingGGPAmt);
		vm.expectRevert(Staking.InsufficientBalance.selector);
		staking.withdrawGGP(1 ether);
		vm.stopPrank();
	}
}
