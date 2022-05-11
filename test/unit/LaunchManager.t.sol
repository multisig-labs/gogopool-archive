pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";

contract LaunchManagerTest is GGPTest {
	int256 private index;
	address private nodeID;
	uint256 private status;
	uint256 private duration;
	uint256 private delegationFee;

	function setUp() public override {
		super.setUp();
	}

	function testGetStatusCounts() public {
		uint256 initialisedCount;
		uint256 prelaunchCount;
		uint256 stakingCount;
		uint256 withdrawableCount;
		uint256 finishedCount;
		uint256 canceledCount;

		for (uint256 i = 0; i < 10; i++) {
			(nodeID, duration, delegationFee) = randMinipool();
			minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);

			(nodeID, duration, delegationFee) = randMinipool();
			minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
			minipoolMgr.updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);

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
		(initialisedCount, prelaunchCount, stakingCount, withdrawableCount, finishedCount, canceledCount) = launchMgr.getMinipoolCountPerStatus(0, 0);
		assertEq(initialisedCount, 10);
		assertEq(prelaunchCount, 10);
		assertEq(stakingCount, 10);
		assertEq(withdrawableCount, 10);
		assertEq(finishedCount, 10);
		assertEq(canceledCount, 10);

		// Test pagination
		(initialisedCount, prelaunchCount, stakingCount, withdrawableCount, finishedCount, canceledCount) = launchMgr.getMinipoolCountPerStatus(0, 6);
		assertEq(initialisedCount, 1);
		assertEq(prelaunchCount, 1);
		assertEq(stakingCount, 1);
		assertEq(withdrawableCount, 1);
		assertEq(finishedCount, 1);
		assertEq(canceledCount, 1);
	}

	function testGetPrelaunchMinipools() public {
		uint256 prelaunchCount;

		uint256 max = 10;
		address[] memory allNodeIDs = new address[](max);
		uint256 foundCount = 0;
		for (uint256 i = 0; i < max; i++) {
			(nodeID, duration, delegationFee) = randMinipool();
			minipoolMgr.createMinipool{value: 1 ether}(nodeID, duration, delegationFee, 0);
			// Update every other one to prelaunch status
			if (i % 2 == 0) {
				minipoolMgr.updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);
				allNodeIDs[foundCount] = nodeID;
				foundCount++;
			}
		}

		(, prelaunchCount, , , , ) = launchMgr.getMinipoolCountPerStatus(0, 0);
		assertEq(prelaunchCount, max / 2);

		LaunchManager.Node[] memory nodes = launchMgr.getPrelaunchMinipools(0, 0);
		for (uint256 i = 0; i < nodes.length; i++) {
			assertEq(nodes[i].nodeID, allNodeIDs[i]);
		}
	}
}
