// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;

/// @title The primary persistent storage for GoGoPool
/// Based on RocketStorage by RocketPool

contract Storage {
	error InvalidGuardianConfirmation();
	error InvalidOrOutdatedContract();
	error MustBeGuardian();

	event GuardianChanged(address oldGuardian, address newGuardian);

	// Storage maps
	mapping(bytes32 => address) private addressStorage;
	mapping(bytes32 => bool) private booleanStorage;
	mapping(bytes32 => bytes) private bytesStorage;
	mapping(bytes32 => bytes32) private bytes32Storage;
	mapping(bytes32 => int256) private intStorage;
	mapping(bytes32 => string) private stringStorage;
	mapping(bytes32 => uint256) private uintStorage;

	// Guardian address
	address private guardian;
	address private newGuardian;

	/// @dev Only allow access from guardian or the latest version of a contract in the GoGoPool network
	modifier onlyLatestNetworkContract() {
		if (booleanStorage[keccak256(abi.encodePacked("contract.exists", msg.sender))] == false && msg.sender != guardian) {
			revert InvalidOrOutdatedContract();
		}
		_;
	}

	constructor() {
		guardian = msg.sender;
	}

	// Initiate transfer of guardianship to a new address
	function setGuardian(address _newAddress) external {
		// Check tx comes from current guardian
		if (msg.sender != guardian) {
			revert MustBeGuardian();
		}
		// Store new address awaiting confirmation
		newGuardian = _newAddress;
	}

	// Get guardian address
	function getGuardian() external view returns (address) {
		return guardian;
	}

	// Completes transfer of guardianship
	function confirmGuardian() external {
		if (msg.sender != newGuardian) {
			revert InvalidGuardianConfirmation();
		}
		// Store old guardian for event
		address oldGuardian = guardian;
		// Update guardian and clear storage
		guardian = newGuardian;
		delete newGuardian;
		emit GuardianChanged(oldGuardian, guardian);
	}

	//
	// GET
	//

	function getAddress(bytes32 _key) external view returns (address r) {
		return addressStorage[_key];
	}

	function getBool(bytes32 _key) external view returns (bool r) {
		return booleanStorage[_key];
	}

	function getBytes(bytes32 _key) external view returns (bytes memory) {
		return bytesStorage[_key];
	}

	function getBytes32(bytes32 _key) external view returns (bytes32 r) {
		return bytes32Storage[_key];
	}

	function getInt(bytes32 _key) external view returns (int256 r) {
		return intStorage[_key];
	}

	function getString(bytes32 _key) external view returns (string memory) {
		return stringStorage[_key];
	}

	function getUint(bytes32 _key) external view returns (uint256 r) {
		return uintStorage[_key];
	}

	//
	// SET
	//

	function setAddress(bytes32 _key, address _value) external onlyLatestNetworkContract {
		addressStorage[_key] = _value;
	}

	function setBool(bytes32 _key, bool _value) external onlyLatestNetworkContract {
		booleanStorage[_key] = _value;
	}

	function setBytes(bytes32 _key, bytes calldata _value) external onlyLatestNetworkContract {
		bytesStorage[_key] = _value;
	}

	function setBytes32(bytes32 _key, bytes32 _value) external onlyLatestNetworkContract {
		bytes32Storage[_key] = _value;
	}

	function setInt(bytes32 _key, int256 _value) external onlyLatestNetworkContract {
		intStorage[_key] = _value;
	}

	function setString(bytes32 _key, string calldata _value) external onlyLatestNetworkContract {
		stringStorage[_key] = _value;
	}

	function setUint(bytes32 _key, uint256 _value) external onlyLatestNetworkContract {
		uintStorage[_key] = _value;
	}

	//
	// DELETE
	//

	function deleteAddress(bytes32 _key) external onlyLatestNetworkContract {
		delete addressStorage[_key];
	}

	function deleteBool(bytes32 _key) external onlyLatestNetworkContract {
		delete booleanStorage[_key];
	}

	function deleteBytes(bytes32 _key) external onlyLatestNetworkContract {
		delete bytesStorage[_key];
	}

	function deleteBytes32(bytes32 _key) external onlyLatestNetworkContract {
		delete bytes32Storage[_key];
	}

	function deleteInt(bytes32 _key) external onlyLatestNetworkContract {
		delete intStorage[_key];
	}

	function deleteString(bytes32 _key) external onlyLatestNetworkContract {
		delete stringStorage[_key];
	}

	function deleteUint(bytes32 _key) external onlyLatestNetworkContract {
		delete uintStorage[_key];
	}

	//
	// ADD / SUBTRACT HELPERS
	//

	/// @param _key The key for the record
	/// @param _amount An amount to add to the record's value
	function addUint(bytes32 _key, uint256 _amount) external onlyLatestNetworkContract {
		uintStorage[_key] = uintStorage[_key] + _amount;
	}

	/// @param _key The key for the record
	/// @param _amount An amount to subtract from the record's value
	function subUint(bytes32 _key, uint256 _amount) external onlyLatestNetworkContract {
		uintStorage[_key] = uintStorage[_key] - _amount;
	}
}
