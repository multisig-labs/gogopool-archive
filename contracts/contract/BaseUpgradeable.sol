// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;

import "./BaseAbstract.sol";
import {Storage} from "./Storage.sol";

contract BaseUpgradeable is BaseAbstract {
	function __BaseUpgradeable_init(Storage _gogoStorageAddress) internal {
		gogoStorage = Storage(_gogoStorageAddress);
	}
}
