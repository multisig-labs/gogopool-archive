// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.17;

import "./utils/BaseTest.sol";
import {BaseAbstract} from "../../contracts/contract/BaseAbstract.sol";
import {IWithdrawer} from "../../contracts/interface/IWithdrawer.sol";

contract VaultTest is BaseTest, IWithdrawer {
	function setUp() public override {
		super.setUp();
	}

	function receiveWithdrawalAVAX() external payable {}

	function testDepositAvaxFromRegisteredContract() public {
		registerContract(store, "VaultTest", address(this));
		vm.deal(address(this), 1 ether);

		vm.expectRevert(Vault.InvalidAmount.selector);
		vault.depositAVAX{value: 0 ether}();

		vault.depositAVAX{value: 1 ether}();
		assertEq(address(this).balance, 0 ether);
		assertEq(vault.balanceOf("VaultTest"), 1 ether);

		vm.expectRevert(Vault.InvalidAmount.selector);
		vault.withdrawAVAX(0 ether);

		vm.expectRevert(Vault.InsufficientContractBalance.selector);
		vault.withdrawAVAX(2 ether);

		vault.withdrawAVAX(1 ether);
		assertEq(address(this).balance, 1 ether);
	}

	function testDepositAvaxFromUnRegisteredContract() public {
		vm.deal(address(this), 1 ether);
		vm.expectRevert(BaseAbstract.ContractNotFound.selector);
		vault.depositAVAX{value: 1 ether}();
		assertEq(vault.balanceOf("VaultTest"), 0 ether);
	}

	function testTransferAvaxFromRegisteredContract() public {
		registerContract(store, "VaultTest", address(this));
		vm.deal(address(this), 1 ether);
		vault.depositAVAX{value: 1 ether}();
		assertEq(vault.balanceOf("VaultTest"), 1 ether);

		vm.expectRevert(Vault.InvalidAmount.selector);
		vault.transferAVAX("VaultTest", "MinipoolManager", 0 ether);

		vault.transferAVAX("VaultTest", "MinipoolManager", 1 ether);
		assertEq(vault.balanceOf("VaultTest"), 0 ether);
		assertEq(vault.balanceOf("MinipoolManager"), 1 ether);
	}

	function testDepositTokenFromRegisteredContract() public {
		registerContract(store, "VaultTest", address(this));
		dealGGP(address(this), 1 ether);
		ggp.approve(address(vault), 1 ether);

		vm.expectRevert(Vault.InvalidAmount.selector);
		vault.depositToken("VaultTest", ggp, 0 ether);

		vault.depositToken("VaultTest", ggp, 1 ether);
		assertEq(vault.balanceOfToken("VaultTest", ggp), 1 ether);

		vm.expectRevert(Vault.InvalidAmount.selector);
		vault.withdrawToken(address(this), ggp, 0 ether);

		vm.expectRevert();
		vault.withdrawToken(address(this), ggp, 2 ether);

		vault.withdrawToken(address(this), ggp, 1 ether);
		assertEq(ggp.balanceOf(address(this)), 1 ether);
	}

	function testDepositTokenFromUnregisteredContract() public {
		dealGGP(address(this), 1 ether);
		ggp.approve(address(vault), 1 ether);

		vm.expectRevert(BaseAbstract.ContractNotFound.selector);
		vault.depositToken("VaultTest", ggp, 1 ether);
	}

	function testTransferTokenFromRegisteredContract() public {
		registerContract(store, "VaultTest", address(this));
		dealGGP(address(this), 1 ether);
		ggp.approve(address(vault), 1 ether);

		vault.depositToken("VaultTest", ggp, 1 ether);
		assertEq(vault.balanceOfToken("VaultTest", ggp), 1 ether);

		vault.transferToken("MinipoolManager", ggp, 1 ether);
		assertEq(vault.balanceOfToken("VaultTest", ggp), 0 ether);
		assertEq(vault.balanceOfToken("MinipoolManager", ggp), 1 ether);
	}

	function testTransferTokenFromUnregisteredContract() public {
		vm.expectRevert(BaseAbstract.ContractNotFound.selector);
		vault.transferToken("MinipoolManager", ggp, 1 ether);
	}
}
