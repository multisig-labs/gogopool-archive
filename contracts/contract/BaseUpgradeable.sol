pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./BaseAbstract.sol";
import {Storage} from "./Storage.sol";

contract BaseUpgradeable is BaseAbstract {
	function __BaseUpgradeable_init(Storage _gogoStorageAddress) internal {
		gogoStorage = Storage(_gogoStorageAddress);
	}
}
