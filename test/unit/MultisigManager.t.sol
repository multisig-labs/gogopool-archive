pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./utils/GGPTest.sol";
import "../../contracts/contract/Storage.sol";
import "../../contracts/contract/MultisigManager.sol";

contract MultisigManagerTest is GGPTest {
	MultisigManager private ms;

	function setUp() public {
		Storage s = new Storage();
		ms = new MultisigManager(s);
		initStorage(s);
	}

	function addMultisig(address _addr) public {
		ms.addMultisig(_addr);
		ms.enableMultisig(_addr);
	}

	// Example of how to sign and recover an address
	function testSimpleVerifySignature() public {
		address rialto1Addr = hevm.addr(RIALTO1_PK);
		bytes32 h = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked("test message")));
		(uint8 v, bytes32 r, bytes32 s) = hevm.sign(RIALTO1_PK, h);
		address recovered = ECDSA.recover(h, v, r, s);
		assertEq(recovered, rialto1Addr);
		hevm.expectRevert("ECDSA: invalid signature 'v' value");
		recovered = ECDSA.recover(h, 99, r, s);
	}

	// Example where hash and sig dont match
	function testSimpleVerifySignature2() public {
		address rialto1Addr = hevm.addr(RIALTO1_PK);
		bytes32 h = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked("test message")));
		(uint8 v, bytes32 r, bytes32 s) = hevm.sign(RIALTO1_PK, h);
		bytes32 badH = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked("different message")));
		address recovered = ECDSA.recover(badH, v, r, s);
		assertFalse(recovered == rialto1Addr);
	}

	function testAddMultisig() public {
		address rialto1Addr = hevm.addr(RIALTO1_PK);
		addMultisig(rialto1Addr);
		int256 index = ms.getIndexOf(rialto1Addr);
		assertEq(index, 0);
		(address a, bool enabled) = ms.getMultisig(uint256(index));
		assertEq(a, rialto1Addr);
		assert(enabled);
	}

	function testVerifySignature() public {
		address rialto1Addr = hevm.addr(RIALTO1_PK);
		addMultisig(rialto1Addr);
		bytes32 h = bytes32("test msg");
		(uint8 v, bytes32 r, bytes32 s) = hevm.sign(RIALTO1_PK, h);
		address recovered = ecrecover(h, v, r, s);
		assertEq(recovered, rialto1Addr);
		assert(ms.verifySignature(rialto1Addr, h, v, r, s));
	}
}
