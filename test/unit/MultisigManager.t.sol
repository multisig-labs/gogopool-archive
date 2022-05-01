pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./utils/GGPTest.sol";

contract MultisigManagerTest is GGPTest {
	function setUp() public override {
		super.setUp();
	}

	// Example of how to sign and recover an address
	function testSimpleVerifySignature() public {
		address rialto1Addr = vm.addr(RIALTO1_PK);
		bytes32 h = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked("test message")));
		(uint8 v, bytes32 r, bytes32 s) = vm.sign(RIALTO1_PK, h);
		address recovered = ECDSA.recover(h, v, r, s);
		assertEq(recovered, rialto1Addr);
		vm.expectRevert("ECDSA: invalid signature 'v' value");
		recovered = ECDSA.recover(h, 99, r, s);
	}

	// Example where hash and sig dont match
	function testSimpleVerifySignature2() public {
		address rialto1Addr = vm.addr(RIALTO1_PK);
		bytes32 h = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked("test message")));
		(uint8 v, bytes32 r, bytes32 s) = vm.sign(RIALTO1_PK, h);
		bytes32 badH = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked("different message")));
		address recovered = ECDSA.recover(badH, v, r, s);
		assertFalse(recovered == rialto1Addr);
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
}
