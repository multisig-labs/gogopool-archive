// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
import "./utils/GGPTest.sol";
import "../../contracts/contract/tokens/TokenGGP.sol";
import "../../contracts/contract/Storage.sol";

contract TokenGGPTest is GGPTest {
	address constant deployer = address(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);
	address constant storageUpdater = address(0xDEADBEEF);
	address constant zeroAddress = address(0x0);
	Storage s;
	TokenGGP t;

	function setUp() public {
		s = new Storage();
		t = new TokenGGP(s);

		vm.startPrank(deployer, deployer);
		s.setBool(keccak256(abi.encodePacked("contract.exists", address(t))), true);
		s.setAddress(keccak256(abi.encodePacked("contract.address", "tokenGGP")), address(t));
		vm.stopPrank();
	}
}
