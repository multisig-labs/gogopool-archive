pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/BaseTest.sol";

contract MinipoolManagerTest is BaseTest {
	int256 private index;
	address private nodeOp;
	uint256 private status;
	uint256 private ggpBondAmt;

	function setUp() public override {
		super.setUp();
		nodeOp = getActorWithTokens("nodeOp", MAX_AMT, MAX_AMT);
	}

	function testExpectedReward() public {
		uint256 amt = minipoolMgr.expectedRewardAmt(365 days, 1_000 ether);
		assertEq(amt, 100 ether);
		amt = minipoolMgr.expectedRewardAmt((365 days / 2), 1_000 ether);
		assertEq(amt, 50 ether);
		amt = minipoolMgr.expectedRewardAmt((365 days / 3), 1_000 ether);
		assertEq(amt, 33333333333333333333);

		// Set 5% annual expected reward rate
		dao.setSettingUint("avalanche.expectedRewardRate", 5e16);
		amt = minipoolMgr.expectedRewardAmt(365 days, 1_000 ether);
		assertEq(amt, 50 ether);
		amt = minipoolMgr.expectedRewardAmt((365 days / 3), 1_000 ether);
		assertEq(amt, 16.666666666666666666 ether);
	}

	function testCalculateSlashAmt() public {
		oracle.setGGPPrice(1 ether, block.timestamp);
		uint256 slashAmt = minipoolMgr.calculateSlashAmt(100 ether);
		assertEq(slashAmt, 100 ether);

		oracle.setGGPPrice(0.5 ether, block.timestamp);
		slashAmt = minipoolMgr.calculateSlashAmt(100 ether);
		assertEq(slashAmt, 200 ether);

		oracle.setGGPPrice(3 ether, block.timestamp);
		slashAmt = minipoolMgr.calculateSlashAmt(100 ether);
		assertEq(slashAmt, 33333333333333333333);
	}

	function testFullCycle_WithUserFunds() public {
		address lilly = getActorWithTokens("lilly", MAX_AMT, MAX_AMT);
		vm.prank(lilly);
		ggAVAX.depositAVAX{value: MAX_AMT}();
		assertEq(lilly.balance, 0);

		uint256 duration = 2 weeks;
		uint256 depositAmt = 1000 ether;
		uint256 avaxAssignmentRequest = 1000 ether;
		uint256 validationAmt = depositAmt + avaxAssignmentRequest;
		uint128 ggpStakeAmt = 200 ether;

		vm.startPrank(nodeOp);
		ggp.approve(address(staking), ggpStakeAmt);
		staking.stakeGGP(ggpStakeAmt);
		MinipoolManager.Minipool memory mp = createMinipool(depositAmt, avaxAssignmentRequest, duration);
		vm.stopPrank();

		assertEq(vault.balanceOf("MinipoolManager"), depositAmt);

		vm.startPrank(rialto);

		minipoolMgr.claimAndInitiateStaking(mp.nodeID);

		assertEq(vault.balanceOf("MinipoolManager"), 0);
		assertEq(rialto.balance, validationAmt);

		bytes32 txID = keccak256("txid");
		minipoolMgr.recordStakingStart(mp.nodeID, txID, block.timestamp);

		vm.expectRevert(MinipoolManager.InvalidEndTime.selector);
		minipoolMgr.recordStakingEnd{value: validationAmt}(mp.nodeID, block.timestamp, 0 ether);

		skip(duration);

		vm.expectRevert(MinipoolManager.InvalidAmount.selector);
		minipoolMgr.recordStakingEnd{value: 0 ether}(mp.nodeID, block.timestamp, 0 ether);

		// // // Give rialto the rewards it needs
		uint256 rewards = 10 ether;
		deal(rialto, rialto.balance + rewards);

		vm.expectRevert(MinipoolManager.InvalidAmount.selector);
		minipoolMgr.recordStakingEnd{value: validationAmt + rewards}(mp.nodeID, block.timestamp, 9 ether);

		//right now rewards are split equally between the node op and user. User provided half the total funds in this test
		minipoolMgr.recordStakingEnd{value: validationAmt + rewards}(mp.nodeID, block.timestamp, 10 ether);
		uint256 commissionFee = (5 ether * 15) / 100;
		//checking the node operators rewards are corrrect
		assertEq(vault.balanceOf("MinipoolManager"), (1005 ether + commissionFee));

		vm.stopPrank();

		///test that the node op can withdraw the funds they are due
		vm.startPrank(nodeOp);
		uint256 priorBalance_nodeOp = nodeOp.balance;

		minipoolMgr.withdrawMinipoolFunds(mp.nodeID);
		assertEq((nodeOp.balance - priorBalance_nodeOp), (1005 ether + commissionFee));
	}

	function testBondZeroGGP() public {
		vm.startPrank(nodeOp);
		address nodeID = randAddress();
		uint256 avaxAssignmentRequest = 1000 ether;

		vm.expectRevert(Staking.StakerNotFound.selector); //no ggp will be staked under the address, so it will fail upon lookup
		minipoolMgr.createMinipool{value: 1000 ether}(nodeID, 0, 0, avaxAssignmentRequest);
		vm.stopPrank();
	}

	function testUndercollateralized() public {
		vm.startPrank(nodeOp);
		address nodeID = randAddress();
		uint256 avaxAmt = 1000 ether;
		uint256 ggpStakeAmt = 50 ether; // 5%
		ggp.approve(address(staking), ggpStakeAmt);
		staking.stakeGGP(ggpStakeAmt);
		vm.expectRevert(MinipoolManager.InsufficientGGPCollateralization.selector); //no ggp will be staked under the address, so it will fail upon lookup
		minipoolMgr.createMinipool{value: avaxAmt}(nodeID, 0, 0, avaxAmt);
		vm.stopPrank();
	}

	// cancelling should cancel the previous avax borrowed counter but right now it doesn't
	// function testCancelAndReBondWithGGP() public {
	// 	uint128 ggpStakeAmt = 100 ether;
	// 	uint256 depositAmt = 1000 ether;
	// 	uint256 avaxAssignmentRequest = 1000 ether;

	// 	(address nodeID, uint256 duration, uint256 delegationFee) = stakeAndCreateMinipool(nodeOp, depositAmt, ggpStakeAmt, avaxAssignmentRequest);
	// 	index = minipoolMgr.getIndexOf(nodeID);
	// 	ggpBondAmt = staking.getGGPStake(nodeOp);
	// 	assertEq(ggpBondAmt, ggpStakeAmt);

	// 	vm.startPrank(nodeOp);
	// 	minipoolMgr.cancelMinipool(nodeID);
	// 	MinipoolManager.Minipool memory mp;
	// 	mp = minipoolMgr.getMinipool(index);

	// 	assertEq(mp.status, uint256(MinipoolStatus.Canceled));
	// 	assertEq(nodeOp.balance, depositAmt);

	// 	minipoolMgr.createMinipool{value: 1000 ether}(nodeID, duration, delegationFee, avaxAssignmentRequest);
	// 	int256 new_index = minipoolMgr.getIndexOf(nodeID);
	// 	assertEq(new_index, index);
	// 	ggpBondAmt = staking.getGGPStake(nodeOp);
	// 	assertEq(ggpBondAmt, ggpStakeAmt);
	// 	vm.stopPrank();
	// }

	function testEmptyState() public {
		vm.startPrank(nodeOp);
		index = minipoolMgr.getIndexOf(ZERO_ADDRESS);
		assertEq(index, -1);
		MinipoolManager.Minipool memory mp;
		mp = minipoolMgr.getMinipool(index);
		assertEq(mp.nodeID, ZERO_ADDRESS);
		vm.stopPrank();
	}

	// Maybe we have testGas... tests that just do a single important operation
	// to make it easier to monitor gas usage
	function testGasCreateMinipool() public {
		uint256 duration = 2 weeks;
		uint256 depositAmt = 1000 ether;
		uint256 avaxAssignmentRequest = 1000 ether;
		uint128 ggpStakeAmt = 200 ether;

		vm.startPrank(nodeOp);
		ggp.approve(address(staking), ggpStakeAmt);
		staking.stakeGGP(ggpStakeAmt);
		startMeasuringGas("testGasCreateMinipool");
		MinipoolManager.Minipool memory mp = createMinipool(depositAmt, avaxAssignmentRequest, duration);
		stopMeasuringGas();
		vm.stopPrank();

		index = minipoolMgr.getIndexOf(mp.nodeID);
		assertFalse(index == -1);
	}

	function testCreateAndGetMany() public {
		vm.startPrank(nodeOp);
		address nodeID;
		uint256 avaxAssignmentRequest = 1000 ether;

		for (uint256 i = 0; i < 10; i++) {
			nodeID = randAddress();
			ggp.approve(address(staking), 100 ether);
			staking.stakeGGP(100 ether);
			minipoolMgr.createMinipool{value: 1000 ether}(nodeID, 0, 0, avaxAssignmentRequest);
		}
		index = minipoolMgr.getIndexOf(nodeID);
		assertEq(index, 9);
		vm.stopPrank();
	}

	function updateMinipoolStatus(address nodeID, MinipoolStatus newStatus) public {
		int256 i = minipoolMgr.getIndexOf(nodeID);
		assertTrue((i != -1), "Minipool not found");
		store.setUint(keccak256(abi.encodePacked("minipool.item", i, ".status")), uint256(newStatus));
	}
}
