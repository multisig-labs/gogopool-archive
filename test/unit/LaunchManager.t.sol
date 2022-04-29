pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";

contract LaunchManagerTest is GGPTest {
	LaunchManager private lm;
	MinipoolManager private mp;
	address private rialto1;

	int256 private index;
	address private nodeID;
	uint256 private status;
	uint256 private duration;
	uint256 private delegationFee;

	function setUp() public {
		(mp, , lm, ) = initManagers();
		rialto1 = vm.addr(RIALTO1_PK);
	}

	function initMinipools() public {
		for (uint256 i = 0; i < 10; i++) {
			(nodeID, duration, delegationFee) = randMinipool();
			mp.createMinipool{value: 1 ether}(nodeID, duration, delegationFee);
		}
		for (uint256 i = 0; i < 10; i++) {
			(nodeID, duration, delegationFee) = randMinipool();
			mp.createMinipool{value: 1 ether}(nodeID, duration, delegationFee);
			mp.updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);
		}
	}

	function testGetStatusCounts() public {
		uint256 initialisedCount;
		uint256 prelaunchCount;
		uint256 stakingCount;
		uint256 withdrawableCount;
		uint256 finishedCount;
		uint256 canceledCount;

		for (uint256 i = 0; i < 100; i++) {
			(nodeID, duration, delegationFee) = randMinipool();
			mp.createMinipool{value: 1 ether}(nodeID, duration, delegationFee);
		}

		// Get all in one page
		(initialisedCount, prelaunchCount, stakingCount, withdrawableCount, finishedCount, canceledCount) = lm.getMinipoolCountPerStatus(0, 0);
		assertEq(initialisedCount, 100);
		assertEq(prelaunchCount, 0);
		assertEq(stakingCount, 0);
		assertEq(withdrawableCount, 0);
		assertEq(finishedCount, 0);
		assertEq(canceledCount, 0);

		// Test pagination
		(initialisedCount, prelaunchCount, stakingCount, withdrawableCount, finishedCount, canceledCount) = lm.getMinipoolCountPerStatus(0, 10);
		assertEq(initialisedCount, 10);
		(initialisedCount, prelaunchCount, stakingCount, withdrawableCount, finishedCount, canceledCount) = lm.getMinipoolCountPerStatus(90, 10);
		assertEq(initialisedCount, 10);
	}

	function testGetPrelaunchMinipools() public {
		uint256 prelaunchCount;

		uint256 max = 10;
		address[] memory allNodeIDs = new address[](max);
		uint256 foundCount = 0;
		for (uint256 i = 0; i < max; i++) {
			(nodeID, duration, delegationFee) = randMinipool();
			mp.createMinipool{value: 1 ether}(nodeID, duration, delegationFee);
			// Update every other one to prelaunch status
			if (i % 2 == 0) {
				mp.updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);
				allNodeIDs[foundCount] = nodeID;
				foundCount++;
			}
		}

		(, prelaunchCount, , , , ) = lm.getMinipoolCountPerStatus(0, 0);
		assertEq(prelaunchCount, max / 2);

		LaunchManager.Node[] memory nodes = lm.getPrelaunchMinipools(0, 0);
		for (uint256 i = 0; i < nodes.length; i++) {
			assertEq(nodes[i].nodeID, allNodeIDs[i]);
		}
	}
}
