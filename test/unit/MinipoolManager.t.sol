pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";
import "../../contracts/contract/Storage.sol";
import "../../contracts/contract/MinipoolManager.sol";
import "../../contracts/contract/MultisigManager.sol";

contract MinipoolManagerTest is GGPTest {
	MinipoolManager private mp;
	MultisigManager private ms;
	address private rialtoAddr;

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

	function setUp() public {
		Storage s = new Storage();
		mp = new MinipoolManager(s);
		ms = new MultisigManager(s);
		registerContract(s, "MultisigManager", address(ms));
		rialtoAddr = vm.addr(RIALTO1_PK);
		ms.addMultisig(rialtoAddr);
		ms.enableMultisig(rialtoAddr);
		initStorage(s);
	}

	function testClaim() public {
		(nodeID, duration) = randMinipool();
		mp.addMinipool(nodeID, duration);
		mp.updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);

		bytes32 nonce = keccak256("0");
		bytes32 msgHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(address(mp), rialtoAddr, nonce)));
		(uint8 v, bytes32 r, bytes32 s) = vm.sign(RIALTO1_PK, msgHash);

		vm.startPrank(rialtoAddr);
		mp.claimAndInitiateStaking(nodeID, nonce, v, r, s);
		vm.expectRevert("Nonce reused");
		mp.claimAndInitiateStaking(nodeID, nonce, v, r, s);
		vm.stopPrank();
		vm.expectRevert("wrong multisig");
		mp.claimAndInitiateStaking(nodeID, nonce, v, r, s);
	}

	function testEmptyState() public {
		index = mp.getIndexOf(NONEXISTANT_NODEID);
		assertEq(index, -1);
		(nodeID, status, duration) = mp.getMinipool(1);
		assertEq(nodeID, ZERO_ADDRESS);
	}

	// Maybe we have testGas... tests that just do a single important operation
	// to make it easier to monitor gas usage
	function testGasAddOne() public {
		(nodeID, duration) = randMinipool();
		startMeasuringGas("testGasAddOne");
		mp.addMinipool(nodeID, duration);
		stopMeasuringGas();
	}

	function testAddAndGetMany() public {
		for (uint256 i = 0; i < 100; i++) {
			(nodeID, duration) = randMinipool();
			mp.addMinipool(nodeID, duration);
		}
		index = mp.getIndexOf(nodeID);
		assertEq(index, 99);
	}

	function testGetStatusCounts() public {
		for (uint256 i = 0; i < 100; i++) {
			(nodeID, duration) = randMinipool();
			mp.addMinipool(nodeID, duration);
		}

		// Get all in one page
		(initialisedCount, prelaunchCount, stakingCount, withdrawableCount, finishedCount, canceledCount) = mp.getMinipoolCountPerStatus(0, 0);
		assertEq(initialisedCount, 100);
		assertEq(prelaunchCount, 0);
		assertEq(stakingCount, 0);
		assertEq(withdrawableCount, 0);
		assertEq(finishedCount, 0);
		assertEq(canceledCount, 0);

		// Test pagination
		(initialisedCount, prelaunchCount, stakingCount, withdrawableCount, finishedCount, canceledCount) = mp.getMinipoolCountPerStatus(0, 10);
		assertEq(initialisedCount, 10);
		(initialisedCount, prelaunchCount, stakingCount, withdrawableCount, finishedCount, canceledCount) = mp.getMinipoolCountPerStatus(90, 10);
		assertEq(initialisedCount, 10);
	}

	function testGetPrelaunchMinipools() public {
		uint256 max = 10;
		address[] memory allNodeIDs = new address[](max);
		uint256 foundCount = 0;
		for (uint256 i = 0; i < max; i++) {
			(nodeID, duration) = randMinipool();
			mp.addMinipool(nodeID, duration);
			// Update every other one to prelaunch status
			if (i % 2 == 0) {
				mp.updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);
				allNodeIDs[foundCount] = nodeID;
				foundCount++;
			}
		}

		(, prelaunchCount, , , , ) = mp.getMinipoolCountPerStatus(0, 0);
		assertEq(prelaunchCount, max / 2);

		MinipoolManager.Node[] memory nodes = mp.getPrelaunchMinipools(0, 0);
		for (uint256 i = 0; i < nodes.length; i++) {
			assertEq(nodes[i].nodeID, allNodeIDs[i]);
		}
	}
}
