pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/BaseTest.sol";
import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";

contract RewardsTest is BaseTest {
	using FixedPointMathLib for uint256;
	// test node IDs
	address public NODE_ID_1 = 0x0000000000000000000000000000000000000001;
	address public NODE_ID_2 = 0x0000000000000000000000000000000000000002;
	address public NODE_ID_3 = 0x0000000000000000000000000000000000000003;

	address private nodeOp;
	address private user1;
	address private nodeID;
	address private withdrawalAddress;
	uint256 private status;
	uint256 private duration;
	uint256 private delegationFee;
	uint256 private constant TOTAL_INITIAL_SUPPLY = 22500000 ether;

	function setUp() public override {
		super.setUp();
		distributeInitialSupply();

		registerMultisig(rialto1);

		nodeOp = getActorWithTokens(1, 20_000 ether, 0);
		user1 = getActorWithTokens(2, 20_000 ether, 0);
		oracle.setGGPPrice(1 ether, block.timestamp);
	}

	function distributeInitialSupply() public {
		// note: guardian is minted 100% of the supply
		vm.startPrank(guardian, guardian);

		uint256 companyAllocation = ((TOTAL_INITIAL_SUPPLY * .32 ether) / 1 ether);
		uint256 pDaoAllo = (TOTAL_INITIAL_SUPPLY * .3233 ether) / 1 ether;
		uint256 seedInvestorAllo = (TOTAL_INITIAL_SUPPLY * .1567 ether) / 1 ether;
		uint256 rewardsPoolAllo = (TOTAL_INITIAL_SUPPLY * .20 ether) / 1 ether;

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

	function testTotalEffectiveStakeNoMinipools() public {
		getGGP(nodeOp, 1000 ether);
		vm.startPrank(nodeOp);
		staking.stakeGGP(1000 ether);

		uint256 totalEffectiveStake = minipoolMgr.getTotalEffectiveGGPStake();
		assertEq(totalEffectiveStake, 0);
		vm.stopPrank();
	}

	function testTotalEffectiveStakeWithMinipool() public {
		getGGP(nodeOp, 1000 ether);
		vm.startPrank(nodeOp);
		staking.stakeGGP(1000 ether);

		(nodeID, duration, delegationFee) = randMinipool();

		minipoolMgr.createMinipool{value: 1000 ether}(nodeID, duration, delegationFee);

		uint256 totalEffectiveStake = minipoolMgr.getTotalEffectiveGGPStake();
		assertEq(totalEffectiveStake, 1000 ether);
		vm.stopPrank();
	}

	function testNodeOpEffectiveStake() public {
		stakeAndCreateMinipool(user1, 2000 ether, 1000 ether);
		stakeAndCreateMinipool(nodeOp, 2000 ether, 1000 ether);

		uint256 totalMinipools = store.getUint(keccak256("minipool.count"));
		assertEq(totalMinipools, 2);

		uint256 totalEffectiveNodeOpStake = minipoolMgr.getNodeEffectiveGGPStake(nodeOp);
		assertEq(totalEffectiveNodeOpStake, 1500 ether);
	}

	function testNodeClaim() public {
		stakeAndCreateMinipool(nodeOp, 2000 ether, 1000 ether);
		uint256 ggpAfterStaking = ggp.balanceOf(nodeOp);

		uint256 totalMinipools = store.getUint(keccak256("minipool.count"));
		assertEq(totalMinipools, 1);

		vm.startPrank(nodeOp);
		vm.expectRevert(bytes("Registered claimer is not registered to claim or has not waited one claim interval"));
		nopClaim.claim();

		// inflation starts one day after deployment
		skip(29 days);
		nopClaim.claim();

		uint256 claimingContractAllowance = rewardsPool.getClaimingContractAllowance("NOPClaim");
		assertEq(ggp.balanceOf(nodeOp) - ggpAfterStaking, claimingContractAllowance);
		vm.stopPrank();
	}

	function testTwoNodesClaim() public {
		stakeAndCreateMinipool(nodeOp, 1000 ether, 1000 ether);
		stakeAndCreateMinipool(user1, 1000 ether, 1000 ether);

		uint256 totalMinipools = store.getUint(keccak256("minipool.count"));
		assertEq(totalMinipools, 2);

		uint256 totalStake = staking.getTotalGGPStake();
		assertEq(totalStake, 2000 ether);

		skip(29 days);

		vm.startPrank(nodeOp);
		nopClaim.claim();

		uint256 claimingContractAllowance = rewardsPool.getClaimingContractAllowance("NOPClaim");
		assertEq(ggp.balanceOf(nodeOp), claimingContractAllowance / 2);
	}

	function testGetInflationCalcTime() public view {
		assert(rewardsPool.getInflationCalcTime() == 0);
	}

	function testGetInflationIntervalTime() public view {
		assert(rewardsPool.getInflationIntervalTime() == 1 days);
	}

	function testGetInflationIntervalRate() public view {
		assert(rewardsPool.getInflationIntervalRate() == uint256(1000133680617113500));
	}

	// TODO figure out how we handle time-based tests like this
	function testGetInflationIntervalStartTime() public view {
		assert(rewardsPool.getInflationIntervalStartTime() == (block.timestamp + 1 days));
	}

	function testGetInflationIntervalsPassed() public view {
		// no inflation intervals have passed
		assert(rewardsPool.getInflationIntervalsPassed() == 0);
	}

	function testInflationCalculate() public view {
		// we haven'ggp minted anything yet,
		// so there should be no inflation
		assert(rewardsPool.inflationCalculate() == 0);
	}
}
