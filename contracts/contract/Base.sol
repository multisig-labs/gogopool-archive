pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import {BaseAbstract} from "./BaseAbstract.sol";
import {IStorage} from "../interface/IStorage.sol";

abstract contract Base is BaseAbstract {
	/// @dev Set the main GoGo Storage address
	constructor(IStorage _gogoStorageAddress) {
		// Update the contract address
		gogoStorage = IStorage(_gogoStorageAddress);
	}
}
