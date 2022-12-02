// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.17;

import "./utils/BaseTest.sol";
import {BaseAbstract} from "../../contracts/contract/BaseAbstract.sol";

import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";

contract ClaimNodeOpTest is BaseTest {
	using FixedPointMathLib for uint256;
	uint256 private constant TOTAL_INITIAL_SUPPLY = 22500000 ether;

	function setUp() public override {
		super.setUp();
		distributeInitialSupply();

		skip(dao.getRewardsCycleSeconds());
		rewardsPool.startRewardsCycle();
		vm.stopPrank();
	}

	function distributeInitialSupply() public {
		// note: guardian is minted 100% of the supply
		vm.startPrank(guardian);

		uint256 companyAllocation = TOTAL_INITIAL_SUPPLY.mulWadDown(.32 ether);
		uint256 pDaoAllo = TOTAL_INITIAL_SUPPLY.mulWadDown(.3233 ether);
		uint256 seedInvestorAllo = TOTAL_INITIAL_SUPPLY.mulWadDown(.1567 ether);
		uint256 rewardsPoolAllo = TOTAL_INITIAL_SUPPLY.mulWadDown(.20 ether); //4.5 million

		// approve vault deposits for all tokens that won't be in company wallet
		ggp.approve(address(vault), TOTAL_INITIAL_SUPPLY - companyAllocation);

		// 33% to the pDAO wallet
		vault.depositToken("ProtocolDAO", ggp, pDaoAllo);

		// TODO make an actual vesting contract
		// 15.67% to vesting smart contract
		vault.depositToken("ProtocolDAO", ggp, seedInvestorAllo);

		// 20% to staking rewards contract
		vault.depositToken("RewardsPool", ggp, rewardsPoolAllo);

		vm.stopPrank();
	}

	function testGetRewardsCycleTotal() public {
		assertEq(nopClaim.getRewardsCycleTotal(), 47247734062418964737913);
	}

	function testSetRewardsCycleTotal() public {
		vm.prank(address(123));
		vm.expectRevert(BaseAbstract.InvalidOrOutdatedContract.selector);
		nopClaim.setRewardsCycleTotal(1234 ether);

		vm.prank(address(rewardsPool));
		nopClaim.setRewardsCycleTotal(1234 ether);
		assertEq(nopClaim.getRewardsCycleTotal(), 1234 ether);
	}

	function testIsEligible() public {
		address nodeOp1 = getActorWithTokens("nodeOp1", MAX_AMT, MAX_AMT);
		vm.startPrank(nodeOp1);
		ggp.approve(address(staking), MAX_AMT);
		staking.stakeGGP(100 ether);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		vm.stopPrank();

		address nodeOp2 = getActorWithTokens("nodeOp2", MAX_AMT, MAX_AMT);
		vm.startPrank(nodeOp2);
		ggp.approve(address(staking), MAX_AMT);
		staking.stakeGGP(100 ether);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		vm.stopPrank();

		assertFalse(nopClaim.isEligible(nodeOp1));
		assertFalse(nopClaim.isEligible(nodeOp2));

		skip(dao.getRewardsEligibilityMinSeconds());

		assertTrue(nopClaim.isEligible(nodeOp1));
		assertTrue(nopClaim.isEligible(nodeOp2));
	}

	function testCalculateAndDistributeRewards() public {
		address nodeOp1 = getActorWithTokens("nodeOp1", MAX_AMT, MAX_AMT);
		vm.startPrank(nodeOp1);
		ggp.approve(address(staking), MAX_AMT);
		staking.stakeGGP(100 ether);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		vm.stopPrank();

		address nodeOp2 = getActorWithTokens("nodeOp2", MAX_AMT, MAX_AMT);
		vm.startPrank(nodeOp2);
		ggp.approve(address(staking), MAX_AMT);
		staking.stakeGGP(100 ether);
		createMinipool(1000 ether, 1000 ether, 2 weeks);
		vm.stopPrank();

		vm.expectRevert(BaseAbstract.MustBeMultisig.selector);
		nopClaim.calculateAndDistributeRewards(nodeOp1, 200 ether);

		vm.startPrank(rialto);

		nopClaim.calculateAndDistributeRewards(nodeOp1, 200 ether);
		assertEq(staking.getGGPRewards(nodeOp1), (nopClaim.getRewardsCycleTotal()) / 2);
		assertEq(staking.getLastRewardsCycleCompleted(nodeOp1), rewardsPool.getRewardsCycleCount());
		assertEq(staking.getAVAXAssignedHighWater(nodeOp1), staking.getAVAXAssigned(nodeOp1));

		vm.expectRevert(abi.encodeWithSelector(ClaimNodeOp.RewardsAlreadyDistributedToStaker.selector, address(nodeOp1)));
		nopClaim.calculateAndDistributeRewards(nodeOp1, 200 ether);
	}

	function testClaimAndRestake() public {
		address nodeOp1 = getActorWithTokens("nodeOp1", MAX_AMT, MAX_AMT);
		vm.startPrank(nodeOp1);
		ggp.approve(address(staking), MAX_AMT);
		staking.stakeGGP(100 ether);
		createMinipool(1000 ether, 1000 ether, 2 weeks);

		uint256 nodeOp1PriorBalanceGGP = ggp.balanceOf(nodeOp1);

		assertEq(staking.getGGPRewards(nodeOp1), 0);
		vm.expectRevert(ClaimNodeOp.NoRewardsToClaim.selector);
		nopClaim.claimAndRestake(0);
		vm.stopPrank();

		vm.startPrank(rialto);
		nopClaim.calculateAndDistributeRewards(nodeOp1, 200 ether);
		vm.stopPrank();

		vm.startPrank(nodeOp1);
		uint256 totalRewardsThisCycle = nopClaim.getRewardsCycleTotal();
		assertEq(staking.getGGPRewards(nodeOp1), totalRewardsThisCycle / 2);
		vm.expectRevert(ClaimNodeOp.InvalidAmount.selector);
		nopClaim.claimAndRestake(totalRewardsThisCycle);

		nopClaim.claimAndRestake((totalRewardsThisCycle / 4)); // half of their rewards
		assertEq(ggp.balanceOf(nodeOp1), (nodeOp1PriorBalanceGGP + (totalRewardsThisCycle / 4)));
		assertEq(staking.getGGPStake(nodeOp1), (100 ether + (totalRewardsThisCycle / 4)));
		assertEq(staking.getGGPRewards(nodeOp1), 0);
	}
}
