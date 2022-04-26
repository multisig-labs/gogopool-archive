pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";
import "../../contracts/contract/Storage.sol";

contract StorageTest is GGPTest {
	address private constant NEWGUARDIAN = address(0xDEADBEEF);
	bytes32 private constant KEY = keccak256("test.key");

	Storage private s;

	function testGuardian() public {
		s = new Storage();
		hevm.label(address(s), "Storage");
		// Storage() was executed by "this", so it is the guardian to start
		assertEq(s.getGuardian(), address(this));
		// We start out in an undeployed state while everything gets set up
		assertBoolEq(s.getDeployedStatus(), false);

		// Change the guardian
		s.setGuardian(NEWGUARDIAN);
		// Should not change yet, must be confirmed
		assertEq(s.getGuardian(), address(this));
		// Impersonate an address
		hevm.startPrank(NEWGUARDIAN);
		s.confirmGuardian();
		assertEq(s.getGuardian(), NEWGUARDIAN);
		s.setString(KEY, "test");
		assertEq(s.getString(KEY), "test");
	}

	// Accepting params will fuzz the test
	function testStorageFuzz(int256 i) public {
		s = new Storage();
		s.setInt(KEY, i);
		assertEq(s.getInt(KEY), i);
	}

	// A test named *Fail* is expected to fail
	function testFailStorage() public {
		s = new Storage();
		hevm.prank(ZERO_ADDRESS);
		s.setInt(KEY, 1);
	}
}
