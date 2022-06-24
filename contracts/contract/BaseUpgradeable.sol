pragma solidity ^0.8.13;

import {BaseAbstract} from "./BaseAbstract.sol";
import {IStorage} from "../interface/IStorage.sol";

contract BaseUpgradeable is BaseAbstract {
	function __BaseUpgradeable_init(IStorage _gogoStorageAddress) internal {
		gogoStorage = IStorage(_gogoStorageAddress);
	}
}
