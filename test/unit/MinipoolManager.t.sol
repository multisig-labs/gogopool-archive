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

	function setUp() public override {
		super.setUp();
		registerMultisig(rialto1);
		nodeOp = getActorWithTokens(1, 10 ether, 10 ether);
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
		assertEq(mockGGP.balanceOf(nodeOp), 10 ether);
		assertEq(nodeOp.balance, 10 ether);
	}

	function testClaim() public {
		vm.startPrank(nodeOp);
		(nodeID, duration, delegationFee) = randMinipool();
		minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
		minipoolMgr.updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);

		uint256 nonce = minipoolMgr.getNonce(rialto1);
		bytes32 msgHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(minipoolMgr), rialto1, nonce)));
		bytes memory sig = signHash(RIALTO1_PK, msgHash);
		vm.stopPrank();

		vm.startPrank(rialto1);
		minipoolMgr.claimAndInitiateStaking(nodeID, sig);
		// Nonce has now been incremented, so the same sig should fail (replay protection)
		vm.expectRevert(IMultisigManager.SignatureInvalid.selector);
		minipoolMgr.claimAndInitiateStaking(nodeID, sig);

		// Get new nonce and try again
		nonce = minipoolMgr.getNonce(rialto1);
		msgHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(minipoolMgr), rialto1, nonce)));
		sig = signHash(RIALTO1_PK, msgHash);
		minipoolMgr.claimAndInitiateStaking(nodeID, sig);

		// Should fail now that we are not rialtoaddr1
		vm.stopPrank();
		vm.expectRevert(MinipoolManager.InvalidMultisigAddress.selector);
		minipoolMgr.claimAndInitiateStaking(nodeID, sig);
	}

	function testCancelByMultisig() public {
		vm.startPrank(nodeOp);
		(nodeID, duration, delegationFee) = randMinipool();
		minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
		minipoolMgr.updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);
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
		minipoolMgr.updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);
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
		(nodeID, duration, delegationFee) = randMinipool();
		startMeasuringGas("testGasCreateMinipool");
		minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
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
}
