pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "../../Base.sol";
import {Storage} from "../../Storage.sol";
import {Vault} from "../../Vault.sol";
import {TokenGGP} from "../../tokens/TokenGGP.sol";
import {ProtocolDAO} from "../../dao/ProtocolDAO.sol";

// RPL Rewards claiming by the DAO
contract ProtocolDAOClaim is Base {
	// Events
	event GGPTokensSentByDAOProtocol(string invoiceID, address indexed from, address indexed to, uint256 amount, uint256 time);

	// Construct
	constructor(Storage storageAddress) Base(storageAddress) {
		// Version
		version = 1;
	}

	// Spend the network DAOs RPL rewards
	// todo add onlyLatestContract("rocketDAOProtocolProposals", msg.sender)
	function spend(
		string memory _invoiceID,
		address _recipientAddress,
		uint256 _amount
	) external {
		// Load contracts
		Vault vault = Vault(getContractAddress("Vault"));
		// Addresses
		TokenGGP ggpToken = TokenGGP(getContractAddress("TokenGGP"));
		// Some initial checks
		require(
			_amount > 0 && _amount <= vault.balanceOfToken("ProtocolDAOClaim", ggpToken),
			"You cannot send 0 GGP or more than the DAO has in its account"
		);
		// Send now
		vault.withdrawToken(_recipientAddress, ggpToken, _amount);
		// Log it
		emit GGPTokensSentByDAOProtocol(_invoiceID, address(this), _recipientAddress, _amount, block.timestamp);
	}
}
