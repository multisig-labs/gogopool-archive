pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/BaseTest.sol";
import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";

contract MinipoolManagerTest is BaseTest {
	using FixedPointMathLib for uint256;
	int256 private index;
	address private nodeOp;
	uint256 private status;
	uint256 private ggpBondAmt;

	function setUp() public override {
		super.setUp();
		nodeOp = getActorWithTokens("nodeOp", MAX_AMT, MAX_AMT);
	}

	function testGetTotalAVAXLiquidStakerAmt() public {
		address nodeOp2 = getActorWithTokens("nodeOp", MAX_AMT, MAX_AMT);
		address liqStaker1 = getActorWithTokens("liqStaker1", 4000 ether, 0);
		vm.prank(liqStaker1);
		ggAVAX.depositAVAX{value: 4000 ether}();

		assert(minipoolMgr.getTotalAVAXLiquidStakerAmt() == 0);

		vm.startPrank(nodeOp);
		ggp.approve(address(staking), MAX_AMT);
		staking.stakeGGP(200 ether);
		MinipoolManager.Minipool memory mp1 = createMinipool(1000 ether, 1000 ether, 2 weeks);
		vm.stopPrank();
		vm.prank(rialto);
		minipoolMgr.claimAndInitiateStaking(mp1.nodeID);
		assert(minipoolMgr.getTotalAVAXLiquidStakerAmt() == 1000 ether);

		vm.prank(nodeOp);
		MinipoolManager.Minipool memory mp2 = createMinipool(1000 ether, 1000 ether, 2 weeks);
		vm.prank(rialto);
		minipoolMgr.claimAndInitiateStaking(mp2.nodeID);
		assert(minipoolMgr.getTotalAVAXLiquidStakerAmt() == 2000 ether);

		vm.startPrank(nodeOp2);
		ggp.approve(address(staking), MAX_AMT);
		staking.stakeGGP(100 ether);
		MinipoolManager.Minipool memory mp3 = createMinipool(1000 ether, 1000 ether, 2 weeks);
		vm.stopPrank();
		vm.prank(rialto);
		minipoolMgr.claimAndInitiateStaking(mp3.nodeID);
		assert(minipoolMgr.getTotalAVAXLiquidStakerAmt() == 3000 ether);
	}

	function testCreateMinipool() public {
		address nodeID = address(1);
		uint256 duration = 2 weeks;
		uint256 delegationFee = 20;
		uint256 avaxAssignmentRequest = 1000 ether;
		uint256 nopAvaxAmount = 1000 ether;

		uint256 vaultOriginalBalance = vault.balanceOf("MinipoolManager");

		assert(minipoolMgr.getMinipoolCount() == 0);

		//fail
		vm.startPrank(nodeOp);
		vm.expectRevert(MinipoolManager.InvalidNodeID.selector);
		minipoolMgr.createMinipool{value: nopAvaxAmount}(address(0), duration, delegationFee, avaxAssignmentRequest);

		//fail
		vm.expectRevert(MinipoolManager.InvalidAVAXAssignmentRequest.selector);
		minipoolMgr.createMinipool{value: nopAvaxAmount}(nodeID, duration, delegationFee, 2000 ether);

		//fail
		vm.expectRevert(MinipoolManager.InvalidAVAXAssignmentRequest.selector);
		minipoolMgr.createMinipool{value: 2000 ether}(nodeID, duration, delegationFee, avaxAssignmentRequest);

		//fail
		vm.expectRevert(Staking.StakerNotFound.selector);
		minipoolMgr.createMinipool{value: nopAvaxAmount}(nodeID, duration, delegationFee, avaxAssignmentRequest);

		//fail
		ggp.approve(address(staking), MAX_AMT);
		staking.stakeGGP(50 ether);
		vm.expectRevert(MinipoolManager.InsufficientGGPCollateralization.selector);
		minipoolMgr.createMinipool{value: nopAvaxAmount}(nodeID, duration, delegationFee, avaxAssignmentRequest);

		staking.stakeGGP(50 ether);
		minipoolMgr.createMinipool{value: nopAvaxAmount}(nodeID, duration, delegationFee, avaxAssignmentRequest);

		//check vault balance to increase by 1000 ether
		assert(vault.balanceOf("MinipoolManager") - vaultOriginalBalance == nopAvaxAmount);

		int256 stakerIndex = staking.getIndexOf(address(nodeOp));
		Staking.Staker memory staker = staking.getStaker(stakerIndex);
		assert(staker.avaxStaked == avaxAssignmentRequest);
		assert(staker.avaxAssigned == nopAvaxAmount);
		assert(staker.minipoolCount == 1);
		assert(staker.rewardsStartTime != 0);

		int256 minipoolIndex = minipoolMgr.getIndexOf(nodeID);
		MinipoolManager.Minipool memory mp = minipoolMgr.getMinipool(minipoolIndex);

		assert(mp.nodeID == nodeID);
		assert(mp.status == uint256(MinipoolStatus.Prelaunch));
		assert(mp.duration == duration);
		assert(mp.delegationFee == delegationFee);
		assert(mp.avaxLiquidStakerAmt == avaxAssignmentRequest);
		assert(mp.avaxNodeOpAmt == nopAvaxAmount);
		assert(mp.owner == address(nodeOp));

		//check that making the same minipool with this id will reset the minipool data
		minipoolMgr.cancelMinipool(nodeID);
		minipoolMgr.createMinipool{value: nopAvaxAmount}(nodeID, 3 weeks, delegationFee, avaxAssignmentRequest);
		int256 minipoolIndex1 = minipoolMgr.getIndexOf(nodeID);
		MinipoolManager.Minipool memory mp1 = minipoolMgr.getMinipool(minipoolIndex1);
		assert(mp1.nodeID == nodeID);
		assert(mp1.status == uint256(MinipoolStatus.Prelaunch));
		assert(mp1.duration == 3 weeks);
		assert(mp1.delegationFee == delegationFee);
		assert(mp1.avaxLiquidStakerAmt == avaxAssignmentRequest);
		assert(mp1.avaxNodeOpAmt == nopAvaxAmount);
		assert(mp1.owner == address(nodeOp));
	}

	function testCancelMinipool() public {
		address nodeID = address(1);
		uint256 duration = 2 weeks;
		uint256 delegationFee = 20;
		uint256 avaxAssignmentRequest = 1000 ether;
		uint256 nopAvaxAmount = 1000 ether;

		vm.startPrank(nodeOp);
		ggp.approve(address(staking), MAX_AMT);
		staking.stakeGGP(100 ether);
		minipoolMgr.createMinipool{value: nopAvaxAmount}(nodeID, duration, delegationFee, avaxAssignmentRequest);

		int256 minipoolIndex = minipoolMgr.getIndexOf(nodeID);
		MinipoolManager.Minipool memory mp = minipoolMgr.getMinipool(minipoolIndex);

		assert(mp.nodeID == nodeID);
		assert(mp.status == uint256(MinipoolStatus.Prelaunch));
		assert(mp.duration == duration);
		assert(mp.delegationFee == delegationFee);
		assert(mp.avaxLiquidStakerAmt == avaxAssignmentRequest);
		assert(mp.avaxNodeOpAmt == nopAvaxAmount);
		assert(mp.owner == address(nodeOp));
	}

	function testWithdrawMinipoolFunds() public {
		address liqStaker1 = getActorWithTokens("liqStaker1", MAX_AMT, MAX_AMT);
		vm.prank(liqStaker1);
		ggAVAX.depositAVAX{value: MAX_AMT}();

		uint256 duration = 2 weeks;
		uint256 depositAmt = 1000 ether;
		uint256 avaxAssignmentRequest = 1000 ether;
		uint256 validationAmt = depositAmt + avaxAssignmentRequest;
		uint128 ggpStakeAmt = 200 ether;

		vm.startPrank(nodeOp);
		ggp.approve(address(staking), MAX_AMT);
		staking.stakeGGP(200 ether);
		MinipoolManager.Minipool memory mp1 = createMinipool(depositAmt, avaxAssignmentRequest, duration);
		vm.stopPrank();

		vm.startPrank(rialto);
		minipoolMgr.claimAndInitiateStaking(mp1.nodeID);
		bytes32 txID = keccak256("txid");
		minipoolMgr.recordStakingStart(mp1.nodeID, txID, block.timestamp);
		skip(duration);
		uint256 rewards = 10 ether;
		deal(rialto, rialto.balance + rewards);
		minipoolMgr.recordStakingEnd{value: validationAmt + rewards}(mp1.nodeID, block.timestamp, 10 ether);
		uint256 percentage = dao.getMinipoolNodeCommissionFeePct();
		uint256 commissionFee = (percentage).mulWadDown(5 ether);
		vm.stopPrank();

		vm.startPrank(nodeOp);
		uint256 priorBalanceNodeOp = nodeOp.balance;
		minipoolMgr.withdrawMinipoolFunds(mp1.nodeID);
		assertEq((nodeOp.balance - priorBalanceNodeOp), (1005 ether + commissionFee));
	}

	function testCanClaimAndInitiateStaking() public {
		uint256 duration = 2 weeks;
		uint256 depositAmt = 1000 ether;
		uint256 avaxAssignmentRequest = 1000 ether;
		uint256 validationAmt = depositAmt + avaxAssignmentRequest;
		uint128 ggpStakeAmt = 200 ether;

		vm.startPrank(nodeOp);
		ggp.approve(address(staking), MAX_AMT);
		staking.stakeGGP(200 ether);
		MinipoolManager.Minipool memory mp1 = createMinipool(depositAmt, avaxAssignmentRequest, duration);

		//will fail
		vm.expectRevert(MinipoolManager.InvalidMultisigAddress.selector);
		minipoolMgr.canClaimAndInitiateStaking(mp1.nodeID);
		vm.stopPrank();

		//will fail
		int256 minipoolIndex = minipoolMgr.getIndexOf(mp1.nodeID);
		store.setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Error));
		vm.prank(rialto);
		vm.expectRevert(MinipoolManager.InvalidStateTransition.selector);
		minipoolMgr.canClaimAndInitiateStaking(mp1.nodeID);
		store.setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Prelaunch));

		//will fail
		vm.prank(rialto);
		assert(minipoolMgr.canClaimAndInitiateStaking(mp1.nodeID) == false);

		address liqStaker1 = getActorWithTokens("liqStaker1", MAX_AMT, MAX_AMT);
		vm.prank(liqStaker1);
		ggAVAX.depositAVAX{value: MAX_AMT}();

		vm.prank(rialto);
		assert(minipoolMgr.canClaimAndInitiateStaking(mp1.nodeID) == true);
	}

	function testClaimAndInitiateStaking() public {
		uint256 duration = 2 weeks;
		uint256 depositAmt = 1000 ether;
		uint256 avaxAssignmentRequest = 1000 ether;
		uint256 validationAmt = depositAmt + avaxAssignmentRequest;
		uint128 ggpStakeAmt = 200 ether;

		vm.startPrank(nodeOp);
		ggp.approve(address(staking), MAX_AMT);
		staking.stakeGGP(200 ether);
		MinipoolManager.Minipool memory mp1 = createMinipool(depositAmt, avaxAssignmentRequest, duration);

		//will fail
		vm.expectRevert(MinipoolManager.InvalidMultisigAddress.selector);
		minipoolMgr.claimAndInitiateStaking(mp1.nodeID);
		vm.stopPrank();

		//will fail
		int256 minipoolIndex = minipoolMgr.getIndexOf(mp1.nodeID);
		store.setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Error));
		vm.prank(rialto);
		vm.expectRevert(MinipoolManager.InvalidStateTransition.selector);
		minipoolMgr.claimAndInitiateStaking(mp1.nodeID);
		store.setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Prelaunch));

		//will fail
		vm.prank(rialto);
		vm.expectRevert(TokenggAVAX.WithdrawAmountTooLarge.selector);
		minipoolMgr.claimAndInitiateStaking(mp1.nodeID);

		address liqStaker1 = getActorWithTokens("liqStaker1", MAX_AMT, MAX_AMT);
		vm.prank(liqStaker1);
		ggAVAX.depositAVAX{value: MAX_AMT}();

		uint256 originalMMbalance = vault.balanceOf("MinipoolManager");

		uint256 originalGGAVAXBalance = ggAVAX.amountAvailableForStaking();
		assert(rialto.balance == 0);

		vm.prank(rialto);
		minipoolMgr.claimAndInitiateStaking(mp1.nodeID);
		MinipoolManager.Minipool memory mp1Updated = minipoolMgr.getMinipool(minipoolIndex);
		assert(mp1Updated.status == uint256(MinipoolStatus.Launched));
		assert(rialto.balance == (depositAmt + avaxAssignmentRequest));
		assert(originalMMbalance - vault.balanceOf("MinipoolManager") == depositAmt);
		assert((originalGGAVAXBalance - ggAVAX.amountAvailableForStaking()) == avaxAssignmentRequest);
	}

	function testRecordStakingStart() public {
		uint256 duration = 2 weeks;
		uint256 depositAmt = 1000 ether;
		uint256 avaxAssignmentRequest = 1000 ether;
		uint256 validationAmt = depositAmt + avaxAssignmentRequest;
		uint128 ggpStakeAmt = 200 ether;

		vm.startPrank(nodeOp);
		ggp.approve(address(staking), MAX_AMT);
		staking.stakeGGP(200 ether);
		MinipoolManager.Minipool memory mp1 = createMinipool(depositAmt, avaxAssignmentRequest, duration);
		vm.stopPrank();

		address liqStaker1 = getActorWithTokens("liqStaker1", MAX_AMT, MAX_AMT);
		vm.prank(liqStaker1);
		ggAVAX.depositAVAX{value: MAX_AMT}();

		vm.prank(rialto);
		minipoolMgr.claimAndInitiateStaking(mp1.nodeID);

		bytes32 txID = keccak256("txid");

		//will fail
		vm.expectRevert(MinipoolManager.InvalidMultisigAddress.selector);
		minipoolMgr.recordStakingStart(mp1.nodeID, txID, block.timestamp);

		//will fail
		int256 minipoolIndex = minipoolMgr.getIndexOf(mp1.nodeID);
		store.setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Error));
		vm.prank(rialto);
		vm.expectRevert(MinipoolManager.InvalidStateTransition.selector);
		minipoolMgr.recordStakingStart(mp1.nodeID, txID, block.timestamp);
		store.setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Launched));

		vm.prank(rialto);
		minipoolMgr.recordStakingStart(mp1.nodeID, txID, block.timestamp);
		MinipoolManager.Minipool memory mp1Updated = minipoolMgr.getMinipool(minipoolIndex);
		assert(mp1Updated.status == uint256(MinipoolStatus.Staking));
		assert(mp1Updated.txID == txID);
		assert(mp1Updated.startTime != 0);
	}

	function testRecordStakingEnd() public {
		uint256 duration = 2 weeks;
		uint256 depositAmt = 1000 ether;
		uint256 avaxAssignmentRequest = 1000 ether;
		uint256 validationAmt = depositAmt + avaxAssignmentRequest;
		uint128 ggpStakeAmt = 200 ether;

		vm.startPrank(nodeOp);
		ggp.approve(address(staking), MAX_AMT);
		staking.stakeGGP(200 ether);
		MinipoolManager.Minipool memory mp1 = createMinipool(depositAmt, avaxAssignmentRequest, duration);
		vm.stopPrank();

		address liqStaker1 = getActorWithTokens("liqStaker1", MAX_AMT, MAX_AMT);
		vm.prank(liqStaker1);
		ggAVAX.depositAVAX{value: MAX_AMT}();

		vm.prank(rialto);
		minipoolMgr.claimAndInitiateStaking(mp1.nodeID);

		bytes32 txID = keccak256("txid");
		vm.prank(rialto);
		minipoolMgr.recordStakingStart(mp1.nodeID, txID, block.timestamp);

		//will fail
		vm.expectRevert(MinipoolManager.InvalidMultisigAddress.selector);
		minipoolMgr.recordStakingEnd{value: validationAmt}(mp1.nodeID, block.timestamp, 0 ether);

		//will fail
		int256 minipoolIndex = minipoolMgr.getIndexOf(mp1.nodeID);
		store.setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Error));
		vm.prank(rialto);
		vm.expectRevert(MinipoolManager.InvalidStateTransition.selector);
		minipoolMgr.recordStakingEnd{value: validationAmt}(mp1.nodeID, block.timestamp, 0 ether);
		store.setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Staking));

		vm.startPrank(rialto);
		vm.expectRevert(MinipoolManager.InvalidEndTime.selector);
		minipoolMgr.recordStakingEnd{value: validationAmt}(mp1.nodeID, block.timestamp, 0 ether);

		skip(duration);

		vm.expectRevert(MinipoolManager.InvalidAmount.selector);
		minipoolMgr.recordStakingEnd{value: 0 ether}(mp1.nodeID, block.timestamp, 0 ether);

		// // // Give rialto the rewards it needs
		uint256 rewards = 10 ether;
		deal(rialto, rialto.balance + rewards);

		vm.expectRevert(MinipoolManager.InvalidAmount.selector);
		minipoolMgr.recordStakingEnd{value: validationAmt + rewards}(mp1.nodeID, block.timestamp, 9 ether);

		//right now rewards are split equally between the node op and user. User provided half the total funds in this test
		minipoolMgr.recordStakingEnd{value: validationAmt + rewards}(mp1.nodeID, block.timestamp, 10 ether);
		uint256 commissionFee = (5 ether * 15) / 100;
		//checking the node operators rewards are corrrect
		assert(vault.balanceOf("MinipoolManager") == (1005 ether + commissionFee));

		MinipoolManager.Minipool memory mp1Updated = minipoolMgr.getMinipool(minipoolIndex);
		assert(mp1Updated.status == uint256(MinipoolStatus.Withdrawable));
		assert(mp1Updated.avaxTotalRewardAmt == 10 ether);
		assert(mp1Updated.endTime != 0);
		assert(mp1Updated.avaxNodeOpRewardAmt == (5 ether + commissionFee));
		assert(mp1Updated.avaxLiquidStakerRewardAmt == (5 ether - commissionFee));

		assert(minipoolMgr.getTotalAVAXLiquidStakerAmt() == 0);

		assert(staking.getAVAXAssigned(mp1Updated.owner) == 0);
		assert(staking.getMinipoolCount(mp1Updated.owner) == 0);
	}

	function testRecordStakingEndWithSlash() public {
		uint256 duration = 2 weeks;
		uint256 depositAmt = 1000 ether;
		uint256 avaxAssignmentRequest = 1000 ether;
		uint256 validationAmt = depositAmt + avaxAssignmentRequest;
		uint128 ggpStakeAmt = 200 ether;

		vm.startPrank(nodeOp);
		ggp.approve(address(staking), MAX_AMT);
		staking.stakeGGP(ggpStakeAmt);
		MinipoolManager.Minipool memory mp1 = createMinipool(depositAmt, avaxAssignmentRequest, duration);
		vm.stopPrank();

		address liqStaker1 = getActorWithTokens("liqStaker1", MAX_AMT, MAX_AMT);
		vm.prank(liqStaker1);
		ggAVAX.depositAVAX{value: MAX_AMT}();

		vm.prank(rialto);
		minipoolMgr.claimAndInitiateStaking(mp1.nodeID);

		bytes32 txID = keccak256("txid");
		vm.prank(rialto);
		minipoolMgr.recordStakingStart(mp1.nodeID, txID, block.timestamp);

		//will fail
		vm.expectRevert(MinipoolManager.InvalidMultisigAddress.selector);
		minipoolMgr.recordStakingEnd{value: validationAmt}(mp1.nodeID, block.timestamp, 0 ether);

		//will fail
		int256 minipoolIndex = minipoolMgr.getIndexOf(mp1.nodeID);
		store.setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Error));
		vm.prank(rialto);
		vm.expectRevert(MinipoolManager.InvalidStateTransition.selector);
		minipoolMgr.recordStakingEnd{value: validationAmt}(mp1.nodeID, block.timestamp, 0 ether);
		store.setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Staking));

		vm.startPrank(rialto);
		vm.expectRevert(MinipoolManager.InvalidEndTime.selector);
		minipoolMgr.recordStakingEnd{value: validationAmt}(mp1.nodeID, block.timestamp, 0 ether);

		skip(duration);

		vm.expectRevert(MinipoolManager.InvalidAmount.selector);
		minipoolMgr.recordStakingEnd{value: 0 ether}(mp1.nodeID, block.timestamp, 0 ether);

		// // // Give rialto the rewards it needs
		uint256 rewards = 10 ether;
		deal(rialto, rialto.balance + rewards);

		vm.expectRevert(MinipoolManager.InvalidAmount.selector);
		minipoolMgr.recordStakingEnd{value: validationAmt + rewards}(mp1.nodeID, block.timestamp, 9 ether);

		//right now rewards are split equally between the node op and user. User provided half the total funds in this test
		minipoolMgr.recordStakingEnd{value: validationAmt}(mp1.nodeID, block.timestamp, 0 ether);
		uint256 commissionFee = (5 ether * 15) / 100;

		assert(vault.balanceOf("MinipoolManager") == (1000 ether));

		MinipoolManager.Minipool memory mp1Updated = minipoolMgr.getMinipool(minipoolIndex);
		assert(mp1Updated.status == uint256(MinipoolStatus.Withdrawable));
		assert(mp1Updated.avaxTotalRewardAmt == 0);
		assert(mp1Updated.endTime != 0);

		assert(mp1Updated.avaxNodeOpRewardAmt == 0);
		assert(mp1Updated.avaxLiquidStakerRewardAmt == 0);

		assert(minipoolMgr.getTotalAVAXLiquidStakerAmt() == 0);

		assert(staking.getAVAXAssigned(mp1Updated.owner) == 0);
		assert(staking.getMinipoolCount(mp1Updated.owner) == 0);

		assert(mp1Updated.ggpSlashAmt > 0);
		assert(staking.getGGPStake(mp1Updated.owner) < ggpStakeAmt);
	}

	function testRecordStakingError() public {
		uint256 duration = 2 weeks;
		uint256 depositAmt = 1000 ether;
		uint256 avaxAssignmentRequest = 1000 ether;
		uint256 validationAmt = depositAmt + avaxAssignmentRequest;
		uint128 ggpStakeAmt = 200 ether;

		vm.startPrank(nodeOp);
		ggp.approve(address(staking), MAX_AMT);
		staking.stakeGGP(ggpStakeAmt);
		MinipoolManager.Minipool memory mp1 = createMinipool(depositAmt, avaxAssignmentRequest, duration);
		vm.stopPrank();

		address liqStaker1 = getActorWithTokens("liqStaker1", MAX_AMT, MAX_AMT);
		vm.prank(liqStaker1);
		ggAVAX.depositAVAX{value: MAX_AMT}();

		vm.prank(rialto);
		minipoolMgr.claimAndInitiateStaking(mp1.nodeID);

		bytes32 txID = keccak256("txid");
		vm.prank(rialto);
		minipoolMgr.recordStakingStart(mp1.nodeID, txID, block.timestamp);

		bytes32 errorCode = "INVALID_NODEID";

		//will fail
		vm.expectRevert(MinipoolManager.InvalidMultisigAddress.selector);
		minipoolMgr.recordStakingError{value: validationAmt}(mp1.nodeID, errorCode);

		//will fail
		vm.startPrank(rialto);
		int256 minipoolIndex = minipoolMgr.getIndexOf(mp1.nodeID);
		store.setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Prelaunch));
		vm.expectRevert(MinipoolManager.InvalidStateTransition.selector);
		minipoolMgr.recordStakingError{value: validationAmt}(mp1.nodeID, errorCode);
		store.setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Staking));

		vm.expectRevert(MinipoolManager.InvalidAmount.selector);
		minipoolMgr.recordStakingError{value: 0 ether}(mp1.nodeID, errorCode);

		minipoolMgr.recordStakingError{value: validationAmt}(mp1.nodeID, errorCode);

		assert(vault.balanceOf("MinipoolManager") == depositAmt);

		MinipoolManager.Minipool memory mp1Updated = minipoolMgr.getMinipool(minipoolIndex);
		assert(mp1Updated.status == uint256(MinipoolStatus.Error));
		assert(mp1Updated.avaxTotalRewardAmt == 0);
		assert(mp1Updated.errorCode == errorCode);
		assert(mp1Updated.avaxNodeOpRewardAmt == 0);
		assert(mp1Updated.avaxLiquidStakerRewardAmt == 0);

		assert(minipoolMgr.getTotalAVAXLiquidStakerAmt() == 0);

		assert(staking.getAVAXAssigned(mp1Updated.owner) == 0);
	}

	function testCancelMinipoolByMultisig() public {
		uint256 duration = 2 weeks;
		uint256 depositAmt = 1000 ether;
		uint256 avaxAssignmentRequest = 1000 ether;
		uint256 validationAmt = depositAmt + avaxAssignmentRequest;
		uint128 ggpStakeAmt = 200 ether;

		vm.startPrank(nodeOp);
		ggp.approve(address(staking), MAX_AMT);
		staking.stakeGGP(ggpStakeAmt);
		MinipoolManager.Minipool memory mp1 = createMinipool(depositAmt, avaxAssignmentRequest, duration);
		vm.stopPrank();

		uint256 priorBalance = nodeOp.balance;

		bytes32 errorCode = "INVALID_NODEID";

		vm.expectRevert(MinipoolManager.InvalidMultisigAddress.selector);
		minipoolMgr.cancelMinipoolByMultisig(mp1.nodeID, errorCode);

		vm.startPrank(rialto);
		int256 minipoolIndex = minipoolMgr.getIndexOf(mp1.nodeID);
		store.setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Staking));
		vm.expectRevert(MinipoolManager.InvalidStateTransition.selector);
		minipoolMgr.cancelMinipoolByMultisig(mp1.nodeID, errorCode);
		store.setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Prelaunch));

		minipoolMgr.cancelMinipoolByMultisig(mp1.nodeID, errorCode);

		MinipoolManager.Minipool memory mp1Updated = minipoolMgr.getMinipool(minipoolIndex);
		assert(mp1Updated.status == uint256(MinipoolStatus.Canceled));
		assert(mp1Updated.errorCode == errorCode);

		assert(minipoolMgr.getTotalAVAXLiquidStakerAmt() == 0);

		assert(staking.getAVAXAssigned(mp1Updated.owner) == 0);
		assert(staking.getAVAXStake(mp1Updated.owner) == 0);
		assert(staking.getMinipoolCount(mp1Updated.owner) == 0);

		assert(nodeOp.balance - priorBalance == depositAmt);
	}

	function testExpectedRewards() public {
		uint256 amt = minipoolMgr.expectedAVAXRewardsAmt(365 days, 1_000 ether);
		assertEq(amt, 100 ether);
		amt = minipoolMgr.expectedAVAXRewardsAmt((365 days / 2), 1_000 ether);
		assertEq(amt, 50 ether);
		amt = minipoolMgr.expectedAVAXRewardsAmt((365 days / 3), 1_000 ether);
		assertEq(amt, 33333333333333333333);

		// Set 5% annual expected rewards rate
		dao.setExpectedAVAXRewardsRate(5e16);
		amt = minipoolMgr.expectedAVAXRewardsAmt(365 days, 1_000 ether);
		assertEq(amt, 50 ether);
		amt = minipoolMgr.expectedAVAXRewardsAmt((365 days / 3), 1_000 ether);
		assertEq(amt, 16.666666666666666666 ether);
	}

	function testGetMinipool() public {
		address nodeID = address(1);
		uint256 duration = 2 weeks;
		uint256 delegationFee = 20;
		uint256 avaxAssignmentRequest = 1000 ether;
		uint256 nopAvaxAmount = 1000 ether;

		vm.startPrank(nodeOp);
		ggp.approve(address(staking), MAX_AMT);
		staking.stakeGGP(100 ether);
		minipoolMgr.createMinipool{value: nopAvaxAmount}(nodeID, duration, delegationFee, avaxAssignmentRequest);

		int256 minipoolIndex = minipoolMgr.getIndexOf(nodeID);
		MinipoolManager.Minipool memory mp = minipoolMgr.getMinipool(minipoolIndex);

		assert(mp.nodeID == nodeID);
		assert(mp.status == uint256(MinipoolStatus.Prelaunch));
		assert(mp.duration == duration);
		assert(mp.delegationFee == delegationFee);
		assert(mp.avaxLiquidStakerAmt == avaxAssignmentRequest);
		assert(mp.avaxNodeOpAmt == nopAvaxAmount);
		assert(mp.owner == address(nodeOp));
	}

	function testGetMinipools() public {
		vm.startPrank(nodeOp, nodeOp);
		address nodeID;
		uint256 avaxAssignmentRequest = 1000 ether;

		for (uint256 i = 0; i < 10; i++) {
			nodeID = randAddress();
			ggp.approve(address(staking), 100 ether);
			staking.stakeGGP(100 ether);
			minipoolMgr.createMinipool{value: 1000 ether}(nodeID, 0, 0, avaxAssignmentRequest);
		}
		vm.stopPrank();

		index = minipoolMgr.getIndexOf(nodeID);
		assertEq(index, 9);

		MinipoolManager.Minipool[] memory mps = minipoolMgr.getMinipools(MinipoolStatus.Prelaunch, 0, 0);
		assert(mps.length == 10);

		vm.startPrank(rialto);
		for (uint256 i = 0; i < 5; i++) {
			int256 minipoolIndex = minipoolMgr.getIndexOf(mps[i].nodeID);
			store.setUint(keccak256(abi.encodePacked("minipool.item", minipoolIndex, ".status")), uint256(MinipoolStatus.Launched));
		}
		MinipoolManager.Minipool[] memory mps1 = minipoolMgr.getMinipools(MinipoolStatus.Launched, 0, 0);
		assert(mps1.length == 5);

		vm.stopPrank();
	}

	function testGetMinipoolCount() public {
		vm.startPrank(nodeOp, nodeOp);
		address nodeID;
		uint256 avaxAssignmentRequest = 1000 ether;

		for (uint256 i = 0; i < 10; i++) {
			nodeID = randAddress();
			ggp.approve(address(staking), 100 ether);
			staking.stakeGGP(100 ether);
			minipoolMgr.createMinipool{value: 1000 ether}(nodeID, 0, 0, avaxAssignmentRequest);
		}
		vm.stopPrank();
		assert(minipoolMgr.getMinipoolCount() == 10);
	}

	function testCalculateSlashAmt() public {
		vm.prank(rialto);
		oracle.setGGPPrice(1 ether, block.timestamp);
		uint256 slashAmt = minipoolMgr.calculateSlashAmt(100 ether);
		assertEq(slashAmt, 100 ether);

		vm.prank(rialto);
		oracle.setGGPPrice(0.5 ether, block.timestamp);
		slashAmt = minipoolMgr.calculateSlashAmt(100 ether);
		assertEq(slashAmt, 200 ether);

		vm.prank(rialto);
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

		vm.startPrank(nodeOp, nodeOp);
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

	function testFullCycle_Error() public {
		address lilly = getActorWithTokens("lilly", MAX_AMT, MAX_AMT);
		vm.prank(lilly);
		ggAVAX.depositAVAX{value: MAX_AMT}();
		assertEq(lilly.balance, 0);

		uint256 duration = 2 weeks;
		uint256 depositAmt = 1000 ether;
		uint256 avaxAssignmentRequest = 1000 ether;
		uint256 validationAmt = depositAmt + avaxAssignmentRequest;
		uint128 ggpStakeAmt = 200 ether;
		uint256 amountAvailForStaking = ggAVAX.amountAvailableForStaking();

		vm.startPrank(nodeOp, nodeOp);
		ggp.approve(address(staking), ggpStakeAmt);
		staking.stakeGGP(ggpStakeAmt);
		MinipoolManager.Minipool memory mp = createMinipool(depositAmt, avaxAssignmentRequest, duration);
		vm.stopPrank();

		assertEq(vault.balanceOf("MinipoolManager"), depositAmt);

		vm.startPrank(rialto);

		minipoolMgr.claimAndInitiateStaking(mp.nodeID);

		assertEq(vault.balanceOf("MinipoolManager"), 0);
		assertEq(rialto.balance, validationAmt);
		assertEq(minipoolMgr.getTotalAVAXLiquidStakerAmt(), avaxAssignmentRequest);

		// Assume something goes wrong and we are unable to launch a minipool

		bytes32 errorCode = "INVALID_NODEID";

		// Expect revert on sending wrong amt
		vm.expectRevert(MinipoolManager.InvalidAmount.selector);
		minipoolMgr.recordStakingError{value: 0}(mp.nodeID, errorCode);

		// Now send correct amt
		minipoolMgr.recordStakingError{value: validationAmt}(mp.nodeID, errorCode);
		assertEq(rialto.balance, 0);
		// NodeOps funds should be back in vault
		assertEq(vault.balanceOf("MinipoolManager"), depositAmt);
		// Liq stakers funds should be returned
		assertEq(ggAVAX.amountAvailableForStaking(), amountAvailForStaking);
		assertEq(minipoolMgr.getTotalAVAXLiquidStakerAmt(), 0);

		mp = minipoolMgr.getMinipool(mp.index);
		assertEq(mp.status, uint256(MinipoolStatus.Error));
		assertEq(mp.errorCode, errorCode);
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
		vm.startPrank(nodeOp, nodeOp);
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

		vm.startPrank(nodeOp, nodeOp);
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
		vm.startPrank(nodeOp, nodeOp);
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
		vm.prank(guardian);
		store.setUint(keccak256(abi.encodePacked("MinipoolManager.item", i, ".status")), uint256(newStatus));
	}
}
