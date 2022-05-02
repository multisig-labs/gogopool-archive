// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import "../../../lib/forge-std/src/Test.sol";
import "../../../contracts/contract/Storage.sol";
import "../../../contracts/contract/Vault.sol";
import "../../../contracts/contract/LaunchManager.sol";
import "../../../contracts/contract/MinipoolManager.sol";
import "../../../contracts/contract/MultisigManager.sol";
import "../../../contracts/contract/dao/ProtocolDAO.sol";
import "../../../contracts/contract/tokens/TokenGGP.sol";
import "../../../contracts/contract/MinipoolQueue.sol";

abstract contract GGPTest is Test {
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
	MinipoolManager public minipoolMgr;
	MultisigManager public multisigMgr;
	LaunchManager public launchMgr;
	ProtocolDAO public dao;
	TokenGGP public ggp;
	MinipoolQueue public minipoolQueue;

	function setUp() public virtual {
		guardian = address(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);
		vm.label(address(guardian), "guardian");

		rialto1 = vm.addr(RIALTO1_PK);
		vm.label(address(rialto1), "rialto1");

		rialto2 = vm.addr(RIALTO2_PK);
		vm.label(address(rialto2), "rialto2");

		// Construct all contracts as Guardian
		vm.startPrank(guardian, guardian);

		store = new Storage();
		initStorage(store);

		vault = new Vault(store);
		registerContract(store, "Vault", address(vault));

		minipoolMgr = new MinipoolManager(store);
		registerContract(store, "MinipoolManager", address(minipoolMgr));

		multisigMgr = new MultisigManager(store);
		registerContract(store, "MultisigManager", address(multisigMgr));

		minipoolQueue = new MinipoolQueue(store);
		registerContract(store, "MinipoolQueue", address(minipoolQueue));

		launchMgr = new LaunchManager(store);
		registerContract(store, "LaunchManager", address(launchMgr));

		dao = new ProtocolDAO(store);
		registerContract(store, "ProtocolDAO", address(dao));
		dao.initialize();

		ggp = new TokenGGP(store);
		registerContract(store, "TokenGGP", address(ggp));

		vm.deal(guardian, 100000 ether);

		vm.stopPrank();
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
		// console.log(string(name), addr);
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
}
