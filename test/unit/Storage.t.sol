pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";
import "../../contracts/contract/Storage.sol";

contract StorageTest is GGPTest {
	address private constant NEWGUARDIAN = address(0xDEADBEEF);
	bytes32 private constant KEY = keccak256("test.key");

	function setUp() public override {
		super.setUp();
	}

	function testGuardian() public {
		// Storage() was created by guardian in setup, so it is the guardian to start
		assertEq(store.getGuardian(), GUARDIAN);
		// We start out in an undeployed state while everything gets set up
		assertBoolEq(store.getDeployedStatus(), false);

		// Change the guardian
		vm.prank(GUARDIAN, GUARDIAN);
		store.setGuardian(NEWGUARDIAN);
		// Should not change yet, must be confirmed
		assertEq(store.getGuardian(), GUARDIAN);

		// Impersonate an address
		vm.startPrank(NEWGUARDIAN, NEWGUARDIAN);
		store.confirmGuardian();
		assertEq(store.getGuardian(), NEWGUARDIAN);
		store.setString(KEY, "test");
		assertEq(store.getString(KEY), "test");
		vm.stopPrank();
	}

	// Accepting params will fuzz the test
	function testStorageFuzz(int256 i) public {
		vm.prank(GUARDIAN, GUARDIAN);
		store.setInt(KEY, i);
		assertEq(store.getInt(KEY), i);
	}

	function testNotGuardian() public {
		vm.prank(NEWGUARDIAN, NEWGUARDIAN);
		vm.expectRevert("Invalid or outdated network contract attempting access during deployment");
		store.setInt(KEY, 2);
		assertEq(store.getInt(KEY), 0);
	}
}
