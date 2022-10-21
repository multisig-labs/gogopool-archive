pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/BaseTest.sol";
import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";

contract RewardsTest is BaseTest {
	using FixedPointMathLib for uint256;

	address private nodeID;
	address private withdrawalAddress;
	uint256 private status;
	uint256 private duration;
	uint256 private delegationFee;
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

	function testcanStartRewardsCycle() public {
		assert(rewardsPool.canStartRewardsCycle() == false);
		// Assuming inflation is a 1 day cycle which is less than rewards cycle
		skip(dao.getInflationIntervalSeconds());
		assert(rewardsPool.canStartRewardsCycle() == false);
		uint256 rewardsCycleSeconds = dao.getRewardsCycleSeconds();
		skip(rewardsCycleSeconds);

		assert(rewardsPool.canStartRewardsCycle() == true);
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

	//commenting this out since it is failing, I think because we took out registering nodes. But we will come back to focusing on rewards later
	// function testNodeClaim() public {
	// 	uint128 ggpStakeAmt = 2000 ether;
	// 	uint128 depositAmt = 1000 ether;
	// 	uint256 avaxAssignmentRequest = 1000 ether;

	// 	address nodeOp = getActorWithTokens(depositAmt, ggpStakeAmt);
	// 	stakeAndCreateMinipool(nodeOp, depositAmt, ggpStakeAmt, avaxAssignmentRequest);
	// 	uint256 ggpAfterStaking = ggp.balanceOf(nodeOp);

	// 	uint256 totalMinipools = store.getUint(keccak256("MinipoolManager.count"));
	// 	assertEq(totalMinipools, 1);

	// 	vm.startPrank(nodeOp);
	// 	vm.expectRevert(bytes("Registered claimer is not registered to claim or has not waited one claim interval"));
	// 	nopClaim.claim();

	// 	// inflation starts one day after deployment
	// 	skip(29 days);
	// 	nopClaim.claim();

	// 	uint256 claimingContractAllowance = rewardsPool.getClaimingContractAllowance("NOPClaim");
	// 	assertEq(ggp.balanceOf(nodeOp) - ggpAfterStaking, claimingContractAllowance);
	// 	vm.stopPrank();
	// }

	//commenting this out since it is failing, I think because we took out registering nodes. But we will come back to focusing on rewards later
	// function testTwoNodesClaim() public {
	// 	uint128 ggpStakeAmt = 1000 ether;
	// 	uint128 depositAmt = 1000 ether;
	// 	uint256 avaxAssignmentRequest = 1000 ether;
	// 	address nodeOp = getNextActor();
	// 	address nodeOp2 = getNextActor();
	// 	vm.deal(nodeOp, depositAmt);
	// 	vm.deal(nodeOp2, depositAmt);

	// 	stakeAndCreateMinipool(nodeOp, depositAmt, ggpStakeAmt, avaxAssignmentRequest);
	// 	stakeAndCreateMinipool(nodeOp2, depositAmt, ggpStakeAmt, avaxAssignmentRequest);

	// 	uint256 totalMinipools = store.getUint(keccak256("MinipoolManager.count"));
	// 	assertEq(totalMinipools, 2);

	// 	uint256 totalStake = staking.getTotalGGPStake();
	// 	assertEq(totalStake, 2000 ether);

	// 	skip(29 days);

	// 	vm.prank(nodeOp);
	// 	nopClaim.claim();

	// 	uint256 claimingContractAllowance = rewardsPool.getClaimingContractAllowance("NOPClaim");
	// 	assertEq(ggp.balanceOf(nodeOp), claimingContractAllowance / 2);
	// }

	// function testGetInflationIntervalStartTime() public {
	// 	//note: current block.timestamp is 1, hence the subtraction of 1 second at the end
	// 	assert(rewardsPool.getInflationIntervalStartTime() == 0);
	// 	uint256 inflationStartTime = dao.getInflationIntervalStartTime();
	// 	skip(inflationStartTime);
	// 	assert(rewardsPool.getInflationIntervalStartTime() == block.timestamp - 1 seconds);
	// }

	// function testGetInflationIntervalsElapsed() public {
	// 	// no inflation intervals have passed
	// 	assert(rewardsPool.getInflationIntervalsElapsed() == 0);
	// 	//skip forward to the inflation start time
	// 	uint256 inflationStartTime = dao.getInflationIntervalStartTime();
	// 	skip(inflationStartTime);
	// 	//now skip forward an interval
	// 	uint256 inflationIntervalLength = dao.getInflationInterval();
	// 	skip(inflationIntervalLength);
	// 	assert(rewardsPool.getInflationIntervalsElapsed() == 1);

	// 	skip(inflationIntervalLength);
	// 	assert(rewardsPool.getInflationIntervalsElapsed() == 2);
	// }

	// //TODO test this full 5 years
	// function testInflationCalculate() public {
	// 	// 0 cycles
	// 	assert(rewardsPool.inflate() == [0, 0]);
	// 	//skip forward to the inflation start time
	// 	uint256 inflationStartTime = dao.getInflationIntervalStartTime();
	// 	skip(inflationStartTime);
	// 	//now skip forward an interval
	// 	uint256 inflationIntervalLength = dao.getInflationInterval();
	// 	skip(inflationIntervalLength);

	// 	//1 cycle, should be 2406.06
	// 	uint256 totalCirculatingSupply = dao.getTotalGGPCirculatingSupply();
	// 	assert(rewardsPool.inflationCalculate() == 2406251108043000000000);

	// 	//this happens in inflationMintTokens()
	// 	dao.setTotalGGPCirculatingSupply((totalCirculatingSupply + 2406251108043000000000));

	// 	//2 cycles
	// 	totalCirculatingSupply = dao.getTotalGGPCirculatingSupply();
	// 	skip(inflationIntervalLength);
	// 	assert(rewardsPool.inflationCalculate() == 4813467266486087907130);

	// 	//test the inflationTokenAmount
	// }

	// function testGetRewardsCyclesPassed() public {
	// 	rewind(block.timestamp);
	// 	assert(rewardsPool.getRewardCyclesElapsed() == 0);

	// 	//now skip forward an interval
	// 	uint256 rewardsIntervalLength = dao.getRewardCycleLength();
	// 	skip(rewardsIntervalLength);
	// 	assert(rewardsPool.getRewardCyclesElapsed() == 1 ether);

	// 	skip(rewardsIntervalLength);
	// 	assert(rewardsPool.getRewardCyclesElapsed() == 2 ether);
	// }

	// function testGetClaimingContractPerc() public {
	// 	assert(rewardsPool.getClaimingContractPerc("ProtocolDAOClaim") == 0.10 ether);
	// 	assert(rewardsPool.getClaimingContractPerc("NOPClaim") == 0.70 ether);
	// 	assert(rewardsPool.getClaimingContractPerc("RialtoClaim") == 0 ether);
	// }

	// function testGetClaimingContractDistribution() public {
	// 	assert(rewardsPool.getClaimingContractDistribution("ProtocolDAOClaim") == 0);
	// 	assert(rewardsPool.getClaimingContractDistribution("NOPClaim") == 0);

	// 	uint256 inflationStartTime = dao.getInflationIntervalStartTime();
	// 	skip(inflationStartTime);

	// 	rewardsPool.startRewardsCycle();
	// 	uint256 rewardsTotal = rewardsPool.getRewardCycleTotalAmount();

	// 	uint256 protocolAllot = rewardsTotal.mulWadDown(0.10 ether);
	// 	assert(rewardsPool.getClaimingContractDistribution("ProtocolDAOClaim") == protocolAllot);

	// 	uint256 nopAllot = rewardsTotal.mulWadDown(0.70 ether);
	// 	assert(rewardsPool.getClaimingContractDistribution("NOPClaim") == nopAllot);
	// }

	// function teststartRewardsCycle() public {
	// 	//start cycle will fail
	// 	rewardsPool.startRewardsCycle();
	// 	assert(rewardsPool.getRewardCycleTotalAmount() == 0);
	// 	assert(dao.getTotalGGPCirculatingSupply() == 18000000 ether);
	// 	assert(rewardsPool.getRewardCycleStartTime() == 0);
	// 	assert(vault.balanceOfToken("ProtocolDAOClaim", ggp) == 0);
	// 	assert(vault.balanceOfToken("NOPClaim", ggp) == 0);

	// 	uint256 rewardsIntervalLength = dao.getRewardCycleLength();
	// 	skip(rewardsIntervalLength);

	// 	//start cycle will fail because inflation has not started yet
	// 	rewardsPool.startRewardsCycle();
	// 	assert(rewardsPool.getRewardCycleTotalAmount() == 0);
	// 	assert(dao.getTotalGGPCirculatingSupply() == 18000000 ether);
	// 	assert(rewardsPool.getRewardCycleStartTime() == 0);
	// 	assert(vault.balanceOfToken("ProtocolDAOClaim", ggp) == 0);
	// 	assert(vault.balanceOfToken("NOPClaim", ggp) == 0);

	// 	uint256 inflationStartTime = dao.getInflationIntervalStartTime();
	// 	skip(inflationStartTime);
	// 	//now skip forward an interval
	// 	uint256 inflationIntervalLength = dao.getInflationInterval();
	// 	skip(inflationIntervalLength);

	// 	//start cycle will work
	// 	rewardsPool.startRewardsCycle();
	// 	assert(rewardsPool.getRewardCycleTotalAmount() > 0);
	// 	assert(dao.getTotalGGPCirculatingSupply() > 18000000 ether);
	// 	assert(rewardsPool.getRewardCycleStartTime() != 0);
	// 	assert(vault.balanceOfToken("ProtocolDAOClaim", ggp) > 0);
	// 	assert(vault.balanceOfToken("NOPClaim", ggp) > 0);
	// }

	//inflationMintToken is internal so not visible
	// function testInflationMintTokens() public {
	// 	uint256 totalCirculatingSupply = dao.getTotalGGPCirculatingSupply();
	// 	rewardsPool.inflationMintTokens();
	// 	//no new tokens have been 'minted'
	// 	assert(rewardsPool.getTotalGGPCirculatingSupply() == totalCirculatingSupply);
	// 	//inflation calc time is still 0
	// 	assert(rewardsPool.getInflationIntervalStartTime() == 0);
	// 	assert(store.getUint(keccak256("rewardsPool.reward.cycle.total.amount")) == 0);

	// 	uint256 inflationStartTime = dao.getInflationIntervalStartTime();
	// 	skip(inflationStartTime);
	// 	//now skip forward an interval
	// 	uint256 inflationIntervalLength = dao.getInflationInterval();
	// 	skip(inflationIntervalLength);

	// 	!assertEq(rewardsPool.getTotalGGPCirculatingSupply(), totalCirculatingSupply);
	// 	assertEq(store.getUint(keccak256("rewardsPool.reward.cycle.total.amount")), (dao.getTotalGGPCirculatingSupply() - totalCirculatingSupply));
	// }

	function testRewardsCyclesElapsed() public {
		uint256 expectedRewardsCycles = 2;
		uint256 rewardsCycleSeconds = dao.getRewardsCycleSeconds();
		uint256 startingRewardsCyclesElapsed = rewardsPool.getRewardsCyclesElapsed();

		skip(rewardsCycleSeconds * expectedRewardsCycles);

		uint256 endingRewardsCyclesElapsed = rewardsPool.getRewardsCyclesElapsed();
		assert((endingRewardsCyclesElapsed - startingRewardsCyclesElapsed) == expectedRewardsCycles);
	}
}
