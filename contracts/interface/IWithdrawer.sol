pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

interface IWithdrawer {
	function receiveVaultWithdrawalETH() external payable;
}
