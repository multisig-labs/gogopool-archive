pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/BaseTest.sol";

contract MultisigManagerTest is BaseTest {
	function setUp() public override {
		super.setUp();
	}

	function testAddMultisig() public {
		uint256 initCount = multisigMgr.getCount();
		address rialto1 = getActor("rialto1");
		registerMultisig(rialto1);
		int256 index = multisigMgr.getIndexOf(rialto1);
		(address a, bool enabled) = multisigMgr.getMultisig(uint256(index));
		assertEq(a, rialto1);
		assert(enabled);
		assertEq(multisigMgr.getCount(), initCount + 1);
	}

	function testFindActive() public {
		// Disable the global one
		multisigMgr.disableMultisig(rialto);

		address rialto1 = getActor("rialto1");
		registerMultisig(rialto1);
		address rialto2 = getActor("rialto2");
		registerMultisig(rialto2);
		multisigMgr.disableMultisig(rialto1);
		address ms = multisigMgr.requireNextActiveMultisig();
		assertEq(rialto2, ms);
	}
}
