pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "../../../lib/forge-std/src/Test.sol";
import {MinipoolManager} from "../../../contracts/contract/MinipoolManager.sol";
import {MultisigManager} from "../../../contracts/contract/MultisigManager.sol";
import {Storage} from "../../../contracts/contract/Storage.sol";
import {ProtocolDAOClaim} from "../../../contracts/contract/rewards/claims/ProtocolDAOClaim.sol";
import {Vault} from "../../../contracts/contract/Vault.sol";
import {Oracle} from "../../../contracts/contract/Oracle.sol";
import {ProtocolDAO} from "../../../contracts/contract/dao/ProtocolDAO.sol";
import {NOPClaim} from "../../../contracts/contract/rewards/claims/NOPClaim.sol";
import {TokenGGP} from "../../../contracts/contract/tokens/TokenGGP.sol";
import {TokenggAVAX} from "../../../contracts/contract/tokens/TokenggAVAX.sol";
import {WAVAX} from "../../../contracts/contract/tokens/WAVAX.sol";
import {MinipoolStatus} from "../../../contracts/types/MinipoolStatus.sol";
import {IWithdrawer} from "../../../contracts/interface/IWithdrawer.sol";
import {RewardsPool} from "../../../contracts/contract/rewards/RewardsPool.sol";
import {Staking} from "../../../contracts/contract/Staking.sol";

import {format} from "sol-utils/format.sol";
import {ERC20} from "@rari-capital/solmate/src/tokens/ERC20.sol";
import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

