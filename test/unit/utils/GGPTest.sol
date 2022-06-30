pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "../../../lib/forge-std/src/Test.sol";
import "../../../contracts/contract/MinipoolManager.sol";
import "../../../contracts/contract/BaseQueue.sol";
import "../../../contracts/contract/MultisigManager.sol";
import "../../../contracts/contract/Storage.sol";
import "../../../contracts/contract/Vault.sol";
import "../../../contracts/contract/Oracle.sol";
import "../../../contracts/contract/dao/ProtocolDAO.sol";
import "../../../contracts/contract/tokens/TokenGGP.sol";
import "../../../contracts/contract/tokens/TokenggAVAX.sol";
import "../../../contracts/contract/tokens/WAVAX.sol";

import {format} from "./format.sol";

import {ERC20} from "@rari-capital/solmate/src/tokens/ERC20.sol";
import {MockERC20} from "@rari-capital/solmate/src/test/utils/mocks/MockERC20.sol";
import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

abstract contract GGPTest is Test {
	using FixedPointMathLib for uint256;

	address internal constant ZERO_ADDRESS = address(0x00);
	// vm.addr(RIALTO1_PK) gives the address of the private key, We need this because we test rialto signing things
	uint256 internal constant RIALTO1_PK = 0xb4679213567f977dbcdb2323249fd738cc9ff283a7514f3350d344e22c8b571a;
	uint256 internal constant RIALTO2_PK = 0x9c4b7f4ad48f977dbcdb2323249fd738cc9ff283a7514f3350d344e22c5b923d;
	uint256 private randNonce = 0;

	// Users
	address public guardian;
	address public rialto1;
	address public rialto2;

	// Contracts
	Storage public store;
	Vault public vault;
	Oracle public oracle;
	BaseQueue public baseQueue;
	MinipoolManager public minipoolMgr;
	MultisigManager public multisigMgr;
	ProtocolDAO public dao;
	TokenGGP public ggp;
	MockERC20 public mockGGP;
	TokenggAVAX public ggAVAX;
	TokenggAVAX public ggAVAXImpl;
	WAVAX public wavax;

	function setUp() public virtual {
		guardian = address(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);
		vm.label(address(guardian), "guardian");

		rialto1 = vm.addr(RIALTO1_PK);
		vm.label(address(rialto1), "rialto1");

		rialto2 = vm.addr(RIALTO2_PK);
		vm.label(address(rialto2), "rialto2");

		// Construct all contracts as Guardian
		vm.startPrank(guardian, guardian);

		mockGGP = new MockERC20("Mock GGP", "GGP", 18);

		store = new Storage();
		initStorage(store);

		dao = new ProtocolDAO(store);
		registerContract(store, "ProtocolDAO", address(dao));
		dao.initialize();

		vault = new Vault(store);
		registerContract(store, "Vault", address(vault));

		oracle = new Oracle(store);
		registerContract(store, "Oracle", address(oracle));

		baseQueue = new BaseQueue(store);
		registerContract(store, "BaseQueue", address(baseQueue));

		wavax = new WAVAX();

		ggAVAXImpl = new TokenggAVAX();
		ggAVAX = TokenggAVAX(deployProxy(address(ggAVAXImpl), guardian));

		vm.stopPrank();
		ggAVAX.initialize(store, wavax);
		vm.startPrank(guardian, guardian);

		registerContract(store, "TokenggAVAX", address(ggAVAX));

		minipoolMgr = new MinipoolManager(store, mockGGP, ggAVAX);
		registerContract(store, "MinipoolManager", address(minipoolMgr));

		multisigMgr = new MultisigManager(store);
		registerContract(store, "MultisigManager", address(multisigMgr));

		dao = new ProtocolDAO(store);
		registerContract(store, "ProtocolDAO", address(dao));
		dao.initialize();

		ggp = new TokenGGP(store);
		registerContract(store, "TokenGGP", address(ggp));

		// Initialize the rewards cycle
		vm.stopPrank();
		ggAVAX.syncRewards();

		deal(guardian, 1 << 128);
	}

	function initStorage(Storage s) internal {
		// Init any default values we want in storage
		bytes32 protocolDaoSettingsNamespace = keccak256(abi.encodePacked("dao.protocol.setting.", "dao.protocol."));
		s.setUint(keccak256(abi.encodePacked(protocolDaoSettingsNamespace, "ggp.inflation.interval.rate")), 1000133680617113500);
		s.setUint(keccak256(abi.encodePacked(protocolDaoSettingsNamespace, "ggp.inflation.interval.start")), block.timestamp + 1 days);
	}

	// Register a contract in Storage
	function registerContract(
		Storage s,
		bytes memory name,
		address addr
	) internal {
		s.setBool(keccak256(abi.encodePacked("contract.exists", addr)), true);
		s.setAddress(keccak256(abi.encodePacked("contract.address", name)), addr);
		s.setString(keccak256(abi.encodePacked("contract.name", addr)), string(name));
	}

	function registerMultisig(address _addr) internal {
		multisigMgr.registerMultisig(_addr);
		multisigMgr.enableMultisig(_addr);
	}

	// Get a deterministic address for an actor
	function getActor(uint160 index) internal pure returns (address) {
		return address(uint160(0x50000 + index));
	}

	// Get an address with `amount` of funds in WAVAX
	function getActorWithWAVAX(uint160 i, uint128 amount) public returns (address) {
		address actor = getActor(i);
		vm.deal(actor, amount);
		vm.startPrank(actor);
		wavax.deposit{value: amount}();
		wavax.approve(address(ggAVAX), amount);
		vm.stopPrank();
		return actor;
	}

	// Get an address with `amount` of funds in GGP
	function getActorWithGGP(uint160 i, uint128 amount) public returns (address) {
		address actor = getActor(i);
		vm.startPrank(actor);
		mockGGP.mint(actor, amount);
		mockGGP.approve(address(minipoolMgr), amount);
		vm.stopPrank();
		return actor;
	}

	function getActorWithTokens(
		uint160 i,
		uint128 avaxAmt,
		uint128 ggpAmt
	) public returns (address) {
		address actor = getActor(i);
		vm.deal(actor, avaxAmt);
		vm.startPrank(actor);
		wavax.deposit{value: avaxAmt}();
		wavax.approve(address(ggAVAX), avaxAmt);
		vm.deal(actor, avaxAmt);
		mockGGP.mint(actor, ggpAmt);
		mockGGP.approve(address(minipoolMgr), ggpAmt);
		vm.stopPrank();
		return actor;
	}

	function randAddress() internal returns (address) {
		randNonce++;
		return address(uint160(uint256(keccak256(abi.encodePacked(randNonce, blockhash(block.timestamp))))));
	}

	function randUint(uint256 _modulus) internal returns (uint256) {
		randNonce++;
		return uint256(keccak256(abi.encodePacked(randNonce, blockhash(block.timestamp)))) % _modulus;
	}

	// Generate data to create a random minipool for tests
	function randMinipool()
		internal
		returns (
			address,
			uint256,
			uint256
		)
	{
		randNonce++;
		address nodeID = randAddress();
		uint256 duration = randUint(2000000);
		uint256 delegationFee = uint256(0); // TODO make this better
		return (nodeID, duration, delegationFee);
	}

	// Copy over some funcs from DSTestPlus
	string private checkpointLabel;
	uint256 private checkpointGasLeft;

	function startMeasuringGas(string memory label) internal virtual {
		checkpointLabel = label;
		checkpointGasLeft = gasleft();
	}

	function stopMeasuringGas() internal virtual {
		uint256 checkpointGasLeft2 = gasleft();

		string memory label = checkpointLabel;

		emit log_named_uint(string(abi.encodePacked(label, " Gas")), checkpointGasLeft - checkpointGasLeft2);
	}

	function assertBoolEq(bool a, bool b) internal virtual {
		b ? assertTrue(a) : assertFalse(a);
	}

	// Helper to combine r/s/v ECDSA signature into a single bytes
	function combineSigParts(
		uint8 _v,
		bytes32 _r,
		bytes32 s
	) internal pure returns (bytes memory) {
		return abi.encodePacked(_r, s, _v);
	}

	function signHash(uint256 pk, bytes32 h) internal returns (bytes memory) {
		(uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, h);
		return combineSigParts(v, r, s);
	}

	function deployProxy(address impl, address deployer) internal returns (address payable) {
		bytes memory data;
		TransparentUpgradeableProxy uups = new TransparentUpgradeableProxy(address(impl), deployer, data);
		return payable(uups);
	}
}
