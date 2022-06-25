pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";

contract MultisigManagerTest is GGPTest {
	function setUp() public override {
		super.setUp();
	}

	function testAddMultisig() public {
		address rialto1Addr = vm.addr(RIALTO1_PK);
		registerMultisig(rialto1Addr);
		int256 index = multisigMgr.getIndexOf(rialto1Addr);
		assertEq(index, 0);
		(address a, bool enabled) = multisigMgr.getMultisig(uint256(index));
		assertEq(a, rialto1Addr);
		assert(enabled);
	}

	function testFindActive() public {
		address rialto1Addr = vm.addr(RIALTO1_PK);
		registerMultisig(rialto1Addr);
		address rialto2Addr = vm.addr(RIALTO2_PK);
		registerMultisig(rialto2Addr);
		multisigMgr.disableMultisig(rialto1Addr);
		address ms = multisigMgr.getNextActiveMultisig();
		assertEq(rialto2Addr, ms);
	}
}
