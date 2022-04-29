pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";
import "../../contracts/contract/Storage.sol";
import "../../contracts/contract/LaunchManager.sol";
import "../../contracts/contract/MultisigManager.sol";

contract LaunchManagerTest is GGPTest {
	LaunchManager private lm;
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

	function setUp() public {
		Storage s = new Storage();

		lm = new LaunchManager(s);
		registerContract(s, "LaunchManager", address(lm));

		ms = new MultisigManager(s);
		registerContract(s, "MultisigManager", address(ms));

		rialtoAddr1 = vm.addr(RIALTO1_PK);
		ms.registerMultisig(rialtoAddr1);
		ms.enableMultisig(rialtoAddr1);
		initStorage(s);
	}

	// function ZtestGetStatusCounts() public {
	// 	for (uint256 i = 0; i < 100; i++) {
	// 		(nodeID, duration) = randMinipool();
	// 		mp.registerMinipool(nodeID, duration);
	// 	}

	// 	// Get all in one page
	// 	(initialisedCount, prelaunchCount, stakingCount, withdrawableCount, finishedCount, canceledCount) = mp.getMinipoolCountPerStatus(0, 0);
	// 	assertEq(initialisedCount, 100);
	// 	assertEq(prelaunchCount, 0);
	// 	assertEq(stakingCount, 0);
	// 	assertEq(withdrawableCount, 0);
	// 	assertEq(finishedCount, 0);
	// 	assertEq(canceledCount, 0);

	// 	// Test pagination
	// 	(initialisedCount, prelaunchCount, stakingCount, withdrawableCount, finishedCount, canceledCount) = mp.getMinipoolCountPerStatus(0, 10);
	// 	assertEq(initialisedCount, 10);
	// 	(initialisedCount, prelaunchCount, stakingCount, withdrawableCount, finishedCount, canceledCount) = mp.getMinipoolCountPerStatus(90, 10);
	// 	assertEq(initialisedCount, 10);
	// }

	// function ZtestGetPrelaunchMinipools() public {
	// 	uint256 max = 10;
	// 	address[] memory allNodeIDs = new address[](max);
	// 	uint256 foundCount = 0;
	// 	for (uint256 i = 0; i < max; i++) {
	// 		(nodeID, duration) = randMinipool();
	// 		mp.registerMinipool(nodeID, duration);
	// 		// Update every other one to prelaunch status
	// 		if (i % 2 == 0) {
	// 			mp.updateMinipoolStatus(nodeID, MinipoolStatus.Prelaunch);
	// 			allNodeIDs[foundCount] = nodeID;
	// 			foundCount++;
	// 		}
	// 	}

	// 	(, prelaunchCount, , , , ) = mp.getMinipoolCountPerStatus(0, 0);
	// 	assertEq(prelaunchCount, max / 2);

	// 	LaunchManager.Node[] memory nodes = mp.getPrelaunchMinipools(0, 0);
	// 	for (uint256 i = 0; i < nodes.length; i++) {
	// 		assertEq(nodes[i].nodeID, allNodeIDs[i]);
	// 	}
	// }
}
