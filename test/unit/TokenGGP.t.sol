pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";

contract TokenGGPTest is GGPTest {
	function setUp() public override {
		super.setUp();
	}

	// **
	// ** Sanity Checks **
	// **

	// get inflation calc time
	function testGetInflationCalcTime() public view {
		assert(ggp.getInflationCalcTime() == 0);
	}

	function testGetInflationIntervalTime() public view {
		assert(ggp.getInflationIntervalTime() == 1 days);
	}

	function testGetInflationIntervalRate() public view {
		assert(ggp.getInflationIntervalRate() == uint256(1000133680617113500));
	}

	// TODO figure out how we handle time-based tests like this
	function testGetInflationIntervalStartTime() public view {
		assert(ggp.getInflationIntervalStartTime() == (block.timestamp + 1 days));
	}

	function testGetInflationIntervalsPassed() public view {
		// no inflation intervals have passed
		assert(ggp.getInflationIntervalsPassed() == 0);
	}

	function testInflationCalculate() public view {
		// we haven'ggp minted anything yet,
		// so there should be no inflation
		assert(ggp.inflationCalculate() == 0);
	}
}
