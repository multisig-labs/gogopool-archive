// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import "./Console.sol";
import "./DSTestPlus.sol";
import "../../../contracts/contract/Storage.sol";

contract GGPTest is DSTestPlus {
	// This is a magic addr that forge deploys all contracts from
	address internal constant GUARDIAN = address(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);
	address internal constant ZERO_ADDRESS = address(0x00);
	address internal constant NONEXISTANT_NODEID = address(0x0123456789);
	// hevm.addr(USER1_PK) gives the address of the private key
	uint256 internal constant USER1_PK = 0x9c4b7f4ad48f977dbcdb2323249fd738cc9ff283a7514f3350d344e22c5b923d;
	uint256 internal constant RIALTO1_PK = 0xb4679213567f977dbcdb2323249fd738cc9ff283a7514f3350d344e22c8b571a;
	uint256 private randNonce = 0;

	// Init common things that needs to be setup
	// Must be last func called from a setUp() function
	function initStorage(Storage _s) internal {
		hevm.label(GUARDIAN, "GUARDIAN");
		_s.setGuardian(GUARDIAN);
		hevm.prank(GUARDIAN);
		_s.confirmGuardian();
	}

	// Register a contract in Storage
	function registerContract(
		Storage _s,
		bytes memory _name,
		address _addr
	) internal {
		_s.setBool(keccak256(abi.encodePacked("contract.exists", _addr)), true);
		_s.setAddress(keccak256(abi.encodePacked("contract.address", _name)), _addr);
	}

	function randAddress() internal returns (address) {
		randNonce++;
		return address(uint160(uint256(keccak256(abi.encodePacked(randNonce, blockhash(block.timestamp))))));
	}

	function randUint(uint256 _modulus) internal returns (uint256) {
		randNonce++;
		return uint256(keccak256(abi.encodePacked(randNonce, blockhash(block.timestamp)))) % _modulus;
	}

	// Generate a random minipool for test data
	function randMinipool() internal returns (address, uint256) {
		randNonce++;
		address nodeID = randAddress();
		uint256 duration = randUint(2000000);
		return (nodeID, duration);
	}
}
