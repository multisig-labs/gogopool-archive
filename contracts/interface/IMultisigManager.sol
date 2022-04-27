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

	function registerMultisig(address _addr) external;

	function enableMultisig(address _addr) external;

	function disableMultisig(address _addr) external;

	function getIndexOf(address _addr) external view returns (int256);

	function getMultisig(uint256 _index) external view returns (address addr, bool enabled);

	function getNextActiveMultisig() external view returns (address addr);

	function requireValidSignature(
		address _addr,
		bytes32 _msgHash,
		bytes memory signature
	) external view;
}
