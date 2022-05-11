pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";
import {ECDSA, MinipoolManager, IMultisigManager} from "../../contracts/contract/MinipoolManager.sol";

contract MinipoolManagerTest is GGPTest {
	int256 private index;
	address private nodeID;
	uint256 private status;
	uint256 private duration;
	uint256 private delegationFee;

	function setUp() public override {
		super.setUp();
		registerMultisig(rialto1);
	}

	function testBond() public {
		address nodeOp = getActorWithTokens(1, 10 ether, 10 ether);
		vm.startPrank(nodeOp);
		(nodeID, duration, delegationFee) = randMinipool();
		minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
		minipoolMgr.bondMinipool(nodeID, 100);
		index = minipoolMgr.getIndexOf(nodeID);
		uint256 ggpBondAmt = store.getUint(keccak256(abi.encodePacked("minipool.item", index, ".ggpBondAmt")));
		assertEq(ggpBondAmt, 100);
	}

	function testClaim() public {
		(nodeID, duration, delegationFee) = randMinipool();
		minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
		minipoolMgr.updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);

		uint256 nonce = minipoolMgr.getNonce(rialto1);
		bytes32 msgHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(minipoolMgr), rialto1, nonce)));
		bytes memory sig = signHash(RIALTO1_PK, msgHash);
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
		(nodeID, duration, delegationFee) = randMinipool();
		minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
		minipoolMgr.updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);

		uint256 nonce = minipoolMgr.getNonce(rialto1);
		bytes32 msgHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(minipoolMgr), rialto1, nonce)));
		bytes memory sig = signHash(RIALTO1_PK, msgHash);
		vm.prank(rialto1);
		minipoolMgr.cancelMinipool(nodeID, sig);
	}

	function testCancelByOwner() public {
		(nodeID, duration, delegationFee) = randMinipool();
		minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
		minipoolMgr.updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);
		minipoolMgr.cancelMinipool(nodeID);

		vm.startPrank(rialto1);
		vm.expectRevert(MinipoolManager.OnlyOwnerCanCancel.selector);
		minipoolMgr.cancelMinipool(nodeID);
	}

	function testEmptyState() public {
		index = minipoolMgr.getIndexOf(ZERO_ADDRESS);
		assertEq(index, -1);
		(nodeID, status, duration, delegationFee) = minipoolMgr.getMinipool(1);
		assertEq(nodeID, ZERO_ADDRESS);
	}

	// Maybe we have testGas... tests that just do a single important operation
	// to make it easier to monitor gas usage
	function testGasCreateMinipool() public {
		(nodeID, duration, delegationFee) = randMinipool();
		startMeasuringGas("testGasCreateMinipool");
		minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
		stopMeasuringGas();
	}

	function testCreateAndGetMany() public {
		for (uint256 i = 0; i < 100; i++) {
			(nodeID, duration, delegationFee) = randMinipool();
			minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
		}
		index = minipoolMgr.getIndexOf(nodeID);
		assertEq(index, 99);
	}
}
