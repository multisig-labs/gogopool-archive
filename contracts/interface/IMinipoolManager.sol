pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "../types/MinipoolStatus.sol";

interface IMinipoolManager {
	/// @notice A minipool with this nodeid has already been registered
	error MinipoolAlreadyRegistered();

	/// @notice A minipool with this nodeid has not been registered
	error MinipoolNotFound();

	/// @notice Invalid state transition
	error InvalidStateTransition();

	/// @notice Validation end time must be after start time
	error InvalidEndTime();

	/// @notice Only minipool owners can cancel a minipool before validation starts
	error OnlyOwnerCanCancel();

	/// @notice Only the multisig assigned to a minipool can interact with it
	error InvalidMultisigAddress();

	/// @notice Invalid signature from the multisig
	error InvalidMultisigSignature();

	/// @notice An error occured when attempting to issue a validation tx for the nodeID
	error ErrorIssuingValidationTx();

	event MinipoolStatusChanged(address indexed nodeID, MinipoolStatus indexed status);

	/**
		@notice Node operators call this function to create a minipool.
		        `nodeID` must not be currently validating. If nodeID has finished validating then this func
						can be called again
						PAYABLE this will accept the AVAX to create the minipool, and the GGP bond amount
		@param nodeID Avalanche node id as 20 bytes (NOT the ASCII text format)
		@param duration Requested validation duration as seconds.
	 */
	function createMinipool(
		address nodeID,
		uint256 duration,
		uint256 delegationFee
	) external payable;

	/**
		@notice Node operators can call this function to cancel a minipool,
		        if and only if the status is Initialised
		@param nodeID Avalanche node id as 20 bytes (NOT the ASCII text format)
	 */
	function cancelMinipool(address nodeID) external;

	/// @notice Force change a minipool status. Maybe remove this.
	function updateMinipoolStatus(address nodeID, MinipoolStatus status) external;

	/**
		@notice Rialto will call this to claim funds (node op and liq staker) to create a validator
		@param nodeID Avalanche node id as 20 bytes (NOT the ASCII text format)
		@param sig Signature that verifies the Rialto multisig identity
	 */
	function claimAndInitiateStaking(address nodeID, bytes calldata sig) external;

	/**
		@notice Rialto will call this to record the start of a successful validation tx
		@param nodeID Avalanche node id as 20 bytes (NOT the ASCII text format)
		@param sig Signature that verifies the Rialto multisig identity
		@param startTime unix time of when the validation period will start
	 */
	function recordStakingStart(
		address nodeID,
		bytes calldata sig,
		uint256 startTime
	) external;

	/**
		@notice Rialto will call this to record the end of a validation period
		@param nodeID Avalanche node id as 20 bytes (NOT the ASCII text format)
		@param sig Signature that verifies the Rialto multisig identity
		@param endTime unix time of when the validation period ended
		@param avaxRewardAmt Amount in gwei of the total rewards paid by the avalanche protocol
	 */
	function recordStakingEnd(
		address nodeID,
		bytes calldata sig,
		uint256 endTime,
		uint256 avaxRewardAmt
	) external;

	/**
		@notice Rialto will call this to record an error while attempting to issue a validation tx
		@param nodeID Avalanche node id as 20 bytes (NOT the ASCII text format)
		@param sig Signature that verifies the Rialto multisig identity
		@param endTime unix time of when the error occured
		@param message Error message
	 */
	function recordStakingError(
		address nodeID,
		bytes calldata sig,
		uint256 endTime,
		string calldata message
	) external;

	function getIndexOf(address nodeID) external view returns (int256);

	function getMinipool(uint256 index)
		external
		view
		returns (
			address nodeID,
			uint256 status,
			uint256 duration,
			uint256 delegationFee
		);
}
