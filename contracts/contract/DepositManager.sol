pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "../interface/IStorage.sol";
import "../interface/IDepositManager.sol";
import "../interface/IVault.sol";
import "../types/MinipoolStatus.sol";
import "./Base.sol";

contract DepositManager is Base, IDepositManager {
	constructor(IStorage storageAddress) Base(storageAddress) {
		version = 1;
	}

	// Accept a deposit from a liquid staking user
	function deposit() external payable {
		// Whatever checks we need
		// Mint ggpAVAX to user
		// RocketTokenRETHInterface rocketTokenRETH = RocketTokenRETHInterface(getContractAddress("rocketTokenRETH"));
		// rocketTokenRETH.mint(msg.value, msg.sender);
		// // Emit deposit received event
		// emit DepositReceived(msg.sender, msg.value, block.timestamp);
		// rocketVault.depositEther{value: msg.value}();
		// assign deposits
	}

	function getUserLastDepositTime(address addr) external view returns (uint256) {
		// TODO
		return uint256(0);
	}
}
