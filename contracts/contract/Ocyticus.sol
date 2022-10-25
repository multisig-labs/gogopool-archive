// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.13;
import {Base} from "./Base.sol";
import {Storage} from "./Storage.sol";
import {ProtocolDAO} from "./dao/ProtocolDAO.sol";
import {MultisigManager} from "./MultisigManager.sol";

// Panic when we want to pause the protocol

// Maintain a list of EOAs that are allowed to emergency pause the protocol
// but not modify any other settings like a guardian would be able to
contract Ocyticus is Base {
	error NotAllowed();

	mapping(address => bool) public defenders;

	modifier onlyDefender() {
		if (!defenders[msg.sender]) {
			revert NotAllowed();
		}
		_;
	}

	constructor(Storage storageAddress) Base(storageAddress) {
		defenders[msg.sender] = true;
	}

	function addDefender(address defender) external onlyGuardian {
		defenders[defender] = true;
	}

	function removeDefender(address defender) external onlyGuardian {
		delete defenders[defender];
	}

	function pauseEverything() external onlyDefender {
		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		dao.pauseContract("TokenggAVAX");
	}

	function resumeEverything() external onlyDefender {
		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		dao.resumeContract("TokenggAVAX");
	}

	function disableAllMultisigs() external onlyDefender {
		MultisigManager mm = MultisigManager(getContractAddress("MultisigManager"));
		uint256 count = mm.getCount();

		address addr;
		bool enabled;
		for (uint256 i = 0; i < count; i++) {
			(addr, enabled) = mm.getMultisig(i);
			if (enabled) {
				mm.disableMultisig(addr);
			}
		}
	}
}