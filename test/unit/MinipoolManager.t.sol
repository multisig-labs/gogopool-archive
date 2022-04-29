pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";

contract MinipoolManagerTest is GGPTest {
	MinipoolManager private mp;
	address private rialto1;

	int256 private index;
	address private nodeID;
	uint256 private status;
	uint256 private duration;
	uint256 private delegationFee;

	function setUp() public {
		(mp, , , ) = initManagers();
		rialto1 = vm.addr(RIALTO1_PK);
	}

	function testClaim() public {
		(nodeID, duration, delegationFee) = randMinipool();
		mp.createMinipool{value: 1 ether}(nodeID, duration, delegationFee);
		mp.updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);

		uint256 nonce = mp.getNonce(rialto1);
		bytes32 msgHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(mp), rialto1, nonce)));
		bytes memory sig = signHash(RIALTO1_PK, msgHash);
		vm.startPrank(rialto1);
		mp.claimAndInitiateStaking(nodeID, sig);
		// Nonce has now been incremented, so the same sig should fail (replay protection)
		vm.expectRevert(IMultisigManager.SignatureInvalid.selector);
		mp.claimAndInitiateStaking(nodeID, sig);

		// Get new nonce and try again
		nonce = mp.getNonce(rialto1);
		msgHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(mp), rialto1, nonce)));
		sig = signHash(RIALTO1_PK, msgHash);
		mp.claimAndInitiateStaking(nodeID, sig);

		// Should fail now that we are not rialtoaddr1
		vm.stopPrank();
		vm.expectRevert(IMinipoolManager.InvalidMultisigAddress.selector);
		mp.claimAndInitiateStaking(nodeID, sig);
	}

	function testCancelByMultisig() public {
		(nodeID, duration, delegationFee) = randMinipool();
		mp.createMinipool{value: 1 ether}(nodeID, duration, delegationFee);
		mp.updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);

		uint256 nonce = mp.getNonce(rialto1);
		bytes32 msgHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(mp), rialto1, nonce)));
		bytes memory sig = signHash(RIALTO1_PK, msgHash);
		vm.prank(rialto1);
		mp.cancelMinipool(nodeID, sig);
	}

	function testCancelByOwner() public {
		(nodeID, duration, delegationFee) = randMinipool();
		mp.createMinipool{value: 1 ether}(nodeID, duration, delegationFee);
		mp.updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);
		mp.cancelMinipool(nodeID);

		vm.startPrank(rialto1);
		vm.expectRevert(IMinipoolManager.OnlyOwnerCanCancel.selector);
		mp.cancelMinipool(nodeID);
	}

	function testEmptyState() public {
		index = mp.getIndexOf(ZERO_ADDRESS);
		assertEq(index, -1);
		(nodeID, status, duration, delegationFee) = mp.getMinipool(1);
		assertEq(nodeID, ZERO_ADDRESS);
	}

	// Maybe we have testGas... tests that just do a single important operation
	// to make it easier to monitor gas usage
	function testGasCreateMinipool() public {
		(nodeID, duration, delegationFee) = randMinipool();
		startMeasuringGas("testGasCreateMinipool");
		mp.createMinipool{value: 1 ether}(nodeID, duration, delegationFee);
		stopMeasuringGas();
	}

	function testCreateAndGetMany() public {
		for (uint256 i = 0; i < 100; i++) {
			(nodeID, duration, delegationFee) = randMinipool();
			mp.createMinipool{value: 1 ether}(nodeID, duration, delegationFee);
		}
		index = mp.getIndexOf(nodeID);
		assertEq(index, 99);
	}
}
