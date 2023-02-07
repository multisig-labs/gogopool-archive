// file for testing erc20upgradeable upgrades

pragma solidity 0.8.17;

import "./utils/BaseTest.sol";

import {MockTokenggAVAXV2} from "./utils/MockTokenggAVAXV2.sol";
import {MockTokenggAVAXV2Dangerous} from "./utils/MockTokenggAVAXV2Dangerous.sol";
import {MockTokenggAVAXV2Safe} from "./utils/MockTokenggAVAXV2Safe.sol";

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

	function testStorageGapDangerouslySet() public {
		// initialize token
		TokenggAVAX impl = new TokenggAVAX();
		TokenggAVAX proxy = TokenggAVAX(deployProxy(address(impl), guardian));

		proxy.initialize(store, wavax);

		proxy.syncRewards();
		vm.warp(ggAVAX.rewardsCycleEnd());

		// add some rewards to make sure error error occurs
		address alice = getActorWithTokens("alice", 1000 ether, 0 ether);
		vm.prank(alice);
		wavax.transfer(address(proxy), 1000 ether);
		proxy.syncRewards();

		uint256 oldLastSync = proxy.lastSync();
		bytes32 oldDomainSeparator = proxy.DOMAIN_SEPARATOR();

		// upgrade implementation
		MockTokenggAVAXV2Dangerous impl2 = new MockTokenggAVAXV2Dangerous();
		vm.prank(guardian);
		proxy.upgradeTo(address(impl2));
		proxy.initialize(store, wavax);

		// now lastSync is reading four bytes of lastRewardsAmt
		assertFalse(proxy.lastSync() == oldLastSync);

		// domain separator also does not change but should during regular upgrade
		assertEq(proxy.DOMAIN_SEPARATOR(), oldDomainSeparator);
	}

	function testStorageGapSafe() public {
		// initialize token
		TokenggAVAX impl = new TokenggAVAX();
		TokenggAVAX proxy = TokenggAVAX(deployProxy(address(impl), guardian));

		proxy.initialize(store, wavax);

		proxy.syncRewards();
		uint256 oldLastSync = proxy.lastSync();
		bytes32 oldDomainSeparator = proxy.DOMAIN_SEPARATOR();

		// upgrade implementation
		MockTokenggAVAXV2Safe impl2 = new MockTokenggAVAXV2Safe();
		vm.prank(guardian);
		proxy.upgradeTo(address(impl2));
		proxy.initialize(store, wavax);

		// verify that lastSync is not overwritten during upgrade
		assertEq(proxy.lastSync(), oldLastSync);
		// verify domain separator changes
		assertFalse(proxy.DOMAIN_SEPARATOR() == oldDomainSeparator);
	}
}
