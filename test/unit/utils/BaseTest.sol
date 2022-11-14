pragma solidity 0.8.17;

// SPDX-License-Identifier: GPL-3.0-only

import "../../../lib/forge-std/src/Test.sol";
import {MinipoolManager} from "../../../contracts/contract/MinipoolManager.sol";
import {MultisigManager} from "../../../contracts/contract/MultisigManager.sol";
import {Storage} from "../../../contracts/contract/Storage.sol";
import {ClaimNodeOp} from "../../../contracts/contract/ClaimNodeOp.sol";
import {ClaimProtocolDAO} from "../../../contracts/contract/ClaimProtocolDAO.sol";
import {Vault} from "../../../contracts/contract/Vault.sol";
import {Oracle} from "../../../contracts/contract/Oracle.sol";
import {ProtocolDAO} from "../../../contracts/contract/ProtocolDAO.sol";
import {TokenGGP} from "../../../contracts/contract/tokens/TokenGGP.sol";
import {TokenggAVAX} from "../../../contracts/contract/tokens/TokenggAVAX.sol";
import {WAVAX} from "../../../contracts/contract/utils/WAVAX.sol";
import {MinipoolStatus} from "../../../contracts/types/MinipoolStatus.sol";
import {IWithdrawer} from "../../../contracts/interface/IWithdrawer.sol";
import {RewardsPool} from "../../../contracts/contract/RewardsPool.sol";
import {Staking} from "../../../contracts/contract/Staking.sol";
import {Ocyticus} from "../../../contracts/contract/Ocyticus.sol";

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
	ClaimNodeOp public nopClaim;
	ClaimProtocolDAO public daoClaim;
	RewardsPool public rewardsPool;
	Staking public staking;
	Ocyticus public ocyticus;

	function setUp() public virtual {
		guardian = address(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);
		vm.label(guardian, "guardian");

		// Construct all contracts as Guardian
		vm.startPrank(guardian);

		store = new Storage();
		// Hack the storage directly to recognize this test contract as a LatestNetworkContract
		store.setBool(keccak256(abi.encodePacked("contract.exists", address(this))), true);

		dao = new ProtocolDAO(store);
		registerContract(store, "ProtocolDAO", address(dao));
		dao.initialize();
		// override default init for testing
		initDao();

		vault = new Vault(store);
		registerContract(store, "Vault", address(vault));

		oracle = new Oracle(store);
		registerContract(store, "Oracle", address(oracle));

		ggp = new TokenGGP();
		registerContract(store, "TokenGGP", address(ggp));

		wavax = new WAVAX();

		ggAVAXImpl = new TokenggAVAX();
		ggAVAX = TokenggAVAX(deployProxy(address(ggAVAXImpl), guardian));
		registerContract(store, "TokenggAVAX", address(ggAVAX));

		vm.stopPrank();
		ggAVAX.initialize(store, wavax);
		vm.startPrank(guardian);

		minipoolMgr = new MinipoolManager(store, ggp, ggAVAX);
		registerContract(store, "MinipoolManager", address(minipoolMgr));

		multisigMgr = new MultisigManager(store);
		registerContract(store, "MultisigManager", address(multisigMgr));

		rialto = getActor("rialto");
		multisigMgr.registerMultisig(rialto);
		multisigMgr.enableMultisig(rialto);

		staking = new Staking(store, ggp);
		registerContract(store, "Staking", address(staking));

		nopClaim = new ClaimNodeOp(store, ggp);
		registerContract(store, "ClaimNodeOp", address(nopClaim));

		daoClaim = new ClaimProtocolDAO(store);
		registerContract(store, "ClaimProtocolDAO", address(daoClaim));

		rewardsPool = new RewardsPool(store);
		registerContract(store, "RewardsPool", address(rewardsPool));
		rewardsPool.initialize();

		ocyticus = new Ocyticus(store);
		registerContract(store, "Ocyticus", address(ocyticus));

		// Initialize the rewards cycle
		vm.stopPrank();
		ggAVAX.syncRewards();

		vm.prank(rialto);
		oracle.setGGPPriceInAVAX(1 ether, block.timestamp);

		deal(guardian, type(uint128).max);
	}

	// Override DAO values for tests
	function initDao() internal {
		// ClaimNodeOp
		store.setUint(keccak256("ProtocolDAO.RewardsEligibilityMinSeconds"), 14 days);

		// RewardsPool
		store.setUint(keccak256("ProtocolDAO.RewardsCycleSeconds"), 28 days); // The time in which a claim period will span in seconds - 28 days by default
		store.setUint(keccak256("ProtocolDAO.TotalGGPCirculatingSupply"), 18_000_000 ether);
		store.setUint(keccak256("ProtocolDAO.ClaimingContractPct.ClaimMultisig"), 0.20 ether);
		store.setUint(keccak256("ProtocolDAO.ClaimingContractPct.ClaimNodeOp"), 0.70 ether);
		store.setUint(keccak256("ProtocolDAO.ClaimingContractPct.ClaimProtocolDAO"), 0.10 ether);

		// GGP Inflation settings may change when we finialize tokenomics
		store.setUint(keccak256("ProtocolDAO.InflationInterval"), 1 days);
		store.setUint(keccak256("ProtocolDAO.InflationIntervalRate"), 1000133680617113500); // 5% annual calculated on a daily interval - Calculate in js example: let dailyInflation = web3.utils.toBN((1 + 0.05) ** (1 / (365)) * 1e18);

		// TokenGGAVAX
		store.setUint(keccak256("ProtocolDAO.TargetGGAVAXReserveRate"), 0.1 ether); // 10% collateral held in reserve

		// Minipool
		store.setUint(keccak256("ProtocolDAO.MinipoolMinAVAXStakingAmt"), 2_000 ether);
		store.setUint(keccak256("ProtocolDAO.MinipoolNodeCommissionFeePct"), 0.15 ether);
		store.setUint(keccak256("ProtocolDAO.MinipoolMaxAVAXAssignment"), 10_000 ether);
		store.setUint(keccak256("ProtocolDAO.MinipoolMinAVAXAssignment"), 1_000 ether);
		store.setUint(keccak256("ProtocolDAO.ExpectedAVAXRewardsRate"), 0.1 ether);

		// Staking
		store.setUint(keccak256("ProtocolDAO.MaxCollateralizationRatio"), 1.5 ether);
		store.setUint(keccak256("ProtocolDAO.MinCollateralizationRatio"), 0.1 ether);
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

			vm.prank(actor);
			wavax.deposit{value: avaxAmt}();

			vm.deal(actor, avaxAmt);
		}

		return actor;
	}

	function dealGGP(address actor, uint256 amount) public {
		vm.prank(guardian);
		ggp.transfer(actor, amount);
	}

	function createMinipool(
		uint256 depositAmt,
		uint256 avaxAssignmentRequest,
		uint256 duration
	) internal returns (MinipoolManager.Minipool memory) {
		address nodeID = randAddress();
		uint256 delegationFee = 0.02 ether;
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
		return address(uint160(uint256(randHash())));
	}

	function randUint(uint256 _modulus) internal returns (uint256) {
		randNonce++;
		return uint256(randHash()) % _modulus;
	}

	function randUintBetween(uint256 lowerBound, uint256 upperBound) internal returns (uint256) {
		randNonce++;
		uint256 bound = uint256(randHash()) % (upperBound - lowerBound);
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
