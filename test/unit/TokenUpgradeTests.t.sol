// file for testing erc20upgradeable upgrades

pragma solidity 0.8.17;

import "./utils/BaseTest.sol";

import {MockTokenggAVAXV2} from "./utils/MockTokenggAVAXV2.sol";
import {MockTokenggAVAXV2Dangerous} from "./utils/MockTokenggAVAXV2Dangerous.sol";
import {MockTokenggAVAXV2Safe} from "./utils/MockTokenggAVAXV2Safe.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract TokenUpgradeTests is BaseTest {
	address public constant DEPLOYER = address(12345);

	function setUp() public override {
		super.setUp();
	}

	function testDeployTransparentProxy() public {
		// deploy token contract
		vm.startPrank(DEPLOYER);

		ProxyAdmin proxyAdmin = new ProxyAdmin();
		TokenggAVAX ggAVAXImpl = new TokenggAVAX();

		TransparentUpgradeableProxy ggAVAXProxy = new TransparentUpgradeableProxy(
			address(ggAVAXImpl),
			address(proxyAdmin),
			abi.encodeWithSelector(ggAVAXImpl.initialize.selector, store, wavax, 0)
		);
		TokenggAVAX token = TokenggAVAX(payable(address(ggAVAXProxy)));

		assertEq(proxyAdmin.getProxyImplementation(ggAVAXProxy), address(ggAVAXImpl));
		proxyAdmin.transferOwnership(guardian);
		vm.stopPrank();

		// verify token works
		address alice = getActorWithTokens("alice", 100 ether, 0);
		vm.deal(alice, MAX_AMT);
		vm.startPrank(alice);
		uint256 shareAmount = token.depositAVAX{value: 100 ether}();
		assertEq(shareAmount, 100 ether);
		assertEq(token.totalAssets(), 100 ether);
		assertEq(token.balanceOf(alice), 100 ether);
		vm.stopPrank();
		assertEq(proxyAdmin.owner(), guardian);

		// upgrade contract
		vm.prank(DEPLOYER);
		MockTokenggAVAXV2 ggAVAXImplV2 = new MockTokenggAVAXV2();

		vm.prank(guardian);
		proxyAdmin.upgrade(ggAVAXProxy, address(ggAVAXImplV2));

		// Verify data is still there
		assertEq(shareAmount, 100 ether);
		assertEq(token.totalAssets(), 100 ether);
		assertEq(token.balanceOf(alice), 100 ether);

		assertEq(proxyAdmin.getProxyImplementation(ggAVAXProxy), address(ggAVAXImplV2));
	}

	function testDomainSeparatorBetweenVersions() public {
		// initialize token
		vm.startPrank(DEPLOYER);
		ProxyAdmin proxyAdmin = new ProxyAdmin();
		TokenggAVAX impl = new TokenggAVAX();

		TransparentUpgradeableProxy transparentProxy = new TransparentUpgradeableProxy(
			address(impl),
			address(proxyAdmin),
			abi.encodeWithSelector(impl.initialize.selector, store, wavax, 0)
		);

		TokenggAVAX proxy = TokenggAVAX(payable(address(transparentProxy)));

		proxyAdmin.transferOwnership(guardian);
		vm.stopPrank();

		bytes32 oldSeparator = proxy.DOMAIN_SEPARATOR();
		address oldAddress = address(proxy);
		string memory oldName = proxy.name();
		console.log("fail here?");

		// upgrade implementation
		vm.prank(DEPLOYER);
		MockTokenggAVAXV2 impl2 = new MockTokenggAVAXV2();

		vm.prank(guardian);
		proxyAdmin.upgradeAndCall(transparentProxy, address(impl2), abi.encodeWithSelector(impl2.initialize.selector, store, wavax, 0));

		assertFalse(proxy.DOMAIN_SEPARATOR() == oldSeparator);
		assertEq(address(proxy), oldAddress);
		assertEq(proxy.name(), oldName);
	}

	function testStorageGapDangerouslySet() public {
		// initialize token
		vm.startPrank(DEPLOYER);
		ProxyAdmin proxyAdmin = new ProxyAdmin();
		TokenggAVAX impl = new TokenggAVAX();

		TransparentUpgradeableProxy transparentProxy = new TransparentUpgradeableProxy(
			address(impl),
			address(proxyAdmin),
			abi.encodeWithSelector(impl.initialize.selector, store, wavax, 0)
		);

		TokenggAVAX proxy = TokenggAVAX(payable(address(transparentProxy)));

		proxyAdmin.transferOwnership(guardian);
		vm.stopPrank();

		// add some rewards to make sure error error occurs
		address alice = getActorWithTokens("alice", 1000 ether, 0 ether);
		vm.prank(alice);
		wavax.transfer(address(proxy), 1000 ether);
		proxy.syncRewards();

		uint256 oldLastSync = proxy.lastSync();
		bytes32 oldDomainSeparator = proxy.DOMAIN_SEPARATOR();

		// upgrade implementation
		vm.prank(DEPLOYER);
		MockTokenggAVAXV2Dangerous impl2 = new MockTokenggAVAXV2Dangerous();

		vm.prank(guardian);
		proxyAdmin.upgradeAndCall(transparentProxy, address(impl2), abi.encodeWithSelector(impl2.initialize.selector, store, wavax, 0));

		// now lastSync is reading four bytes of lastRewardsAmt
		assertFalse(proxy.lastSync() == oldLastSync);

		// domain separator also does not change but should during regular upgrade
		assertEq(proxy.DOMAIN_SEPARATOR(), oldDomainSeparator);
	}

	function testStorageGapSafe() public {
		// initialize token
		vm.startPrank(DEPLOYER);
		ProxyAdmin proxyAdmin = new ProxyAdmin();
		TokenggAVAX impl = new TokenggAVAX();

		TransparentUpgradeableProxy transparentProxy = new TransparentUpgradeableProxy(
			address(impl),
			address(proxyAdmin),
			abi.encodeWithSelector(impl.initialize.selector, store, wavax, 0)
		);

		TokenggAVAX proxy = TokenggAVAX(payable(address(transparentProxy)));

		proxyAdmin.transferOwnership(guardian);
		vm.stopPrank();

		proxy.syncRewards();
		uint256 oldLastSync = proxy.lastSync();
		bytes32 oldDomainSeparator = proxy.DOMAIN_SEPARATOR();

		// upgrade implementation
		vm.prank(DEPLOYER);
		MockTokenggAVAXV2Safe impl2 = new MockTokenggAVAXV2Safe();
		vm.prank(guardian);
		proxyAdmin.upgradeAndCall(transparentProxy, address(impl2), abi.encodeWithSelector(impl2.initialize.selector, store, wavax, 0));

		// verify that lastSync is not overwritten during upgrade
		assertEq(proxy.lastSync(), oldLastSync);
		// verify domain separator changes
		assertFalse(proxy.DOMAIN_SEPARATOR() == oldDomainSeparator);
	}
}
