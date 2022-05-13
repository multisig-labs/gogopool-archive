pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";
import {ECDSA, MinipoolManager, IMultisigManager} from "../../contracts/contract/MinipoolManager.sol";

contract MinipoolManagerTest is GGPTest {
	int256 private index;
	address private nodeID;
	address private nodeOp;
	uint256 private status;
	uint256 private duration;
	uint256 private delegationFee;
	uint256 private ggpBondAmt;
	uint128 private immutable MAX_AMT = 20000 ether;

	function setUp() public override {
		super.setUp();
		registerMultisig(rialto1);
		nodeOp = getActorWithTokens(1, MAX_AMT, MAX_AMT);
	}

	function testFullCycle_NoUserFunds() public {
		(nodeID, duration, delegationFee) = randMinipool();
		vm.prank(nodeOp);
		minipoolMgr.createMinipool{value: 2000 ether}(nodeID, duration, delegationFee, 2000 ether);
		assertEq(vault.balanceOf("MinipoolManager"), 2000 ether);
		updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);

		vm.startPrank(rialto1);
		uint256 nonce = minipoolMgr.getNonce(rialto1);
		bytes32 msgHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(minipoolMgr), rialto1, nonce)));
		bytes memory sig = signHash(RIALTO1_PK, msgHash);
		minipoolMgr.claimAndInitiateStaking(nodeID, sig);
		assertEq(vault.balanceOf("MinipoolManager"), 0);
		assertEq(rialto1.balance, 2000 ether);

		nonce = minipoolMgr.getNonce(rialto1);
		msgHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(minipoolMgr), rialto1, nonce)));
		sig = signHash(RIALTO1_PK, msgHash);
		minipoolMgr.recordStakingStart(nodeID, sig, block.timestamp);

		nonce = minipoolMgr.getNonce(rialto1);
		msgHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(minipoolMgr), rialto1, nonce)));
		sig = signHash(RIALTO1_PK, msgHash);

		vm.expectRevert(MinipoolManager.InvalidEndTime.selector);
		minipoolMgr.recordStakingEnd{value: 2000 ether}(nodeID, sig, block.timestamp, 0 ether);

		skip(duration);

		vm.expectRevert(MinipoolManager.InvalidAmount.selector);
		minipoolMgr.recordStakingEnd{value: 0 ether}(nodeID, sig, block.timestamp, 0 ether);

		// Give rialto the rewards it needs
		uint256 rewards = 10 ether;
		deal(rialto1, rialto1.balance + rewards);
		minipoolMgr.recordStakingEnd{value: 2010 ether}(nodeID, sig, block.timestamp, 10 ether);
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
		uint256 avaxAmt = store.getUint(keccak256(abi.encodePacked("minipool.item", index, ".avaxAmt")));
		assertEq(avaxAmt, 1 ether);
	}

	function testBondWithGGP() public {
		vm.startPrank(nodeOp);
		(nodeID, duration, delegationFee) = randMinipool();
		minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 1 ether);
		index = minipoolMgr.getIndexOf(nodeID);
		ggpBondAmt = store.getUint(keccak256(abi.encodePacked("minipool.item", index, ".ggpBondAmt")));
		assertEq(ggpBondAmt, 1 ether);
	}

	function testCancelAndReBondWithGGP() public {
		vm.startPrank(nodeOp);
		(nodeID, duration, delegationFee) = randMinipool();
		minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 1 ether);
		index = minipoolMgr.getIndexOf(nodeID);
		ggpBondAmt = store.getUint(keccak256(abi.encodePacked("minipool.item", index, ".ggpBondAmt")));
		assertEq(ggpBondAmt, 1 ether);

		minipoolMgr.cancelMinipool(nodeID);
		(, status, , , ) = minipoolMgr.getMinipool(index);
		assertEq(status, uint256(MinipoolStatus.Canceled));
		assertEq(mockGGP.balanceOf(nodeOp), MAX_AMT);
		assertEq(nodeOp.balance, MAX_AMT);

		minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 1 ether);
		int256 new_index = minipoolMgr.getIndexOf(nodeID);
		assertEq(new_index, index);
		ggpBondAmt = store.getUint(keccak256(abi.encodePacked("minipool.item", index, ".ggpBondAmt")));
		assertEq(ggpBondAmt, 1 ether);
	}

	function testClaimPreventNonceReuse() public {
		(nodeID, duration, delegationFee) = randMinipool();

		vm.prank(nodeOp);
		minipoolMgr.createMinipool{value: 2000 ether}(nodeID, duration, delegationFee, 0);
		updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);

		vm.startPrank(rialto1);
		uint256 nonce = minipoolMgr.getNonce(rialto1);
		bytes32 msgHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(minipoolMgr), rialto1, nonce)));
		bytes memory sig = signHash(RIALTO1_PK, msgHash);
		minipoolMgr.claimAndInitiateStaking(nodeID, sig);
		vm.stopPrank();

		// Now create a new minipool
		(nodeID, duration, delegationFee) = randMinipool();

		vm.prank(nodeOp);
		minipoolMgr.createMinipool{value: 2000 ether}(nodeID, duration, delegationFee, 0);
		updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);

		// Nonce has now been incremented, so the same sig should fail (replay protection)
		vm.expectRevert(IMultisigManager.SignatureInvalid.selector);
		vm.prank(rialto1);
		minipoolMgr.claimAndInitiateStaking(nodeID, sig);
	}

	function testClaimNoUserFunds() public {
		(nodeID, duration, delegationFee) = randMinipool();
		vm.prank(nodeOp);
		minipoolMgr.createMinipool{value: 2000 ether}(nodeID, duration, delegationFee, 2000 ether);

		updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);

		vm.startPrank(rialto1);
		uint256 nonce = minipoolMgr.getNonce(rialto1);
		bytes32 msgHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(minipoolMgr), rialto1, nonce)));
		bytes memory sig = signHash(RIALTO1_PK, msgHash);
		minipoolMgr.claimAndInitiateStaking(nodeID, sig);

		assertEq(rialto1.balance, 2000 ether);
	}

	function testCancelByMultisig() public {
		vm.startPrank(nodeOp);
		(nodeID, duration, delegationFee) = randMinipool();
		minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
		updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);
		vm.stopPrank();

		uint256 nonce = minipoolMgr.getNonce(rialto1);
		bytes32 msgHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(minipoolMgr), rialto1, nonce)));
		bytes memory sig = signHash(RIALTO1_PK, msgHash);
		vm.prank(rialto1);
		minipoolMgr.cancelMinipool(nodeID, sig);
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
	}

	function testEmptyState() public {
		vm.startPrank(nodeOp);
		index = minipoolMgr.getIndexOf(ZERO_ADDRESS);
		assertEq(index, -1);
		(nodeID, status, duration, delegationFee, ggpBondAmt) = minipoolMgr.getMinipool(1);
		assertEq(nodeID, ZERO_ADDRESS);
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
	}

	function testCreateAndGetMany() public {
		vm.startPrank(nodeOp);
		for (uint256 i = 0; i < 10; i++) {
			(nodeID, duration, delegationFee) = randMinipool();
			minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
		}
		index = minipoolMgr.getIndexOf(nodeID);
		assertEq(index, 9);
	}

	function updateMinipoolStatus(address nodeID_, MinipoolStatus newStatus) public {
		int256 i = minipoolMgr.getIndexOf(nodeID_);
		assertTrue((i != -1), "Minipool not found");
		store.setUint(keccak256(abi.encodePacked("minipool.item", i, ".status")), uint256(newStatus));
	}
}
