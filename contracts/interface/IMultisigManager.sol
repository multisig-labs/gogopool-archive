pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

interface IMultisigManager {
	/// @notice A multisig with this address has already been registered
	error MultisigAlreadyRegistered();

	/// @notice A multisig with this address has not been registered
	error MultisigNotFound();

	/// @notice Multisig has been disabled
	error MultisigDisabled();

	/// @notice Signature is invalid
	error SignatureInvalid();

	// Events
	event RegisteredMultisig(address indexed addr);
	event EnabledMultisig(address indexed addr);
	event DisabledMultisig(address indexed addr);

	function registerMultisig(address addr) external;

	function enableMultisig(address addr) external;

	function disableMultisig(address addr) external;

	function getNextActiveMultisig() external returns (address);

	function requireValidSignature(
		address addr,
		bytes32 msgHash,
		bytes memory sig
	) external view;

	function getIndexOf(address addr) external view returns (int256);

	function getMultisig(uint256 index) external view returns (address addr, bool enabled);
}
