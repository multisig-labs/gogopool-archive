// file for testing erc20upgradeable upgrades

pragma solidity 0.8.17;

import "./utils/BaseTest.sol";

import {MockTokenggAVAXV2} from "./utils/MockTokenggAVAXV2.sol";

contract TokenUpgradeTests is BaseTest {
	function setUp() public override {
		super.setUp();
	}

	function testDomainSeparatorBetweenVersions() public {
		// initialize token
		TokenggAVAX impl = new TokenggAVAX();
		TokenggAVAX proxy = TokenggAVAX(deployProxy(address(impl), guardian));

		proxy.initialize(store, wavax);

		bytes32 oldSeparator = proxy.DOMAIN_SEPARATOR();
		address oldAddress = address(proxy);
		string memory oldName = proxy.name();

		// upgrade implementation
		MockTokenggAVAXV2 impl2 = new MockTokenggAVAXV2();
		vm.prank(guardian);
		proxy.upgradeTo(address(impl2));

		proxy.initialize(store, wavax);

		assertFalse(proxy.DOMAIN_SEPARATOR() == oldSeparator);
		assertEq(address(proxy), oldAddress);
		assertEq(proxy.name(), oldName);
	}
}
