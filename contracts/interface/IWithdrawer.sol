pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

interface IWithdrawer {
	function receiveVaultWithdrawalAVAX() external payable;
}
