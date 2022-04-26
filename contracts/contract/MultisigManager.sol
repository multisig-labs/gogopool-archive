pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./Base.sol";
import "../interface/IStorage.sol";
import "../interface/IMultisigManager.sol";

/*
	Data Storage Schema
	multisig.count = Starts at 0 and counts up by 1 after an addr is added.
	multisig.index<address> = <index> of multisigAddress
	multisig.item<index>.address = multisigAddress used as primary key (NOT the ascii but the actual 20 bytes of C-Chain address)
	multisig.item<index>.enabled = bool
	multisig.item<index>.validatorCount = total active nodes managed
	multisig.item<index>.avaxTotal = total avax on active validators
*/

contract MultisigManager is Base, IMultisigManager {
	// Events
	event MultisigCreated(address indexed addr);
	event MultisigEnabled(address indexed addr);
	event MultisigDisabled(address indexed addr);

	constructor(IStorage _storageAddress) Base(_storageAddress) {
		version = 1;
	}

	// Add a multisig. Default to disabled when created.
	function addMultisig(address _addr) public override {
		int256 index = getIndexOf(_addr);
		require(index == -1, "Address already exists");
		uint256 count = getUint(keccak256("multisig.count"));
		setAddress(keccak256(abi.encodePacked("multisig.item", count, ".address")), _addr);

		// NOTE the index is actually 1 more than where it is actually stored. The 1 is subtracted in getIndexOf().
		// Copied from RP, probably so they can use "-1" to signify that something doesnt exist
		setUint(keccak256(abi.encodePacked("multisig.index", _addr)), count + 1);
		addUint(keccak256("multisig.count"), 1);
		emit MultisigCreated(_addr);
	}

	function enableMultisig(address _addr) public override {
		int256 index = getIndexOf(_addr);
		require(index != -1, "Node does not exist");
		setBool(keccak256(abi.encodePacked("multisig.item", index, ".enabled")), true);
		emit MultisigEnabled(_addr);
	}

	function disableMultisig(address _addr) public override {
		int256 index = getIndexOf(_addr);
		require(index != -1, "Node does not exist");
		setBool(keccak256(abi.encodePacked("multisig.item", index, ".enabled")), false);
		emit MultisigDisabled(_addr);
	}

	// The index of an item
	// Returns -1 if the value is not found
	function getIndexOf(address _addr) public view override returns (int256) {
		return int256(getUint(keccak256(abi.encodePacked("multisig.index", _addr)))) - 1;
	}

	function getMultisig(uint256 _index) public view override returns (address addr, bool enabled) {
		addr = getAddress(keccak256(abi.encodePacked("multisig.item", _index, ".address")));
		enabled = getBool(keccak256(abi.encodePacked("multisig.item", _index, ".enabled")));
	}

	// In future, have a way to choose which multisig gets used for each validator
	// i.e. round-robin, or based on GGP staked, etc
	function getNextActiveMultisig() public view override returns (address) {
		uint256 index = 0; // In future some other method of selecting multisig
		(address multisigAddress, ) = getMultisig(index);
		return multisigAddress;
	}

	// Verifies that an active Rialto multisig signed the _hash
	function verifySignature(
		address _signer,
		bytes32 _hash,
		bytes memory _sig
	) public view returns (bool) {
		address recovered = ECDSA.recover(_hash, _sig);
		require(_signer == recovered, "Invalid signature");
		return isActiveMultisig(recovered);
	}

	// Verifies that an active Rialto multisig signed the _hash
	function verifySignature(
		address _signer,
		bytes32 _hash,
		uint8 _v,
		bytes32 _r,
		bytes32 _s
	) public view returns (bool) {
		address recovered = ECDSA.recover(_hash, _v, _r, _s);
		require(_signer == recovered, "Invalid signature");
		return isActiveMultisig(recovered);
	}

	function isActiveMultisig(address _addr) private view returns (bool) {
		int256 index = getIndexOf(_addr);
		require(index != -1, "addr does not exist");
		(, bool enabled) = getMultisig(uint256(index));
		require(enabled, "addr is disabled");
		return true;
	}
}
