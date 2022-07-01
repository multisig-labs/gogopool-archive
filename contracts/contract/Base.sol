pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./BaseAbstract.sol";
import {Storage} from "./Storage.sol";

abstract contract Base is BaseAbstract {
	/// @dev Set the main GoGo Storage address
	constructor(Storage _gogoStorageAddress) {
		// Update the contract address
		gogoStorage = Storage(_gogoStorageAddress);
	}
}
