pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";

// Try to understand how forge sets addresses
contract ExperimentTest1 is GGPTest {
	function setUp() public view {
		console.log("ExperimentTest1 setup tx.origin", tx.origin);
		console.log("ExperimentTest1 setup msg.sender", msg.sender);
		console.log("ExperimentTest1 setup this", address(this));
	}

	function testExperiment1() public view {
		console.log("ExperimentTest1 func tx.origin", tx.origin);
		console.log("ExperimentTest1 func msg.sender", msg.sender);
		console.log("ExperimentTest1 func this", address(this));
	}
}

contract ExperimentTest2 is GGPTest {
	function setUp() public view {
		console.log("ExperimentTest2 setup tx.origin", tx.origin);
		console.log("ExperimentTest2 setup msg.sender", msg.sender);
		console.log("ExperimentTest2 setup this", address(this));
	}

	function testExperiment2() public view {
		console.log("ExperimentTest2 func tx.origin", tx.origin);
		console.log("ExperimentTest2 func msg.sender", msg.sender);
		console.log("ExperimentTest2 func this", address(this));
	}
}
