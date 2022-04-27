// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import "../../../lib/forge-std/src/Test.sol";
import "../../../contracts/contract/Storage.sol";

contract GGPTest is Test {
	// This is a magic addr that forge deploys all contracts from
	address internal constant GUARDIAN = address(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);
	address internal constant ZERO_ADDRESS = address(0x00);
	address internal constant NONEXISTANT_NODEID = address(0x0123456789);
	// vm.addr(USER1_PK) gives the address of the private key
	uint256 internal constant USER1_PK = 0x9c4b7f4ad48f977dbcdb2323249fd738cc9ff283a7514f3350d344e22c5b923d;
	uint256 internal constant RIALTO1_PK = 0xb4679213567f977dbcdb2323249fd738cc9ff283a7514f3350d344e22c8b571a;
	uint256 private randNonce = 0;

	// Copy over some funcs from DSTestPlus
	string private checkpointLabel;
	uint256 private checkpointGasLeft;

	function startMeasuringGas(string memory label) internal virtual {
		checkpointLabel = label;
		checkpointGasLeft = gasleft();
	}

	function stopMeasuringGas() internal virtual {
		uint256 checkpointGasLeft2 = gasleft();

		string memory label = checkpointLabel;

		emit log_named_uint(string(abi.encodePacked(label, " Gas")), checkpointGasLeft - checkpointGasLeft2);
	}

	function assertBoolEq(bool a, bool b) internal virtual {
		b ? assertTrue(a) : assertFalse(a);
	}

	// Init common things that needs to be setup
	// Must be last func called from a setUp() function
	function initStorage(Storage _s) internal {
		vm.label(GUARDIAN, "GUARDIAN");
		_s.setGuardian(GUARDIAN);
		vm.prank(GUARDIAN);
		_s.confirmGuardian();

		// put any default values here
		vm.startPrank(GUARDIAN);
		bytes32 protocolDaoSettingsNamespace = keccak256(abi.encodePacked("dao.protocol.setting.", "dao.protocol."));
		_s.setUint(keccak256(abi.encodePacked(protocolDaoSettingsNamespace, "ggp.inflation.interval.rate")), 1000133680617113500);
		_s.setUint(keccak256(abi.encodePacked(protocolDaoSettingsNamespace, "ggp.inflation.interval.start")), block.timestamp + 1 days);
		vm.stopPrank();
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

	// Helper to combine r/s/v ECDSA signature into a single bytes
	function combineSigParts(
		uint8 _v,
		bytes32 _r,
		bytes32 _s
	) internal pure returns (bytes memory) {
		return abi.encodePacked(_r, _s, _v);
	}

	function signHash(uint256 pk, bytes32 h) internal returns (bytes memory) {
		(uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, h);
		return combineSigParts(v, r, s);
	}
}
