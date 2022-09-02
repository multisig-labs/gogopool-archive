pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./Base.sol";
import {Storage} from "./Storage.sol";

/*
	Data Storage Schema
	multisig.count = Starts at 0 and counts up by 1 after an addr is added.
	multisig.index<address> = <index> of multisigAddress
	multisig.item<index>.address = multisigAddress used as primary key (NOT the ascii but the actual 20 bytes of C-Chain address)
	multisig.item<index>.enabled = bool
*/

contract MultisigManager is Base {
	/// @notice A multisig with this address has already been registered
	error MultisigAlreadyRegistered();

	/// @notice A multisig with this address has not been registered
	error MultisigNotFound();

	/// @notice Multisig has been disabled
	error MultisigDisabled();

	/// @notice No active Multisig has been found
	error NoEnabledMultisigFound();

	// Events
	event RegisteredMultisig(address indexed addr);
	event EnabledMultisig(address indexed addr);
	event DisabledMultisig(address indexed addr);

	constructor(Storage storageAddress) Base(storageAddress) {
		version = 1;
	}

	// TODO modifiers for who can call all these functions

	// Register a multisig. Defaults to disabled when first registered.
	function registerMultisig(address addr) external {
		int256 index = getIndexOf(addr);
		if (index != -1) {
			revert MultisigAlreadyRegistered();
		}
		uint256 count = getUint(keccak256("multisig.count"));
		setAddress(keccak256(abi.encodePacked("multisig.item", count, ".address")), addr);

		// NOTE the index is actually 1 more than where it is actually stored. The 1 is subtracted in getIndexOf().
		// Copied from RP, probably so they can use "-1" to signify that something doesnt exist
		setUint(keccak256(abi.encodePacked("multisig.index", addr)), count + 1);
		addUint(keccak256("multisig.count"), 1);
		emit RegisteredMultisig(addr);
	}

	function enableMultisig(address addr) external {
		int256 index = getIndexOf(addr);
		if (index == -1) {
			revert MultisigNotFound();
		}
		setBool(keccak256(abi.encodePacked("multisig.item", index, ".enabled")), true);
		emit EnabledMultisig(addr);
	}

	// TODO What does this mean? If they have existing validations then they MUST be able to finalize them
	// so this probably means they cant get assigned any NEW nodes
	function disableMultisig(address addr) external {
		int256 index = getIndexOf(addr);
		if (index == -1) {
			revert MultisigNotFound();
		}
		setBool(keccak256(abi.encodePacked("multisig.item", index, ".enabled")), false);
		emit DisabledMultisig(addr);
	}

	// In future, have a way to choose which multisig gets used for each validator
	// i.e. round-robin, or based on GGP staked, etc
	function requireNextActiveMultisig() external view returns (address) {
		uint256 total = getUint(keccak256("multisig.count"));
		address addr;
		bool enabled;
		for (uint256 i = 0; i < total; i++) {
			(addr, enabled) = getMultisig(i);
			if (enabled && addr != address(0)) {
				return addr;
			}
		}
		revert NoEnabledMultisigFound();
	}

	// The index of an item
	// Returns -1 if the value is not found
	function getIndexOf(address addr) public view returns (int256) {
		return int256(getUint(keccak256(abi.encodePacked("multisig.index", addr)))) - 1;
	}

	function getCount() public view returns (uint256) {
		return getUint(keccak256("multisig.count"));
	}

	function getMultisig(uint256 index) public view returns (address addr, bool enabled) {
		addr = getAddress(keccak256(abi.encodePacked("multisig.item", index, ".address")));
		enabled = getBool(keccak256(abi.encodePacked("multisig.item", index, ".enabled")));
	}
}
