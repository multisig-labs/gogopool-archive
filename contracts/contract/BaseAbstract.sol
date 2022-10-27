// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.17;

import {Storage} from "./Storage.sol";

// TODO remove this when dev is complete
// import {console} from "forge-std/console.sol";
// import {format} from "sol-utils/format.sol";

/// @title Base settings / modifiers for each contract in GoGoPool
/// @author Chandler
// Based on RocketBase by RocketPool

abstract contract BaseAbstract {
	error InvalidOrOutdatedContract();
	error MustBeGuardian();
	error MustBeMultisig();
	error ContractPaused();
	error ContractNotFound();
	error MustBeGuardianOrValidContract();

	// Version of the contract
	uint8 public version;

	// The main storage contract where primary persistant storage is maintained
	Storage internal gogoStorage;

	/*** Modifiers **********************************************************/

	/**
	 * @dev Throws if called by any sender that doesn't match a GoGo Pool network contract
	 */
	modifier onlyLatestNetworkContract() {
		if (getBool(keccak256(abi.encodePacked("contract.exists", msg.sender))) == false) {
			revert InvalidOrOutdatedContract();
		}
		_;
	}

	/**
	 * @dev Throws if called by any sender that doesn't match one of the supplied contract or is the latest version of that contract
	 */
	modifier onlyLatestContract(string memory contractName, address contractAddress) {
		if (contractAddress != getAddress(keccak256(abi.encodePacked("contract.address", contractName)))) {
			revert InvalidOrOutdatedContract();
		}
		_;
	}

	// I want a modifier that allows the guardian or
	// ocyticus to be able to call

	modifier guardianOrLatestContract(string memory contractName, address contractAddress) {
		bool isContract = contractAddress == getAddress(keccak256(abi.encodePacked("contract.address", contractName)));
		bool isGuardian = msg.sender == gogoStorage.getGuardian();

		if (!(isGuardian || isContract)) {
			revert MustBeGuardianOrValidContract();
		}
		_;
	}

	/**
	 * @dev Throws if called by any account other than a guardian account (temporary account allowed access to settings before DAO is fully enabled)
	 */
	modifier onlyGuardian() {
		if (msg.sender != gogoStorage.getGuardian()) {
			revert MustBeGuardian();
		}
		_;
	}

	modifier onlyMultisig() {
		int256 multisigIndex = int256(getUint(keccak256(abi.encodePacked("MultisigManager.index", msg.sender)))) - 1;
		address addr = getAddress(keccak256(abi.encodePacked("MultisigManager.item", multisigIndex, ".address")));
		bool enabled = (addr != address(0)) && getBool(keccak256(abi.encodePacked("MultisigManager.item", multisigIndex, ".enabled")));
		if (enabled == false) {
			revert MustBeMultisig();
		}
		_;
	}

	modifier whenNotPaused() {
		string memory contractName = getContractName(address(this));
		if (getBool(keccak256(abi.encodePacked("contract.paused", contractName)))) {
			revert ContractPaused();
		}
		_;
	}

	/*** Methods **********************************************************/

	/// @dev Get the address of a network contract by name
	function getContractAddress(string memory contractName) public view returns (address) {
		address contractAddress = getAddress(keccak256(abi.encodePacked("contract.address", contractName)));
		if (contractAddress == address(0x0)) {
			revert ContractNotFound();
		}
		return contractAddress;
	}

	/// @dev Get the address of a network contract by name (returns address(0x0) instead of reverting if contract does not exist)
	function getContractAddressUnsafe(string memory contractName) internal view returns (address) {
		address contractAddress = getAddress(keccak256(abi.encodePacked("contract.address", contractName)));
		return contractAddress;
	}

	/// @dev Get the name of a network contract by address
	function getContractName(address contractAddress) internal view returns (string memory) {
		string memory contractName = getString(keccak256(abi.encodePacked("contract.name", contractAddress)));
		if (bytes(contractName).length == 0) {
			revert ContractNotFound();
		}
		return contractName;
	}

	/// @dev Get revert error message from a .call method
	function getRevertMsg(bytes memory returnData) internal pure returns (string memory) {
		// If the _res length is less than 68, then the transaction failed silently (without a revert message)
		if (returnData.length < 68) return "Transaction reverted silently";
		// solhint-disable-next-line no-inline-assembly
		assembly {
			// Slice the sighash.
			returnData := add(returnData, 0x04)
		}
		return abi.decode(returnData, (string)); // All that remains is the revert string
	}

	/*** GoGo Storage Methods ****************************************/

	// Note: Unused helpers have been removed to keep contract sizes down

	/// @dev Storage get methods
	function getAddress(bytes32 key) internal view returns (address) {
		return gogoStorage.getAddress(key);
	}

	function getBool(bytes32 key) internal view returns (bool) {
		return gogoStorage.getBool(key);
	}

	function getBytes(bytes32 key) internal view returns (bytes memory) {
		return gogoStorage.getBytes(key);
	}

	function getBytes32(bytes32 key) internal view returns (bytes32) {
		return gogoStorage.getBytes32(key);
	}

	function getInt(bytes32 key) internal view returns (int256) {
		return gogoStorage.getInt(key);
	}

	function getUint(bytes32 key) internal view returns (uint256) {
		return gogoStorage.getUint(key);
	}

	function getString(bytes32 key) internal view returns (string memory) {
		return gogoStorage.getString(key);
	}

	/// @dev Storage set methods
	function setAddress(bytes32 key, address value) internal {
		gogoStorage.setAddress(key, value);
	}

	function setBool(bytes32 key, bool value) internal {
		gogoStorage.setBool(key, value);
	}

	function setBytes(bytes32 key, bytes memory value) internal {
		gogoStorage.setBytes(key, value);
	}

	function setBytes32(bytes32 key, bytes32 value) internal {
		gogoStorage.setBytes32(key, value);
	}

	function setInt(bytes32 key, int256 value) internal {
		gogoStorage.setInt(key, value);
	}

	function setUint(bytes32 key, uint256 value) internal {
		gogoStorage.setUint(key, value);
	}

	function setString(bytes32 key, string memory value) internal {
		gogoStorage.setString(key, value);
	}

	/// @dev Storage delete methods
	function deleteAddress(bytes32 key) internal {
		gogoStorage.deleteAddress(key);
	}

	function deleteBool(bytes32 key) internal {
		gogoStorage.deleteBool(key);
	}

	function deleteBytes(bytes32 key) internal {
		gogoStorage.deleteBytes(key);
	}

	function deleteBytes32(bytes32 key) internal {
		gogoStorage.deleteBytes32(key);
	}

	function deleteInt(bytes32 key) internal {
		gogoStorage.deleteInt(key);
	}

	function deleteUint(bytes32 key) internal {
		gogoStorage.deleteUint(key);
	}

	function deleteString(bytes32 key) internal {
		gogoStorage.deleteString(key);
	}

	/// @dev Storage arithmetic methods
	function addUint(bytes32 key, uint256 amount) internal {
		gogoStorage.addUint(key, amount);
	}

	function subUint(bytes32 key, uint256 amount) internal {
		gogoStorage.subUint(key, amount);
	}
}
