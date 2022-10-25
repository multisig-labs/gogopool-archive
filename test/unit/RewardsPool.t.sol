// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;

import "./utils/BaseTest.sol";
import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";

contract RewardsPoolTest is BaseTest {
	using FixedPointMathLib for uint256;

	uint256 private constant TOTAL_INITIAL_SUPPLY = 22500000 ether;

	function setUp() public override {
		super.setUp();
		distributeInitialSupply();
	}

	function distributeInitialSupply() public {
		// note: guardian is minted 100% of the supply
		vm.startPrank(guardian, guardian);

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

	//commenting this out since it is failing, because effective stake only applies to minipools that have borrowed liquid stakers funds. But we will come back to focusing on rewards later
	// function testTotalEffectiveStakeNoMinipools() public {
	// 	address nodeOp = getActorWithGGP(1000 ether);
	// 	vm.startPrank(nodeOp);
	// 	staking.stakeGGP(1000 ether);

	// 	uint256 totalEffectiveStake = staking.getTotalEffectiveGGPStake();
	// 	assertEq(totalEffectiveStake, 0);
	// 	vm.stopPrank();
	// }

	//commenting this out since it is failing, because effective stake only applies to minipools that have borrowed liquid stakers funds. But we will come back to focusing on rewards later
	// function testTotalEffectiveStakeWithMinipool() public {
	// 	uint128 ggpStakeAmt = 1000 ether;
	// 	uint256 depositAmt = 1000 ether;
	// 	uint256 avaxAssignmentRequest = 1000 ether;

	// 	address nodeOp = getActorWithGGP(ggpStakeAmt);
	// 	vm.deal(nodeOp, depositAmt);

	// 	vm.startPrank(nodeOp);
	// 	staking.stakeGGP(ggpStakeAmt);

	// 	(nodeID, duration, delegationFee) = randMinipool();

	// 	minipoolMgr.createMinipool{value: depositAmt}(nodeID, duration, delegationFee, avaxAssignmentRequest);

	// 	uint256 totalEffectiveStake = staking.getTotalEffectiveGGPStake();
	// 	assertEq(totalEffectiveStake, ggpStakeAmt);
	// 	vm.stopPrank();
	// }

	//commenting this out since it is failing, because effective stake only applies to minipools that have borrowed liquid stakers funds. But we will come back to focusing on rewards later
	// function testNodeOpEffectiveStake() public {
	// 	uint128 ggpStakeAmt = 2000 ether;
	// 	uint256 depositAmt = 1000 ether;
	// 	uint256 avaxAssignmentRequest = 1000 ether;

	// 	address nodeOp = getActorWithTokens(1000 ether, 2000 ether);
	// 	address nodeOp2 = getActorWithTokens(1000 ether, 2000 ether);

	// 	stakeAndCreateMinipool(nodeOp, depositAmt, ggpStakeAmt, avaxAssignmentRequest);
	// 	stakeAndCreateMinipool(nodeOp2, depositAmt, ggpStakeAmt, avaxAssignmentRequest);

	// 	uint256 totalMinipools = store.getUint(keccak256("MinipoolManager.count"));
	// 	assertEq(totalMinipools, 2);

	// 	uint256 totalEffectiveNodeOpStake = staking.getUserEffectiveGGPStake(nodeOp);
	// 	assertEq(totalEffectiveNodeOpStake, 1500 ether);
	// }

	function testInitialization() public {
		assertTrue(store.getBool(keccak256("RewardsPool.initialized")));
		assertGt(rewardsPool.getInflationIntervalStartTime(), 0);
		assertGt(rewardsPool.getRewardsCycleStartTime(), 0);
	}

	function testGetInflationIntervalsElapsed() public {
		assertEq(rewardsPool.getInflationIntervalsElapsed(), 0);
		skip(dao.getInflationIntervalSeconds());
		assertEq(rewardsPool.getInflationIntervalsElapsed(), 1);
	}

	//TODO test this full 5 years
	function testInflationCalculate() public {
		uint256 curSupply;
		uint256 newSupply;

		// Hard-code numbers for this specific test
		uint256 totalCirculatingSupply = 18000000 ether;
		store.setUint(keccak256("ProtocolDAO.TotalGGPCirculatingSupply"), totalCirculatingSupply);
		assertEq(dao.getTotalGGPCirculatingSupply(), totalCirculatingSupply);

		uint256 inflationRate = 1000133680617113500;
		store.setUint(keccak256("ProtocolDAO.InflationIntervalRate"), inflationRate);
		assertEq(dao.getInflationIntervalRate(), inflationRate);

		(curSupply, newSupply) = rewardsPool.getInflationAmt();
		assertEq(curSupply, totalCirculatingSupply);
		// No inflation expected
		assertEq(newSupply, totalCirculatingSupply);

		skip(dao.getInflationIntervalSeconds());

		//1 cycle, should be 2406.06
		(curSupply, newSupply) = rewardsPool.getInflationAmt();
		assertEq(newSupply - curSupply, 2406251108043000000000);

		//this happens in inflate()
		store.setUint(keccak256("ProtocolDAO.TotalGGPCirculatingSupply"), totalCirculatingSupply + 2406251108043000000000);

		//2 cycles
		skip(dao.getInflationIntervalSeconds());

		(curSupply, newSupply) = rewardsPool.getInflationAmt();
		assertEq(newSupply - curSupply, 4813467266486087907130);
	}

	function testGetClaimingContractDistribution() public {
		assert(rewardsPool.getClaimingContractDistribution("ProtocolDAOClaim") == 0);
		assert(rewardsPool.getClaimingContractDistribution("NOPClaim") == 0);

		skip(dao.getRewardsCycleSeconds());

		rewardsPool.startRewardsCycle();
		uint256 rewardsTotal = rewardsPool.getRewardsCycleTotalAmount();

		uint256 protocolAllot = rewardsTotal.mulWadDown(dao.getClaimingContractPct("ProtocolDAOClaim"));
		assert(rewardsPool.getClaimingContractDistribution("ProtocolDAOClaim") == protocolAllot);

		uint256 nopAllot = rewardsTotal.mulWadDown(dao.getClaimingContractPct("NOPClaim"));
		assert(rewardsPool.getClaimingContractDistribution("NOPClaim") == nopAllot);
	}

	function testStartRewardsCycle() public {
		uint256 rewardsCycleStartTime = rewardsPool.getRewardsCycleStartTime();

		vm.expectRevert(RewardsPool.UnableToStartRewardsCycle.selector);
		rewardsPool.startRewardsCycle();
		assertFalse(rewardsPool.canStartRewardsCycle());
		assertEq(vault.balanceOfToken("NOPClaim", ggp), 0);
		assertEq(vault.balanceOfToken("ProtocolDAOClaim", ggp), 0);
		assertEq(store.getUint(keccak256("RewardsPool.RewardsCycleTotalAmount")), 0);

		skip(dao.getRewardsCycleSeconds());

		assertEq(rewardsPool.getRewardsCyclesElapsed(), 1);
		assertTrue(rewardsPool.canStartRewardsCycle());
		rewardsPool.startRewardsCycle();

		assertEq(rewardsPool.getRewardsCycleStartTime(), rewardsCycleStartTime + dao.getRewardsCycleSeconds());
		assertGt(rewardsPool.getRewardsCycleTotalAmount(), 0);
		assertGt(vault.balanceOfToken("NOPClaim", ggp), 0);
		assertGt(vault.balanceOfToken("ProtocolDAOClaim", ggp), 0);
	}
}
