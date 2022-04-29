pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";
import "../../contracts/contract/Storage.sol";
import "../../contracts/contract/MinipoolManager.sol";
import "../../contracts/contract/MultisigManager.sol";

contract MinipoolManagerTest is GGPTest {
	MinipoolManager private mp;
	MultisigManager private ms;
	address private rialtoAddr1;

	// Since these are used in every test, maybe we declare up here?
	uint256 private count;
	uint256 private initialisedCount;
	uint256 private prelaunchCount;
	uint256 private stakingCount;
	uint256 private withdrawableCount;
	uint256 private finishedCount;
	uint256 private canceledCount;
	int256 private index;
	address private nodeID;
	uint256 private status;
	uint256 private duration;
	uint256 private delegationFee;

	function setUp() public {
		Storage s = new Storage();
		mp = new MinipoolManager(s);
		ms = new MultisigManager(s);
		registerContract(s, "MultisigManager", address(ms));
		rialtoAddr1 = vm.addr(RIALTO1_PK);
		ms.registerMultisig(rialtoAddr1);
		ms.enableMultisig(rialtoAddr1);
		initStorage(s);
	}

	function testClaim() public {
		(nodeID, duration, delegationFee) = randMinipool();
		mp.createMinipool(nodeID, duration, delegationFee);
		mp.updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);

		uint256 nonce = mp.getNonce(rialtoAddr1);
		bytes32 msgHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(mp), rialtoAddr1, nonce)));
		bytes memory sig = signHash(RIALTO1_PK, msgHash);
		vm.startPrank(rialtoAddr1);
		mp.claimAndInitiateStaking(nodeID, sig);
		// Nonce has now been incremented, so the same sig should fail (replay protection)
		vm.expectRevert(IMultisigManager.SignatureInvalid.selector);
		mp.claimAndInitiateStaking(nodeID, sig);

		// Get new nonce and try again
		nonce = mp.getNonce(rialtoAddr1);
		msgHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(mp), rialtoAddr1, nonce)));
		sig = signHash(RIALTO1_PK, msgHash);
		mp.claimAndInitiateStaking(nodeID, sig);
		vm.stopPrank();

		// Should fail now that we are not rialtoaddr1
		vm.expectRevert(IMinipoolManager.InvalidMultisigAddress.selector);
		mp.claimAndInitiateStaking(nodeID, sig);
	}

	function testCancelByMultisig() public {
		(nodeID, duration, delegationFee) = randMinipool();
		mp.createMinipool(nodeID, duration, delegationFee);
		mp.updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);

		uint256 nonce = mp.getNonce(rialtoAddr1);
		bytes32 msgHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(mp), rialtoAddr1, nonce)));
		bytes memory sig = signHash(RIALTO1_PK, msgHash);
		vm.startPrank(rialtoAddr1);
		mp.cancelMinipool(nodeID, sig);
	}

	function testCancelByOwner() public {
		(nodeID, duration, delegationFee) = randMinipool();
		mp.createMinipool(nodeID, duration, delegationFee);
		mp.updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);
		mp.cancelMinipool(nodeID);

		vm.startPrank(rialtoAddr1);
		vm.expectRevert(IMinipoolManager.OnlyOwnerCanCancel.selector);
		mp.cancelMinipool(nodeID);
	}

	function testEmptyState() public {
		index = mp.getIndexOf(NONEXISTANT_NODEID);
		assertEq(index, -1);
		(nodeID, status, duration, delegationFee) = mp.getMinipool(1);
		assertEq(nodeID, ZERO_ADDRESS);
	}

	// Maybe we have testGas... tests that just do a single important operation
	// to make it easier to monitor gas usage
	function testGasAddOne() public {
		(nodeID, duration, delegationFee) = randMinipool();
		startMeasuringGas("testGasAddOne");
		mp.createMinipool(nodeID, duration, delegationFee);
		stopMeasuringGas();
	}

	function testAddAndGetMany() public {
		for (uint256 i = 0; i < 100; i++) {
			(nodeID, duration, delegationFee) = randMinipool();
			mp.createMinipool(nodeID, duration, delegationFee);
		}
		index = mp.getIndexOf(nodeID);
		assertEq(index, 99);
	}
}
