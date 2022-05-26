pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./Base.sol";
import "../interface/IStorage.sol";

// Delegation queue storage helper (ring buffer implementation)
// Based off the Minipool queue

contract BaseQueue is Base {
	// Settings
	uint256 public constant CAPACITY = 2**255; // max uint256 / 2

	// Construct
	constructor(IStorage storageAddress) Base(storageAddress) {
		version = 1;
	}

	// Add item to the end of the queue
	function enqueue(bytes32 key, address nodeID) external {
		require(getLength(key) < CAPACITY - 1, "Queue is at capacity");
		require(getUint(keccak256(abi.encodePacked(key, ".index", nodeID))) == 0, "NodeID exists in queue");
		uint256 index = getUint(keccak256(abi.encodePacked(key, ".end")));
		// Save the attrs individually in the k/v store
		setAddress(keccak256(abi.encodePacked(key, ".item", index, ".nodeID")), nodeID);
		setUint(keccak256(abi.encodePacked(key, ".index", nodeID)), index + 1);
		index = index + 1;
		if (index >= CAPACITY) {
			index = index - CAPACITY;
		}
		setUint(keccak256(abi.encodePacked(key, ".end")), index);
	}

	// Remove an item from the start of a queue and return it
	// Requires that the queue is not empty
	// Skip any nodeIDs that were canceled
	function dequeue(bytes32 key) external returns (address) {
		require(getLength(key) > 0, "Queue is empty");
		uint256 index = getUint(keccak256(abi.encodePacked(key, ".start")));
		address nodeID;

		do {
			nodeID = getAddress(keccak256(abi.encodePacked(key, ".item", index, ".nodeID")));
			index = index + 1;
			if (index >= CAPACITY) {
				index = index - CAPACITY;
			}
		} while (nodeID == address(0));

		setUint(keccak256(abi.encodePacked(key, ".start")), index);
		return nodeID;
	}

	// HACK Zero out the nodeID, but this will leave an empty spot in queue for dequeue to handle
	function cancel(bytes32 key, address nodeID) external {
		int256 index = getIndexOf(key, nodeID);
		if (index != -1) {
			setUint(keccak256(abi.encodePacked(key, ".index", nodeID)), 0);
			setAddress(keccak256(abi.encodePacked(key, ".item", index, ".nodeID")), address(0));
		}
	}

	// The number of items in a queue
	function getLength(bytes32 key) public view returns (uint256) {
		uint256 start = getUint(keccak256(abi.encodePacked(key, ".start")));
		uint256 end = getUint(keccak256(abi.encodePacked(key, ".end")));
		if (end < start) {
			end = end + CAPACITY;
		}
		return end - start;
	}

	// The item in a queue by index
	function getItem(bytes32 key, uint256 _index) public view returns (address) {
		uint256 index = getUint(keccak256(abi.encodePacked(key, ".start"))) + _index;
		if (index >= CAPACITY) {
			index = index - CAPACITY;
		}
		return getAddress(keccak256(abi.encodePacked(key, ".item", index, ".nodeID")));
	}

	// The index of an item in a queue
	// Returns -1 if the value is not found
	function getIndexOf(bytes32 key, address _nodeID) public view returns (int256) {
		int256 index = int256(getUint(keccak256(abi.encodePacked(key, ".index", _nodeID)))) - 1;
		if (index != -1) {
			index -= int256(getUint(keccak256(abi.encodePacked(key, ".start"))));
			if (index < 0) {
				index += int256(CAPACITY);
			}
		}
		return index;
	}
}
