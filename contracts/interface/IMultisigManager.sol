pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

interface IMultisigManager {
	function getIndexOf(address _addr) external view returns (int256);

	function getMultisig(uint256 _index) external view returns (address addr, bool enabled);

	function getNextActiveMultisig() external view returns (address addr);

	function addMultisig(address _addr) external;

	function enableMultisig(address _addr) external;

	function disableMultisig(address _addr) external;

	function requireValidSignature(
		address _signer,
		bytes32 _msgHash,
		bytes memory signature
	) external;
}