abstract contract BaseTest is Test {
	address internal constant ZERO_ADDRESS = address(0x00);
	uint128 internal constant MAX_AMT = 1_000_000 ether;

	uint256 private randNonce = 0;
	uint160 private actorCounter = 0;

	// Global Users
	address public guardian;
	address public rialto;

	// Contracts
	Storage public store;
	Vault public vault;
	Oracle public oracle;
	TokenGGP public ggp;
	TokenggAVAX public ggAVAX;
	TokenggAVAX public ggAVAXImpl;
	WAVAX public wavax;
	MinipoolManager public minipoolMgr;
	MultisigManager public multisigMgr;
	ProtocolDAO public dao;
	ProtocolDAOClaim public daoClaim;
	RewardsPool public rewardsPool;
	NOPClaim public nopClaim;
	Staking public staking;

	function setUp() public virtual {
		guardian = address(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);
		vm.label(guardian, "guardian");

		// Construct all contracts as Guardian
		vm.startPrank(guardian, guardian);

		store = new Storage();
		initStorage(store);

		dao = new ProtocolDAO(store);
		registerContract(store, "ProtocolDAO", address(dao));
		dao.initialize();

		vault = new Vault(store);
		registerContract(store, "Vault", address(vault));

		oracle = new Oracle(store);
		oracle.setGGPPrice(1 ether, block.timestamp);
		registerContract(store, "Oracle", address(oracle));

		ggp = new TokenGGP(store);
		registerContract(store, "TokenGGP", address(ggp));

		wavax = new WAVAX();

		ggAVAXImpl = new TokenggAVAX();
		ggAVAX = TokenggAVAX(deployProxy(address(ggAVAXImpl), guardian));
		registerContract(store, "TokenggAVAX", address(ggAVAX));

		vm.stopPrank();
		ggAVAX.initialize(store, wavax);
		vm.startPrank(guardian, guardian);

		minipoolMgr = new MinipoolManager(store, ggp, ggAVAX);
		registerContract(store, "MinipoolManager", address(minipoolMgr));

		multisigMgr = new MultisigManager(store);
		registerContract(store, "MultisigManager", address(multisigMgr));

		rialto = getActor("rialto");
		registerMultisig(rialto);

		dao = new ProtocolDAO(store);
		registerContract(store, "ProtocolDAO", address(dao));
		initDao();

		staking = new Staking(store, ggp);
		registerContract(store, "Staking", address(staking));

		daoClaim = new ProtocolDAOClaim(store);
		registerContract(store, "ProtocolDAOClaim", address(daoClaim));

		rewardsPool = new RewardsPool(store);
		registerContract(store, "RewardsPool", address(rewardsPool));

		nopClaim = new NOPClaim(store, ggp);
		registerContract(store, "NOPClaim", address(nopClaim));

		// Initialize the rewards cycle
		vm.stopPrank();
		ggAVAX.syncRewards();

		deal(guardian, type(uint128).max);
	}

	// Global settings we need for tests
	function initStorage(Storage s) internal {}

	// Override DAO values for tests
	function initDao() internal {
		store.setUint(keccak256("avalanche.expectedRewardRate"), 0.1 ether);
		// GGP Inflation settings
		// these may change when we finialize tokenomics
		store.setUint(keccak256("ggp.inflation.intervalRate"), 1000133680617113500); // 5% annual calculated on a daily interval - Calculate in js example: let dailyInflation = web3.utils.toBN((1 + 0.05) ** (1 / (365)) * 1e18);
		store.setUint(keccak256("ggp.inflation.intervalStart"), (block.timestamp + 1 days)); // Set the default start date for inflation to begin as 1 day after deployment
		store.setUint(keccak256("ggp.inflation.interval"), 1 days);
		store.setUint(keccak256("ggAvax.reserveTarget"), 0.1 ether); // 10% collateral held in reserver
		//Delegation duration limit set to 2 Months
		store.setUint(keccak256("delegation.maxDuration"), 5097600);

		// Minipool Settings
		store.setUint(keccak256("minipool.minStakingAmount"), 2000 ether);
		store.setUint(keccak256("minipool.nodeCommision"), 0.15 ether);
		store.setUint(keccak256("minipool.maxAvaxAssignment"), 10_000 ether);
		store.setUint(keccak256("minipool.minAvaxAssignment"), 1_000 ether);
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

	function registerMultisig(address addr) internal {
		multisigMgr.registerMultisig(addr);
		multisigMgr.enableMultisig(addr);
	}

	function getActor(string memory name) public returns (address) {
		actorCounter++;
		address addr = address(uint160(0x50000 + actorCounter));
		vm.label(addr, name);
		return addr;
	}

	// Return new address with AVAX and WAVAX and GGP
	function getActorWithTokens(
		string memory name,
		uint128 avaxAmt,
		uint128 ggpAmt
	) public returns (address) {
		address actor = getActor(name);

		if (ggpAmt > 0) {
			dealGGP(actor, ggpAmt);
		}

		if (avaxAmt > 0) {
			vm.deal(actor, avaxAmt);

			vm.startPrank(actor);
			wavax.deposit{value: avaxAmt}();
			vm.stopPrank();

			vm.deal(actor, avaxAmt);
		}

		return actor;
	}

	function dealGGP(address actor, uint128 amount) public {
		vm.startPrank(guardian);
		ggp.transfer(actor, amount);
		vm.stopPrank();
	}

	function createMinipool(
		uint256 depositAmt,
		uint256 avaxAssignmentRequest,
		uint256 duration
	) internal returns (MinipoolManager.Minipool memory) {
		address nodeID = randAddress();
		uint256 delegationFee = uint256(20_000);
		minipoolMgr.createMinipool{value: depositAmt}(nodeID, duration, delegationFee, avaxAssignmentRequest);
		int256 index = minipoolMgr.getIndexOf(nodeID);
		return minipoolMgr.getMinipool(index);
	}

	function randHash() internal returns (bytes32) {
		randNonce++;
		return keccak256(abi.encodePacked(randNonce, blockhash(block.timestamp)));
	}

	function randAddress() internal returns (address) {
		randNonce++;
		return address(uint160(uint256(keccak256(abi.encodePacked(randNonce, blockhash(block.timestamp))))));
	}

	function randUint(uint256 _modulus) internal returns (uint256) {
		randNonce++;
		return uint256(keccak256(abi.encodePacked(randNonce, blockhash(block.timestamp)))) % _modulus;
	}

	function randUintBetween(uint256 lowerBound, uint256 upperBound) internal returns (uint256) {
		randNonce++;
		uint256 bound = uint256(keccak256(abi.encodePacked(randNonce, blockhash(block.timestamp)))) % (upperBound - lowerBound);
		uint256 randomNum = bound + lowerBound;
		return randomNum;
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

	function deployProxy(address impl, address deployer) internal returns (address payable) {
		bytes memory data;
		TransparentUpgradeableProxy uups = new TransparentUpgradeableProxy(address(impl), deployer, data);
		return payable(uups);
	}
}
