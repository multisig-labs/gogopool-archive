pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import {Storage} from "./Storage.sol";

// TODO remove this when dev is complete
import {console} from "forge-std/console.sol";
import {format} from "sol-utils/format.sol";

/// @title Base settings / modifiers for each contract in GoGoPool
/// @author Chandler
// Based on RocketBase by RocketPool

abstract contract BaseAbstract {
	// Calculate using this as the base
	uint256 internal constant CALC_BASE = 1 ether;

	// Version of the contract
	uint8 public version;

	// The main storage contract where primary persistant storage is maintained
	Storage internal gogoStorage;

	/*** Modifiers **********************************************************/

	/**
	 * @dev Throws if called by any sender that doesn't match a GoGo Pool network contract
	 */
	modifier onlyLatestNetworkContract() {
		require(getBool(keccak256(abi.encodePacked("contract.exists", msg.sender))), "Invalid or outdated contract");
		_;
	}

	/**
	 * @dev Throws if called by any sender that doesn't match one of the supplied contract or is the latest version of that contract
	 */
	modifier onlyLatestContract(string memory _contractName, address _contractAddress) {
		require(_contractAddress == getAddress(keccak256(abi.encodePacked("contract.address", _contractName))), "Invalid or outdated contract");
		_;
	}

	/**
	 * @dev Throws if called by any account other than a guardian account (temporary account allowed access to settings before DAO is fully enabled)
	 */
	modifier onlyGuardian() {
		require(msg.sender == gogoStorage.getGuardian(), "Account is not a guardian");
		_;
	}

	/*** Methods **********************************************************/

	/// @dev Get the address of a network contract by name
	function getContractAddress(string memory _contractName) public view returns (address) {
		// Get the current contract address
		address contractAddress = getAddress(keccak256(abi.encodePacked("contract.address", _contractName)));
		// Check it
		require(contractAddress != address(0x0), "Contract not found");
		// Return
		return contractAddress;
	}

	/// @dev Get the address of a network contract by name (returns address(0x0) instead of reverting if contract does not exist)
	function getContractAddressUnsafe(string memory _contractName) internal view returns (address) {
		// Get the current contract address
		address contractAddress = getAddress(keccak256(abi.encodePacked("contract.address", _contractName)));
		// Return
		return contractAddress;
	}

	/// @dev Get the name of a network contract by address
	function getContractName(address _contractAddress) internal view returns (string memory) {
		// Get the contract name
		string memory contractName = getString(keccak256(abi.encodePacked("contract.name", _contractAddress)));
		// Check it
		require(bytes(contractName).length > 0, "Contract not found");
		// Return
		return contractName;
	}

	/// @dev Get revert error message from a .call method
	function getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {
		// If the _res length is less than 68, then the transaction failed silently (without a revert message)
		if (_returnData.length < 68) return "Transaction reverted silently";
		// solhint-disable-next-line no-inline-assembly
		assembly {
			// Slice the sighash.
			_returnData := add(_returnData, 0x04)
		}
		return abi.decode(_returnData, (string)); // All that remains is the revert string
	}

	/*** GoGo Storage Methods ****************************************/

	// Note: Unused helpers have been removed to keep contract sizes down

	/// @dev Storage get methods
	function getAddress(bytes32 key) internal view returns (address) {
		return gogoStorage.getAddress(key);
	}

	function getUint(bytes32 _key) internal view returns (uint256) {
		return gogoStorage.getUint(_key);
	}

	function getString(bytes32 _key) internal view returns (string memory) {
		return gogoStorage.getString(_key);
	}

	function getBytes(bytes32 _key) internal view returns (bytes memory) {
		return gogoStorage.getBytes(_key);
	}

	function getBool(bytes32 _key) internal view returns (bool) {
		return gogoStorage.getBool(_key);
	}

	function getInt(bytes32 _key) internal view returns (int256) {
		return gogoStorage.getInt(_key);
	}

	function getBytes32(bytes32 _key) internal view returns (bytes32) {
		return gogoStorage.getBytes32(_key);
	}

	/// @dev Storage set methods
	function setAddress(bytes32 _key, address _value) internal {
		gogoStorage.setAddress(_key, _value);
	}

	/// @dev Storage get Settings methods
	/*** Uints  ****************/

	// A general method to return any setting given the setting namespace and path is correct, only accepts uints
	function getSettingUint(bytes32 settingNameSpace, string memory _settingPath) public view returns (uint256) {
		return getUint(keccak256(abi.encodePacked(settingNameSpace, _settingPath)));
	}

	/*** Bools  ****************/

	// A general method to return any setting given the setting namespace and path is correct, only accepts bools
	function getSettingBool(bytes32 settingNameSpace, string memory _settingPath) public view returns (bool) {
		return getBool(keccak256(abi.encodePacked(settingNameSpace, _settingPath)));
	}

	/*** Addresses  ****************/

	// A general method to return any setting given the setting namespace and path is correct, only accepts addresses
	function getSettingAddress(bytes32 settingNameSpace, string memory _settingPath) external view returns (address) {
		return getAddress(keccak256(abi.encodePacked(settingNameSpace, _settingPath)));
	}

	/// @dev Storage set methods
	function setUint(bytes32 _key, uint256 _value) internal {
		gogoStorage.setUint(_key, _value);
	}

	function setString(bytes32 _key, string memory _value) internal {
		gogoStorage.setString(_key, _value);
	}

	function setBytes(bytes32 _key, bytes memory _value) internal {
		gogoStorage.setBytes(_key, _value);
	}

	function setBool(bytes32 _key, bool _value) internal {
		gogoStorage.setBool(_key, _value);
	}

	function setInt(bytes32 _key, int256 _value) internal {
		gogoStorage.setInt(_key, _value);
	}

	function setBytes32(bytes32 _key, bytes32 _value) internal {
		gogoStorage.setBytes32(_key, _value);
	}

	/// @dev Storage delete methods
	function deleteAddress(bytes32 _key) internal {
		gogoStorage.deleteAddress(_key);
	}

	function deleteUint(bytes32 _key) internal {
		gogoStorage.deleteUint(_key);
	}

	function deleteString(bytes32 _key) internal {
		gogoStorage.deleteString(_key);
	}

	function deleteBytes(bytes32 _key) internal {
		gogoStorage.deleteBytes(_key);
	}

	function deleteBool(bytes32 _key) internal {
		gogoStorage.deleteBool(_key);
	}

	function deleteInt(bytes32 _key) internal {
		gogoStorage.deleteInt(_key);
	}

	function deleteBytes32(bytes32 _key) internal {
		gogoStorage.deleteBytes32(_key);
	}

	/// @dev Storage arithmetic methods
	function addUint(bytes32 _key, uint256 _amount) internal {
		gogoStorage.addUint(_key, _amount);
	}

	function subUint(bytes32 _key, uint256 _amount) internal {
		gogoStorage.subUint(_key, _amount);
	}
}
