pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "./Base.sol";
import "../interface/IStorage.sol";
import "../interface/IMinipoolQueue.sol";

// MiniPool queue storage helper (ring buffer implementation)

contract MinipoolQueue is Base, IMinipoolQueue {
	// Settings
	uint256 public constant CAPACITY = 2**255; // max uint256 / 2

	// Construct
	constructor(IStorage storageAddress) Base(storageAddress) {
		version = 1;
	}

	// Add item to the end of the queue
	function enqueue(address nodeID) external override {
		require(getLength() < CAPACITY - 1, "Queue is at capacity");
		require(getUint(keccak256(abi.encodePacked("minipoolqueue.index", nodeID))) == 0, "NodeID exists in queue");
		uint256 index = getUint(keccak256("minipoolqueue.end"));
		// Save the attrs individually in the k/v store
		setAddress(keccak256(abi.encodePacked("minipoolqueue.item", index, ".nodeID")), nodeID);
		setUint(keccak256(abi.encodePacked("minipoolqueue.index", nodeID)), index + 1);
		index = index + 1;
		if (index >= CAPACITY) {
			index = index - CAPACITY;
		}
		setUint(keccak256("minipoolqueue.end"), index);
	}

	// Remove an item from the start of a queue and return it
	// Requires that the queue is not empty
	function dequeue() external returns (address) {
		require(getLength() > 0, "Queue is empty");
		uint256 index = getUint(keccak256("minipoolqueue.start"));

		address nodeID = getAddress(keccak256(abi.encodePacked("minipoolqueue.item", index, ".nodeID")));
		index = index + 1;
		if (index >= CAPACITY) {
			index = index - CAPACITY;
		}
		setUint(keccak256("minipoolqueue.start"), index);
		return nodeID;
	}

	// HACK Zero out the nodeID, but this will leave an empty spot in queue for Rialto to
	// handle gracefully by dequeueing, then ignoring emptys and dequeueing again
	function cancel(address nodeID) external {
		int256 index = getIndexOf(nodeID);
		if (index != -1) {
			setUint(keccak256(abi.encodePacked("minipoolqueue.index", nodeID)), 0);
			setAddress(keccak256(abi.encodePacked("minipoolqueue.item", index, ".nodeID")), address(0));
		}
	}

	// The number of items in a queue
	function getLength() public view returns (uint256) {
		uint256 start = getUint(keccak256("minipoolqueue.start"));
		uint256 end = getUint(keccak256("minipoolqueue.end"));
		if (end < start) {
			end = end + CAPACITY;
		}
		return end - start;
	}

	// The item in a queue by index
	function getItem(uint256 _index) public view returns (address) {
		uint256 index = getUint(keccak256("minipoolqueue.start")) + _index;
		if (index >= CAPACITY) {
			index = index - CAPACITY;
		}
		return getAddress(keccak256(abi.encodePacked("minipoolqueue.item", index, ".nodeID")));
	}

	// The index of an item in a queue
	// Returns -1 if the value is not found
	function getIndexOf(address _nodeID) public view returns (int256) {
		int256 index = int256(getUint(keccak256(abi.encodePacked("minipoolqueue.index", _nodeID)))) - 1;
		if (index != -1) {
			index -= int256(getUint(keccak256("minipoolqueue.start")));
			if (index < 0) {
				index += int256(CAPACITY);
			}
		}
		return index;
	}
}
