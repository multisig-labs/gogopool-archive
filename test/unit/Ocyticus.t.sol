pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/BaseTest.sol";

contract OcyticusTest is BaseTest {
	function setUp() public override {
		super.setUp();
	}

	function testPauseEverything() public {
		vm.prank(guardian);
		ocyticus.pauseEverything();
		assert(dao.getContractPaused("TokenggAVAX"));

		vm.prank(guardian);
		ocyticus.resumeEverything();
		console.log("paused?", dao.getContractPaused("TokenggAVAX"));
	}

	function testAddRemoveDefender() public {
		address alice = getActor("alice");
		vm.prank(guardian);
		ocyticus.addDefender(alice);
		assert(ocyticus.defenders(alice));

		vm.prank(guardian);
		ocyticus.removeDefender(alice);
		assert(!ocyticus.defenders(alice));
	}

	function testDisableAllMultisigs() public {
		address alice = getActor("alice");
		vm.startPrank(guardian);
		multisigMgr.registerMultisig(alice);
		multisigMgr.enableMultisig(alice);
		vm.stopPrank();

		int256 rialtoIndex = multisigMgr.getIndexOf(rialto);
		int256 aliceIndex = multisigMgr.getIndexOf(alice);
		assert(rialtoIndex != -1);
		assert(aliceIndex != -1);

		address addr;
		bool enabled;
		(addr, enabled) = multisigMgr.getMultisig(uint256(rialtoIndex));
		assert(enabled);
		(addr, enabled) = multisigMgr.getMultisig(uint256(aliceIndex));
		assert(enabled);

		vm.prank(guardian);
		ocyticus.disableAllMultisigs();

		(addr, enabled) = multisigMgr.getMultisig(uint256(rialtoIndex));
		assert(!enabled);
		(addr, enabled) = multisigMgr.getMultisig(uint256(aliceIndex));
		assert(!enabled);
	}
}
