// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;

import "./utils/BaseTest.sol";
import {MultisigManager} from "../../contracts/contract/MultisigManager.sol";

contract MultisigManagerTest is BaseTest {
	function setUp() public override {
		super.setUp();
	}

	function testAddMultisig() public {
		uint256 initCount = multisigMgr.getCount();
		address rialto1 = getActor("rialto1");

		// This isnt working?
		// vm.expectRevert(MultisigManager.MustBeGuardian.selector);
		bytes memory customError = abi.encodeWithSignature("MustBeGuardian()");
		vm.expectRevert(customError);
		multisigMgr.registerMultisig(rialto1);

		vm.startPrank(guardian);
		multisigMgr.registerMultisig(rialto1);
		multisigMgr.enableMultisig(rialto1);
		vm.stopPrank();

		int256 index = multisigMgr.getIndexOf(rialto1);
		(address a, bool enabled) = multisigMgr.getMultisig(uint256(index));
		assertEq(a, rialto1);
		assert(enabled);
		assertEq(multisigMgr.getCount(), initCount + 1);
	}

	function testFindActive() public {
		// Disable the global one
		vm.startPrank(guardian);
		multisigMgr.disableMultisig(rialto);
		address rialto1 = getActor("rialto1");
		multisigMgr.registerMultisig(rialto1);
		multisigMgr.enableMultisig(rialto1);
		address rialto2 = getActor("rialto2");
		multisigMgr.registerMultisig(rialto2);
		multisigMgr.enableMultisig(rialto2);
		multisigMgr.disableMultisig(rialto1);
		vm.stopPrank();
		address ms = multisigMgr.requireNextActiveMultisig();
		assertEq(rialto2, ms);
	}
}
