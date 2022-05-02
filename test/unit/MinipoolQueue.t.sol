pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";

contract MinipoolQueueTest is GGPTest {
	// test node IDs
	bytes32 private constant NODE_ID_1 = keccak256("node_1");
	bytes32 private constant NODE_ID_2 = keccak256("node_2");

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
		bytes32 nodeId = minipoolQueue.dequeue();

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
}
