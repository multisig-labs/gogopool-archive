pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";

contract MinipoolQueueTest is GGPTest {
	// test node IDs
	address public NODE_ID_1 = 0x0000000000000000000000000000000000000001;

	function setUp() public override {
		super.setUp();
	}

	function testEmpty() public {
		assertEq(minipoolQueue.getLength(), 0);
	}

	function testEnqueue() public {
		// enqueue the first node
		minipoolQueue.enqueue(NODE_ID_1);

		// check the length
		assertEq(minipoolQueue.getLength(), 1);
	}

	function testDequeue() public {
		// enqueue the first node
		minipoolQueue.enqueue(NODE_ID_1);

		// check the length
		assertEq(minipoolQueue.getLength(), 1);

		// dequeue the first node
		address nodeId = minipoolQueue.dequeue();

		// check the length
		assertEq(minipoolQueue.getLength(), 0);

		// check the node ID
		assertEq(nodeId, NODE_ID_1);
	}

	function testIndexOf() public {
		// enqueue the first node
		minipoolQueue.enqueue(NODE_ID_1);

		// check the length
		assertEq(minipoolQueue.getLength(), 1);

		// check the index of the first node
		assertEq(minipoolQueue.getIndexOf(NODE_ID_1), 0);
	}

	function testGetItem() public {
		// enqueue the first node
		minipoolQueue.enqueue(NODE_ID_1);

		// check the length
		assertEq(minipoolQueue.getLength(), 1);

		// check the index of the first node
		assertEq(minipoolQueue.getIndexOf(NODE_ID_1), 0);

		// check the node ID
		assertEq(minipoolQueue.getItem(0), NODE_ID_1);
	}

	function testManyPools(uint256 x) public {
		vm.assume(x <= 1000);
		vm.assume(x > 0);
		// add x pools to the queue
		for (uint256 i = 0; i < x; i++) {
			minipoolQueue.enqueue(randAddress());
		}

		// check the length
		assertEq(minipoolQueue.getLength(), x);

		// get a random uint
		uint256 index = randUint(x);

		// try to access it
		address nodeId = minipoolQueue.getItem(index);

		// check its index
		assertEq(minipoolQueue.getIndexOf(nodeId), int256(index));
	}
}
