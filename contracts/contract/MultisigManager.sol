// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.17;

import "./Base.sol";
import {Storage} from "./Storage.sol";

/*
	Data Storage Schema
	MultisigManager.count = Starts at 0 and counts up by 1 after an addr is added.

	MultisigManager.index<address> = <index> + 1 of multisigAddress
	MultisigManager.item<index>.address = C-chain address used as primary key
	MultisigManager.item<index>.enabled = bool
*/

contract MultisigManager is Base {
	error MultisigAlreadyRegistered();
	error MultisigDisabled();
	error MultisigNotFound();
	error NoEnabledMultisigFound();

	event DisabledMultisig(address indexed addr);
	event EnabledMultisig(address indexed addr);
	event RegisteredMultisig(address indexed addr);

	constructor(Storage storageAddress) Base(storageAddress) {
		version = 1;
	}

	/// @notice Register a multisig. Defaults to disabled when first registered.
	function registerMultisig(address addr) external onlyGuardian {
		int256 multisigIndex = getIndexOf(addr);
		if (multisigIndex != -1) {
			revert MultisigAlreadyRegistered();
		}
		uint256 index = getUint(keccak256("MultisigManager.count"));
		setAddress(keccak256(abi.encodePacked("MultisigManager.item", index, ".address")), addr);

		// The index is stored 1 greater than the actual value. The 1 is subtracted in getIndexOf().
		setUint(keccak256(abi.encodePacked("MultisigManager.index", addr)), index + 1);
		addUint(keccak256("MultisigManager.count"), 1);
		emit RegisteredMultisig(addr);
	}

	function enableMultisig(address addr) external onlyGuardian {
		int256 multisigIndex = getIndexOf(addr);
		if (multisigIndex == -1) {
			revert MultisigNotFound();
		}
		setBool(keccak256(abi.encodePacked("MultisigManager.item", multisigIndex, ".enabled")), true);
		emit EnabledMultisig(addr);
	}

	/// @dev this will prevent the multisig from completing validations
	/// 		the minipool will need to be manually reassigned to a new multisig
	function disableMultisig(address addr) external guardianOrLatestContract("Ocyticus", msg.sender) {
		int256 multisigIndex = getIndexOf(addr);
		if (multisigIndex == -1) {
			revert MultisigNotFound();
		}
		setBool(keccak256(abi.encodePacked("MultisigManager.item", multisigIndex, ".enabled")), false);
		emit DisabledMultisig(addr);
	}

	function requireNextActiveMultisig() external view returns (address) {
		uint256 total = getUint(keccak256("MultisigManager.count"));
		address addr;
		bool enabled;
		for (uint256 i = 0; i < total; i++) {
			(addr, enabled) = getMultisig(i);
			if (enabled) {
				return addr;
			}
		}
		revert NoEnabledMultisigFound();
	}

	function getIndexOf(address addr) public view returns (int256) {
		return int256(getUint(keccak256(abi.encodePacked("MultisigManager.index", addr)))) - 1;
	}

	function getCount() public view returns (uint256) {
		return getUint(keccak256("MultisigManager.count"));
	}

	function getMultisig(uint256 index) public view returns (address addr, bool enabled) {
		addr = getAddress(keccak256(abi.encodePacked("MultisigManager.item", index, ".address")));
		enabled = (addr != address(0)) && getBool(keccak256(abi.encodePacked("MultisigManager.item", index, ".enabled")));
	}
}
