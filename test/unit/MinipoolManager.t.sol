pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";

contract MinipoolManagerTest is GGPTest {
	int256 private index;
	address private nodeID;
	address private nodeOp;
	uint256 private status;
	uint256 private duration;
	uint256 private delegationFee;
	uint256 private ggpBondAmt;
	uint128 private immutable MAX_AMT = 20_000 ether;

	function setUp() public override {
		super.setUp();
		registerMultisig(rialto1);
		nodeOp = getActorWithTokens(1, MAX_AMT, MAX_AMT);
	}

	function testExpectedReward() public {
		uint256 amt = minipoolMgr.expectedRewardAmt(365 days, 1_000 ether);
		assertEq(amt, 100 ether);
		amt = minipoolMgr.expectedRewardAmt((365 days / 2), 1_000 ether);
		assertEq(amt, 50 ether);
		amt = minipoolMgr.expectedRewardAmt((365 days / 3), 1_000 ether);
		assertEq(amt, 33333333333333333000);

		// Set 5% annual expected reward rate
		dao.setSettingUint("avalanche.expectedRewardRate", 5e16);
		amt = minipoolMgr.expectedRewardAmt(365 days, 1_000 ether);
		assertEq(amt, 50 ether);
		amt = minipoolMgr.expectedRewardAmt((365 days / 3), 1_000 ether);
		assertEq(amt, 16.666666666666666 ether);
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

	function testFullCycle_NoUserFunds() public {
		(nodeID, duration, delegationFee) = randMinipool();
		vm.prank(nodeOp);
		minipoolMgr.createMinipool{value: 2000 ether}(nodeID, duration, delegationFee, 2000 ether);
		assertEq(vault.balanceOf("MinipoolManager"), 2000 ether);
		updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);

		vm.startPrank(rialto1);
		// uint256 nonce = minipoolMgr.getNonce(rialto1);
		// bytes32 msgHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(minipoolMgr), rialto1, nonce)));
		// bytes memory sig = signHash(RIALTO1_PK, msgHash);
		minipoolMgr.claimAndInitiateStaking(nodeID);
		assertEq(vault.balanceOf("MinipoolManager"), 0);
		assertEq(rialto1.balance, 2000 ether);

		// nonce = minipoolMgr.getNonce(rialto1);
		// msgHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(minipoolMgr), rialto1, nonce)));
		// sig = signHash(RIALTO1_PK, msgHash);
		bytes32 txID = keccak256("txid");
		minipoolMgr.recordStakingStart(nodeID, txID, block.timestamp);

		// nonce = minipoolMgr.getNonce(rialto1);
		// msgHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(minipoolMgr), rialto1, nonce)));
		// sig = signHash(RIALTO1_PK, msgHash);

		vm.expectRevert(MinipoolManager.InvalidEndTime.selector);
		minipoolMgr.recordStakingEnd{value: 2000 ether}(nodeID, block.timestamp, 0 ether);

		skip(duration);

		vm.expectRevert(MinipoolManager.InvalidAmount.selector);
		minipoolMgr.recordStakingEnd{value: 0 ether}(nodeID, block.timestamp, 0 ether);

		// Give rialto the rewards it needs
		uint256 rewards = 10 ether;
		deal(rialto1, rialto1.balance + rewards);

		vm.expectRevert(MinipoolManager.InvalidAmount.selector);
		minipoolMgr.recordStakingEnd{value: 2010 ether}(nodeID, block.timestamp, 9 ether);

		minipoolMgr.recordStakingEnd{value: 2010 ether}(nodeID, block.timestamp, 10 ether);
		assertEq(vault.balanceOf("MinipoolManager"), 2010 ether);

		vm.stopPrank();
	}

	function testBondZeroGGP() public {
		vm.startPrank(nodeOp);
		(nodeID, duration, delegationFee) = randMinipool();
		minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
		index = minipoolMgr.getIndexOf(nodeID);
		address nodeID_ = store.getAddress(keccak256(abi.encodePacked("minipool.item", index, ".nodeID")));
		assertEq(nodeID_, nodeID);
		ggpBondAmt = store.getUint(keccak256(abi.encodePacked("minipool.item", index, ".ggpBondAmt")));
		assertEq(ggpBondAmt, 0);
		uint256 avaxAmt = store.getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxNodeOpAmt")));
		assertEq(avaxAmt, 1 ether);
		vm.stopPrank();
	}

	function testBondWithGGP() public {
		vm.startPrank(nodeOp);
		(nodeID, duration, delegationFee) = randMinipool();
		minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 1 ether);
		index = minipoolMgr.getIndexOf(nodeID);
		ggpBondAmt = store.getUint(keccak256(abi.encodePacked("minipool.item", index, ".ggpBondAmt")));
		assertEq(ggpBondAmt, 1 ether);
		vm.stopPrank();
	}

	function testCancelAndReBondWithGGP() public {
		vm.startPrank(nodeOp);
		(nodeID, duration, delegationFee) = randMinipool();
		minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 1 ether);
		index = minipoolMgr.getIndexOf(nodeID);
		ggpBondAmt = store.getUint(keccak256(abi.encodePacked("minipool.item", index, ".ggpBondAmt")));
		assertEq(ggpBondAmt, 1 ether);

		minipoolMgr.cancelMinipool(nodeID);
		MinipoolManager.Minipool memory mp;
		mp = minipoolMgr.getMinipool(index);

		assertEq(mp.status, uint256(MinipoolStatus.Canceled));
		assertEq(mockGGP.balanceOf(nodeOp), MAX_AMT);
		assertEq(nodeOp.balance, MAX_AMT);

		minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 1 ether);
		int256 new_index = minipoolMgr.getIndexOf(nodeID);
		assertEq(new_index, index);
		ggpBondAmt = store.getUint(keccak256(abi.encodePacked("minipool.item", index, ".ggpBondAmt")));
		assertEq(ggpBondAmt, 1 ether);
		vm.stopPrank();
	}

	function testClaimNoUserFunds() public {
		(nodeID, duration, delegationFee) = randMinipool();
		vm.prank(nodeOp);
		minipoolMgr.createMinipool{value: 2000 ether}(nodeID, duration, delegationFee, 2000 ether);

		updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);

		vm.startPrank(rialto1);
		minipoolMgr.claimAndInitiateStaking(nodeID);

		assertEq(rialto1.balance, 2000 ether);
		vm.stopPrank();
	}

	function testCancelByOwner() public {
		vm.startPrank(nodeOp);
		(nodeID, duration, delegationFee) = randMinipool();
		minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
		updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);
		minipoolMgr.cancelMinipool(nodeID);
		vm.stopPrank();

		vm.startPrank(rialto1);
		vm.expectRevert(MinipoolManager.OnlyOwnerCanCancel.selector);
		minipoolMgr.cancelMinipool(nodeID);
		vm.stopPrank();
	}

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
		vm.startPrank(nodeOp);
		(nodeID, duration, delegationFee) = randMinipool();
		startMeasuringGas("testGasCreateMinipool");
		minipoolMgr.createMinipool{value: 2000 ether}(nodeID, duration, delegationFee, 2000 ether);
		stopMeasuringGas();
		index = minipoolMgr.getIndexOf(nodeID);
		vm.stopPrank();
	}

	function testCreateAndGetMany() public {
		vm.startPrank(nodeOp);
		for (uint256 i = 0; i < 10; i++) {
			(nodeID, duration, delegationFee) = randMinipool();
			minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
		}
		index = minipoolMgr.getIndexOf(nodeID);
		assertEq(index, 9);
		vm.stopPrank();
	}

	function testGetStatusCounts() public {
		uint256 prelaunchCount;
		uint256 launchedCount;
		uint256 stakingCount;
		uint256 withdrawableCount;
		uint256 finishedCount;
		uint256 canceledCount;

		for (uint256 i = 0; i < 10; i++) {
			(nodeID, duration, delegationFee) = randMinipool();
			minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);

			(nodeID, duration, delegationFee) = randMinipool();
			minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
			minipoolMgr.updateMinipoolStatus(nodeID, MinipoolStatus.Launched);

			(nodeID, duration, delegationFee) = randMinipool();
			minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
			minipoolMgr.updateMinipoolStatus(nodeID, MinipoolStatus.Staking);

			(nodeID, duration, delegationFee) = randMinipool();
			minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
			minipoolMgr.updateMinipoolStatus(nodeID, MinipoolStatus.Withdrawable);

			(nodeID, duration, delegationFee) = randMinipool();
			minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
			minipoolMgr.updateMinipoolStatus(nodeID, MinipoolStatus.Finished);

			(nodeID, duration, delegationFee) = randMinipool();
			minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
			minipoolMgr.updateMinipoolStatus(nodeID, MinipoolStatus.Canceled);
		}

		// Get all in one page
		(prelaunchCount, launchedCount, stakingCount, withdrawableCount, finishedCount, canceledCount) = minipoolMgr.getMinipoolCountPerStatus(0, 0);
		assertEq(prelaunchCount, 10);
		assertEq(launchedCount, 10);
		assertEq(stakingCount, 10);
		assertEq(withdrawableCount, 10);
		assertEq(finishedCount, 10);
		assertEq(canceledCount, 10);

		// Test pagination
		(prelaunchCount, launchedCount, stakingCount, withdrawableCount, finishedCount, canceledCount) = minipoolMgr.getMinipoolCountPerStatus(0, 6);
		assertEq(prelaunchCount, 1);
		assertEq(launchedCount, 1);
		assertEq(stakingCount, 1);
		assertEq(withdrawableCount, 1);
		assertEq(finishedCount, 1);
		assertEq(canceledCount, 1);
	}

	function updateMinipoolStatus(address nodeID_, MinipoolStatus newStatus) public {
		int256 i = minipoolMgr.getIndexOf(nodeID_);
		assertTrue((i != -1), "Minipool not found");
		store.setUint(keccak256(abi.encodePacked("minipool.item", i, ".status")), uint256(newStatus));
	}
}
