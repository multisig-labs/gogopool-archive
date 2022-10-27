// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.17;

import "./utils/BaseTest.sol";
import {ProtocolDAO} from "../../contracts/contract/dao/ProtocolDAO.sol";

contract ProtocolDAOClaimTest is BaseTest {
	function setUp() public override {
		super.setUp();

		vm.startPrank(guardian);
		ggp.approve(address(vault), 1000 ether);
		vault.depositToken("ProtocolDAOClaim", ggp, 1000 ether);
		vm.stopPrank();
	}

	function testSpendFunds() public {
		address alice = getActor("alice");
		// TODO This isnt working?
		// vm.expectRevert(MultisigManager.MustBeGuardian.selector);
		bytes memory customError = abi.encodeWithSignature("MustBeGuardian()");
		vm.expectRevert(customError);
		daoClaim.spend("Invoice1", alice, 100 ether);

		vm.startPrank(guardian);
		vm.expectRevert(ProtocolDAOClaim.InvalidAmount.selector);
		daoClaim.spend("Invoice1", alice, 0 ether);

		vm.expectRevert(ProtocolDAOClaim.InvalidAmount.selector);
		daoClaim.spend("Invoice1", alice, 1001 ether);

		daoClaim.spend("Invoice1", alice, 1000 ether);
	}
}
