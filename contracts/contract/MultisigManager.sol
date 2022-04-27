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
	constructor(IStorage _storageAddress) Base(_storageAddress) {
		version = 1;
	}

	// Register a multisig. Defaults to disabled when first registered.
	function registerMultisig(address _addr) external override {
		int256 index = getIndexOf(_addr);
		if (index != -1) {
			revert MultisigAlreadyRegistered();
		}
		uint256 count = getUint(keccak256("multisig.count"));
		setAddress(keccak256(abi.encodePacked("multisig.item", count, ".address")), _addr);

		// NOTE the index is actually 1 more than where it is actually stored. The 1 is subtracted in getIndexOf().
		// Copied from RP, probably so they can use "-1" to signify that something doesnt exist
		setUint(keccak256(abi.encodePacked("multisig.index", _addr)), count + 1);
		addUint(keccak256("multisig.count"), 1);
		emit RegisteredMultisig(_addr);
	}

	function enableMultisig(address _addr) external override {
		int256 index = getIndexOf(_addr);
		if (index == -1) {
			revert MultisigNotFound();
		}
		setBool(keccak256(abi.encodePacked("multisig.item", index, ".enabled")), true);
		emit EnabledMultisig(_addr);
	}

	function disableMultisig(address _addr) external override {
		int256 index = requireEnabledMultisig(_addr);
		setBool(keccak256(abi.encodePacked("multisig.item", index, ".enabled")), false);
		emit DisabledMultisig(_addr);
	}

	// In future, have a way to choose which multisig gets used for each validator
	// i.e. round-robin, or based on GGP staked, etc
	function getNextActiveMultisig() external view override returns (address) {
		uint256 index = 0; // In future some other method of selecting multisig
		(address multisigAddress, ) = getMultisig(index);
		return multisigAddress;
	}

	// Verifies that an active Rialto multisig signed the _msgHash
	function requireValidSignature(
		address _addr,
		bytes32 _msgHash,
		bytes calldata _sig
	) external view {
		requireEnabledMultisig(_addr);
		address recovered = ECDSA.recover(_msgHash, _sig);
		if (_addr != recovered) {
			revert SignatureInvalid();
		}
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

	function requireEnabledMultisig(address _addr) private view returns (int256) {
		int256 index = getIndexOf(_addr);
		if (index == -1) {
			revert MultisigNotFound();
		}
		(, bool enabled) = getMultisig(uint256(index));
		if (!enabled) {
			revert MultisigDisabled();
		}
		return index;
	}
}
