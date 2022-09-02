pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./Base.sol";
import {MinipoolManager} from "./MinipoolManager.sol";
import {Oracle} from "./Oracle.sol";
import {Storage} from "./Storage.sol";
import {Vault} from "./Vault.sol";

import {ERC20} from "@rari-capital/solmate/src/mixins/ERC4626.sol";
import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";
import {SafeTransferLib} from "@rari-capital/solmate/src/utils/SafeTransferLib.sol";

/*
	Data Storage Schema
	A "staker" is a user of the protocol who stakes GGP into this contract

	staker.count = Starts at 0 and counts up by 1 after a staker is added.
	staker.index<stakerAddr> = <index> of stakerAddr
	staker.item<index>.stakerAddr = wallet address of staker, used as primary key
	staker.item<index>.ggpStaked = Total amt of GGP staked across all minipools
	staker.item<index>.avaxStaked = Total amt of AVAX staked across all minipools
	staker.item<index>.avaxAssigned = Total amt of liquid staker funds assigned across all minipools
*/

contract Staking is Base {
	using SafeTransferLib for ERC20;
	using SafeTransferLib for address;
	using FixedPointMathLib for uint256;

	// 1 ether = 100%
	uint256 public constant maxCollateralizationPercent = 1.5 ether;
	uint256 public constant minCollateralizationPercent = 0.1 ether;
	ERC20 public immutable ggp;

	uint256 internal constant WAD = 1e18; // The scalar of ETH and most ERC20s.

	/// @notice The staker address does not exist
	error StakerNotFound();

	/// @notice Cannot withdraw GGP if under 150% collateralization ratio
	error CannotWithdrawUnder150CollateralizationRatio();

	error TransferFailed();
	error InsufficientBalance();

	// Not used for storage, just for returning data from view functions
	struct Staker {
		address stakerAddr;
		uint256 ggpStaked;
		uint256 avaxStaked;
		uint256 avaxAssigned;
	}

	event GGPStaked(address indexed from, uint256 amount);
	event GGPWithdrawn(address indexed to, uint256 amount);

	constructor(Storage storageAddress, ERC20 ggp_) Base(storageAddress) {
		version = 1;
		ggp = ggp_;
	}

	// Total GGP in vault assigned to this contract
	function getTotalGGPStake() public view returns (uint256) {
		Vault vault = Vault(getContractAddress("Vault"));
		return vault.balanceOfToken("Staking", ggp);
	}

	function getStakerCount() public view returns (uint256) {
		return getUint(keccak256("staker.count"));
	}

	/* GGP STAKE */
	function getGGPStake(address stakerAddr) public view returns (uint256) {
		int256 index = requireValidStaker(stakerAddr);
		return getUint(keccak256(abi.encodePacked("staker.item", index, ".ggpStaked")));
	}

	function increaseGGPStake(address stakerAddr, uint256 amount) public {
		int256 index = requireValidStaker(stakerAddr);
		addUint(keccak256(abi.encodePacked("staker.item", index, ".ggpStaked")), amount);
	}

	function decreaseGGPStake(address stakerAddr, uint256 amount) public {
		int256 index = requireValidStaker(stakerAddr);
		subUint(keccak256(abi.encodePacked("staker.item", index, ".ggpStaked")), amount);
	}

	/* AVAX STAKE */
	function getAVAXStake(address stakerAddr) public view returns (uint256) {
		int256 index = requireValidStaker(stakerAddr);
		return getUint(keccak256(abi.encodePacked("staker.item", index, ".avaxStaked")));
	}

	function increaseAVAXStake(address stakerAddr, uint256 amount) public {
		int256 index = requireValidStaker(stakerAddr);
		addUint(keccak256(abi.encodePacked("staker.item", index, ".avaxStaked")), amount);
	}

	function decreaseAVAXStake(address stakerAddr, uint256 amount) public {
		int256 index = requireValidStaker(stakerAddr);
		subUint(keccak256(abi.encodePacked("staker.item", index, ".avaxStaked")), amount);
	}

	/* AVAX ASSIGNED */
	function getAVAXAssigned(address stakerAddr) public view returns (uint256) {
		int256 index = requireValidStaker(stakerAddr);
		return getUint(keccak256(abi.encodePacked("staker.item", index, ".avaxAssigned")));
	}

	function increaseAVAXAssigned(address stakerAddr, uint256 amount) public {
		int256 index = requireValidStaker(stakerAddr);
		addUint(keccak256(abi.encodePacked("staker.item", index, ".avaxAssigned")), amount);
	}

	function decreaseAVAXAssigned(address stakerAddr, uint256 amount) public {
		int256 index = requireValidStaker(stakerAddr);
		subUint(keccak256(abi.encodePacked("staker.item", index, ".avaxAssigned")), amount);
	}

	// Get a stakers's minimum ggp stake to collateralize their minipools. Returned in GGP
	function getMinimumGGPStake(address stakerAddr) public view returns (uint256) {
		Oracle oracle = Oracle(getContractAddress("Oracle"));
		(uint256 ggpPriceInAvax, ) = oracle.getGGPPrice();

		uint256 avaxAssigned = getAVAXAssigned(stakerAddr);
		uint256 ggp100pct = avaxAssigned.divWadDown(ggpPriceInAvax);
		return ggp100pct.mulWadDown(minCollateralizationPercent);
	}

	// Returns 0 = 0%, 1 ether = 100%
	function getCollateralizationRatio(address stakerAddr) public view returns (uint256) {
		Oracle oracle = Oracle(getContractAddress("Oracle"));
		(uint256 ggpPriceInAvax, ) = oracle.getGGPPrice();

		uint256 ggpStaked = getGGPStake(stakerAddr);
		uint256 ggpStakedInAvax = ggpStaked.mulWadDown(ggpPriceInAvax);
		uint256 avaxAssigned = getAVAXAssigned(stakerAddr);
		if (ggpStaked == 0 || avaxAssigned == 0) {
			// Infinite collat ratio
			return type(uint256).max;
		}
		return ggpStakedInAvax.divWadDown(avaxAssigned);
	}

	// Accept a GGP stake
	// user must approve the transfer request for amount first
	function stakeGGP(uint256 amount) external {
		// Transfer GGP tokens from staker to this contract
		// TODO this reverts with a arithmetic error if approvals are not correct
		// should we spend gas here to do a better check? How do other protocols handle it?
		ggp.transferFrom(msg.sender, address(this), amount);

		// Deposit GGP tokens from this contract to vault
		Vault vault = Vault(getContractAddress("Vault"));
		ggp.approve(address(vault), amount);
		vault.depositToken("Staking", ggp, amount);

		int256 index = getIndexOf(msg.sender);
		if (index == -1) {
			// create index for the new staker
			index = int256(getUint(keccak256("staker.count")));
			addUint(keccak256("staker.count"), 1);
			setUint(keccak256(abi.encodePacked("staker.index", msg.sender)), uint256(index + 1));
			setAddress(keccak256(abi.encodePacked("staker.item", index, ".stakerAddr")), msg.sender);
		}
		increaseGGPStake(msg.sender, amount);

		emit GGPStaked(msg.sender, amount);
	}

	function withdrawGGP(uint256 amount) external {
		if (amount > getGGPStake(msg.sender)) {
			revert InsufficientBalance();
		}

		decreaseGGPStake(msg.sender, amount);

		if (getCollateralizationRatio(msg.sender) < maxCollateralizationPercent) {
			revert CannotWithdrawUnder150CollateralizationRatio();
		}

		Vault vault = Vault(getContractAddress("Vault"));
		vault.withdrawToken(msg.sender, ggp, amount);

		emit GGPWithdrawn(msg.sender, amount);
	}

	//Minipool Manager will call this if a minipool ended and was not in good standing
	function slashGGP(address stakerAddr, uint256 ggpAmt) public {
		decreaseGGPStake(stakerAddr, ggpAmt);
		// Lets handle the emit in minipool manager
		// TODO So, if we reduce the staker's GGP count in storage, but the GGP is still in the vault, its kind of "unassigned"
		// and floating in there. Maybe we have to move the GGP to the DAO?
	}

	function requireValidStaker(address stakerAddr) public view returns (int256) {
		int256 index = getIndexOf(stakerAddr);
		if (index != -1) {
			return index;
		} else {
			revert StakerNotFound();
		}
	}

	// The index of an item
	// Returns -1 if the value is not found
	function getIndexOf(address stakerAddr) public view returns (int256) {
		return int256(getUint(keccak256(abi.encodePacked("staker.index", stakerAddr)))) - 1;
	}

	function getStaker(int256 index) public view returns (Staker memory staker) {
		staker.ggpStaked = getUint(keccak256(abi.encodePacked("staker.item", index, ".ggpStaked")));
		staker.avaxAssigned = getUint(keccak256(abi.encodePacked("staker.item", index, ".avaxAssigned")));
		staker.avaxStaked = getUint(keccak256(abi.encodePacked("staker.item", index, ".avaxStaked")));
		staker.stakerAddr = getAddress(keccak256(abi.encodePacked("staker.item", index, ".stakerAddr")));
	}

	// Get all stakers (limit=0 means no pagination)
	function getStakers(uint256 offset, uint256 limit) external view returns (Staker[] memory stakers) {
		uint256 totalStakers = getStakerCount();
		uint256 max = offset + limit;
		if (max > totalStakers || limit == 0) {
			max = totalStakers;
		}
		stakers = new Staker[](max - offset);
		uint256 total = 0;
		for (uint256 i = offset; i < max; i++) {
			Staker memory s = getStaker(int256(i));
			stakers[total] = s;
			total++;
		}
		// Dirty hack to cut unused elements off end of return value (from RP)
		// solhint-disable-next-line no-inline-assembly
		assembly {
			mstore(stakers, total)
		}
	}
}
