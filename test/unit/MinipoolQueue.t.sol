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
		require(minipoolQueue.getLength() == 0, "length should be zero");
	}

	function testEnqueue() public {
		// enqueue the first node
		minipoolQueue.enqueue(NODE_ID_1);

		// check the length
		require(minipoolQueue.getLength() == 1, "length should be one");
	}

	function testDequeue() public {
		// enqueue the first node
		minipoolQueue.enqueue(NODE_ID_1);

		// check the length
		require(minipoolQueue.getLength() == 1, "length should be one");

		// dequeue the first node
		bytes32 nodeId = minipoolQueue.dequeue();

		// check the length
		require(minipoolQueue.getLength() == 0, "length should be zero");

		// check the node ID
		require(nodeId == NODE_ID_1, "node ID should be node_1");
	}

	function testIndexOf() public {
		// enqueue the first node
		minipoolQueue.enqueue(NODE_ID_1);

		// check the length
		require(minipoolQueue.getLength() == 1, "length should be one");

		// check the index of the first node
		require(minipoolQueue.getIndexOf(NODE_ID_1) == 0, "index should be zero");
	}

	function testGetItem() public {
		// enqueue the first node
		minipoolQueue.enqueue(NODE_ID_1);

		// check the length
		require(minipoolQueue.getLength() == 1, "length should be one");

		// check the index of the first node
		require(minipoolQueue.getIndexOf(NODE_ID_1) == 0, "index should be zero");

		// check the node ID
		require(minipoolQueue.getItem(0) == NODE_ID_1, "node ID should be node_1");
	}
}
