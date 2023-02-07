// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.17;

import "./Base.sol";
import {MinipoolManager} from "./MinipoolManager.sol";
import {Oracle} from "./Oracle.sol";
import {ProtocolDAO} from "./ProtocolDAO.sol";
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
	staker.item<index>.avaxValidating = Total amt of liquid staker funds used for validation across all minipools
	staker.item<index>.avaxValidatingHighWater = Highest amt of liquid staker funds used for validation during a GGP rewards cycle
*/

/// @title GGP staking and staker attributes
contract Staking is Base {
	using SafeTransferLib for ERC20;
	using SafeTransferLib for address;
	using FixedPointMathLib for uint256;

	error CannotWithdrawUnder150CollateralizationRatio();
	error InsufficientBalance();
	error InvalidRewardsStartTime();
	error StakerNotFound();

	event GGPStaked(address indexed from, uint256 amount);
	event GGPWithdrawn(address indexed to, uint256 amount);

	/// @dev Not used for storage, just for returning data from view functions
	struct Staker {
		address stakerAddr;
		uint256 ggpStaked;
		uint256 avaxStaked;
		uint256 avaxAssigned;
		uint256 avaxValidating;
		uint256 avaxValidatingHighWater;
		uint256 minipoolCount;
		uint256 rewardsStartTime;
		uint256 ggpRewards;
		uint256 lastRewardsCycleCompleted;
	}

	uint256 internal constant TENTH = 0.1 ether;

	ERC20 public immutable ggp;

	constructor(Storage storageAddress, ERC20 ggp_) Base(storageAddress) {
		version = 1;
		ggp = ggp_;
	}

	/// @notice Total GGP (stored in vault) assigned to this contract
	function getTotalGGPStake() public view returns (uint256) {
		Vault vault = Vault(getContractAddress("Vault"));
		return vault.balanceOfToken("Staking", ggp);
	}

	/// @notice Total count of GGP stakers in the protocol
	function getStakerCount() public view returns (uint256) {
		return getUint(keccak256("staker.count"));
	}

	/* GGP STAKE */

	/// @notice The amount of GGP a given staker is staking
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function getGGPStake(address stakerAddr) public view returns (uint256) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		return getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".ggpStaked")));
	}

	/// @notice Increase the amount of GGP a given staker is staking
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function increaseGGPStake(address stakerAddr, uint256 amount) internal {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		addUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".ggpStaked")), amount);
	}

	/// @notice Decrease the amount of GGP a given staker is staking
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function decreaseGGPStake(address stakerAddr, uint256 amount) internal {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		subUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".ggpStaked")), amount);
	}

	/* AVAX STAKE */

	/// @notice The amount of AVAX a given staker is staking
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function getAVAXStake(address stakerAddr) public view returns (uint256) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		return getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxStaked")));
	}

	/// @notice Increase the amount of AVAX a given staker is staking
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function increaseAVAXStake(address stakerAddr, uint256 amount) public onlySpecificRegisteredContract("MinipoolManager", msg.sender) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		addUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxStaked")), amount);
	}

	/// @notice Decrease the amount of AVAX a given staker is staking
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function decreaseAVAXStake(address stakerAddr, uint256 amount) public onlySpecificRegisteredContract("MinipoolManager", msg.sender) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		subUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxStaked")), amount);
	}

	/* AVAX ASSIGNED + REQUESTED */

	/// @notice The amount of AVAX a given staker is assigned by the protocol (for minipool creation)
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function getAVAXAssigned(address stakerAddr) public view returns (uint256) {
		int256 stakerIndex = getIndexOf(stakerAddr);
		return getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxAssigned")));
	}

	/// @notice Increase the amount of AVAX a given staker is assigned by the protocol (for minipool creation)
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function increaseAVAXAssigned(address stakerAddr, uint256 amount) public onlySpecificRegisteredContract("MinipoolManager", msg.sender) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		addUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxAssigned")), amount);
	}

	/// @notice Decrease the amount of AVAX a given staker is assigned by the protocol (for minipool creation)
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function decreaseAVAXAssigned(address stakerAddr, uint256 amount) public onlySpecificRegisteredContract("MinipoolManager", msg.sender) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		subUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxAssigned")), amount);
	}

	/* AVAX VALIDATING */

	/// @notice The amount of AVAX a given staker has validating
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function getAVAXValidating(address stakerAddr) public view returns (uint256) {
		int256 stakerIndex = getIndexOf(stakerAddr);
		return getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxValidating")));
	}

	/// @notice Increase the amount of AVAX a given staker has validating
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	/// @param amount Amount to increase
	function increaseAVAXValidating(address stakerAddr, uint256 amount) public onlySpecificRegisteredContract("MinipoolManager", msg.sender) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		addUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxValidating")), amount);
	}

	/// @notice Decrease the amount of AVAX a given staker has validating
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	/// @param amount Amount to decrease
	function decreaseAVAXValidating(address stakerAddr, uint256 amount) public onlySpecificRegisteredContract("MinipoolManager", msg.sender) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		subUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxValidating")), amount);
	}

	/* AVAX VALIDATING HIGH-WATER */

	/// @notice Largest total AVAX amt assigned to a staker during a rewards period
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function getAVAXValidatingHighWater(address stakerAddr) public view returns (uint256) {
		int256 stakerIndex = getIndexOf(stakerAddr);
		return getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxValidatingHighWater")));
	}

	/// @notice Set AVAXValidatingHighWater to value passed in
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	/// @param amount New value for AVAXValidatingHighWater
	function setAVAXValidatingHighWater(address stakerAddr, uint256 amount) public onlyRegisteredNetworkContract {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		setUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxValidatingHighWater")), amount);
	}

	/* MINIPOOL COUNT */

	/// @notice The number of minipools the given staker has
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function getMinipoolCount(address stakerAddr) public view returns (uint256) {
		int256 stakerIndex = getIndexOf(stakerAddr);
		return getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".minipoolCount")));
	}

	/// @notice Increase the number of minipools the given staker has
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function increaseMinipoolCount(address stakerAddr) public onlySpecificRegisteredContract("MinipoolManager", msg.sender) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		addUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".minipoolCount")), 1);
	}

	/// @notice Decrease the number of minipools the given staker has
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function decreaseMinipoolCount(address stakerAddr) public onlySpecificRegisteredContract("MinipoolManager", msg.sender) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		subUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".minipoolCount")), 1);
	}

	/* REWARDS START TIME */

	/// @notice The timestamp when the staker registered for GGP rewards
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function getRewardsStartTime(address stakerAddr) public view returns (uint256) {
		int256 stakerIndex = getIndexOf(stakerAddr);
		return getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".rewardsStartTime")));
	}

	/// @notice Set the timestamp when the staker registered for GGP rewards
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	// TODO cant use onlySpecificRegisteredContract("ClaimNodeOp", msg.sender) since we also call from increaseMinipoolCount. Wat do?
	function setRewardsStartTime(address stakerAddr, uint256 time) public onlyRegisteredNetworkContract {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		if (time > block.timestamp) {
			revert InvalidRewardsStartTime();
		}

		setUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".rewardsStartTime")), time);
	}

	/* GGP REWARDS */

	/// @notice The amount of GGP rewards the staker has earned and not claimed
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function getGGPRewards(address stakerAddr) public view returns (uint256) {
		int256 stakerIndex = getIndexOf(stakerAddr);
		return getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".ggpRewards")));
	}

	/// @notice Increase the amount of GGP rewards the staker has earned and not claimed
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function increaseGGPRewards(address stakerAddr, uint256 amount) public onlySpecificRegisteredContract("ClaimNodeOp", msg.sender) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		addUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".ggpRewards")), amount);
	}

	/// @notice Decrease the amount of GGP rewards the staker has earned and not claimed
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function decreaseGGPRewards(address stakerAddr, uint256 amount) public onlySpecificRegisteredContract("ClaimNodeOp", msg.sender) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		subUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".ggpRewards")), amount);
	}

	/* LAST REWARDS CYCLE PAID OUT */

	/// @notice The most recent reward cycle number that the staker has been paid out for
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function getLastRewardsCycleCompleted(address stakerAddr) public view returns (uint256) {
		int256 stakerIndex = getIndexOf(stakerAddr);
		return getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".lastRewardsCycleCompleted")));
	}

	/// @notice Set the most recent reward cycle number that the staker has been paid out for
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	/// @param cycleNumber The cycle that the staker was just rewarded for
	function setLastRewardsCycleCompleted(address stakerAddr, uint256 cycleNumber) public onlySpecificRegisteredContract("ClaimNodeOp", msg.sender) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		setUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".lastRewardsCycleCompleted")), cycleNumber);
	}

	/// @notice Get a stakers's minimum GGP stake to collateralize their minipools, based on current GGP price
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	/// @return Amount of GGP
	function getMinimumGGPStake(address stakerAddr) public view returns (uint256) {
		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		Oracle oracle = Oracle(getContractAddress("Oracle"));
		(uint256 ggpPriceInAvax, ) = oracle.getGGPPriceInAVAX();

		uint256 avaxAssigned = getAVAXAssigned(stakerAddr);
		uint256 ggp100pct = avaxAssigned.divWadDown(ggpPriceInAvax);
		return ggp100pct.mulWadDown(dao.getMinCollateralizationRatio());
	}

	/// @notice Returns collateralization ratio based on current GGP price
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	/// @return A ratio where 0 = 0%, 1 ether = 100%
	function getCollateralizationRatio(address stakerAddr) public view returns (uint256) {
		uint256 avaxAssigned = getAVAXAssigned(stakerAddr);
		if (avaxAssigned == 0) {
			// Infinite collat ratio
			return type(uint256).max;
		}
		Oracle oracle = Oracle(getContractAddress("Oracle"));
		(uint256 ggpPriceInAvax, ) = oracle.getGGPPriceInAVAX();
		uint256 ggpStakedInAvax = getGGPStake(stakerAddr).mulWadDown(ggpPriceInAvax);
		return ggpStakedInAvax.divWadDown(avaxAssigned);
	}

	/// @notice Returns effective collateralization ratio which will be used to pay out rewards
	///         based on current GGP price and AVAX high water mark. A staker can earn GGP rewards
	///         on up to 150% collat ratio
	/// returns collateral ratio of GGP -> avax high water
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	/// @return Ratio is between 0%-150% (0-1.5 ether)
	function getEffectiveRewardsRatio(address stakerAddr) public view returns (uint256) {
		uint256 avaxValidatingHighWater = getAVAXValidatingHighWater(stakerAddr);
		if (avaxValidatingHighWater == 0) {
			return 0;
		}

		if (getCollateralizationRatio(stakerAddr) < TENTH) {
			return 0;
		}

		Oracle oracle = Oracle(getContractAddress("Oracle"));
		(uint256 ggpPriceInAvax, ) = oracle.getGGPPriceInAVAX();
		uint256 ggpStakedInAvax = getGGPStake(stakerAddr).mulWadDown(ggpPriceInAvax);
		uint256 ratio = ggpStakedInAvax.divWadDown(avaxValidatingHighWater);

		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		uint256 maxRatio = dao.getMaxCollateralizationRatio();

		return (ratio > maxRatio) ? maxRatio : ratio;
	}

	/// @notice GGP that will count towards rewards this cycle
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function getEffectiveGGPStaked(address stakerAddr) external view returns (uint256) {
		Oracle oracle = Oracle(getContractAddress("Oracle"));
		(uint256 ggpPriceInAvax, ) = oracle.getGGPPriceInAVAX();
		uint256 avaxValidatingHighWater = getAVAXValidatingHighWater(stakerAddr);

		// ratio of ggp to avax high water
		uint256 ratio = getEffectiveRewardsRatio(stakerAddr);
		return avaxValidatingHighWater.mulWadDown(ratio).divWadDown(ggpPriceInAvax);
	}

	/// @notice Accept a GGP stake
	/// @param amount The amount of GGP being staked
	function stakeGGP(uint256 amount) external whenNotPaused {
		// Transfer GGP tokens from staker to this contract
		ggp.safeTransferFrom(msg.sender, address(this), amount);
		_stakeGGP(msg.sender, amount);
	}

	/// @notice Convenience function to allow for restaking claimed GGP rewards
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	/// @param amount The amount of GGP being staked
	function restakeGGP(address stakerAddr, uint256 amount) public onlySpecificRegisteredContract("ClaimNodeOp", msg.sender) {
		// Transfer GGP tokens from the ClaimNodeOp contract to this contract
		ggp.safeTransferFrom(msg.sender, address(this), amount);
		_stakeGGP(stakerAddr, amount);
	}

	/// @notice Stakes GGP in the protocol
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	/// @param amount The amount of GGP being staked
	function _stakeGGP(address stakerAddr, uint256 amount) internal {
		emit GGPStaked(stakerAddr, amount);

		// Deposit GGP tokens from this contract to vault
		Vault vault = Vault(getContractAddress("Vault"));
		ggp.approve(address(vault), amount);
		vault.depositToken("Staking", ggp, amount);

		int256 stakerIndex = getIndexOf(stakerAddr);
		if (stakerIndex == -1) {
			// create index for the new staker
			stakerIndex = int256(getUint(keccak256("staker.count")));
			addUint(keccak256("staker.count"), 1);
			setUint(keccak256(abi.encodePacked("staker.index", stakerAddr)), uint256(stakerIndex + 1));
			setAddress(keccak256(abi.encodePacked("staker.item", stakerIndex, ".stakerAddr")), stakerAddr);
		}
		increaseGGPStake(stakerAddr, amount);
	}

	/// @notice Allows the staker to unstake their GGP if they are over the 150% collateralization ratio
	/// @param amount The amount of GGP being withdrawn
	function withdrawGGP(uint256 amount) external whenNotPaused {
		if (amount > getGGPStake(msg.sender)) {
			revert InsufficientBalance();
		}

		emit GGPWithdrawn(msg.sender, amount);

		decreaseGGPStake(msg.sender, amount);

		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		if (getCollateralizationRatio(msg.sender) < dao.getMaxCollateralizationRatio()) {
			revert CannotWithdrawUnder150CollateralizationRatio();
		}

		Vault vault = Vault(getContractAddress("Vault"));
		vault.withdrawToken(msg.sender, ggp, amount);
	}

	/// @notice Minipool Manager will call this if a minipool ended and was not in good standing
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	/// @param ggpAmt The amount of GGP being slashed
	function slashGGP(address stakerAddr, uint256 ggpAmt) public onlySpecificRegisteredContract("MinipoolManager", msg.sender) {
		Vault vault = Vault(getContractAddress("Vault"));
		decreaseGGPStake(stakerAddr, ggpAmt);
		vault.transferToken("ProtocolDAO", ggp, ggpAmt);
	}

	/// @notice Verifying the staker exists in the protocol
	/// @param stakerAddr The C-chain address of a GGP staker in the protocol
	function requireValidStaker(address stakerAddr) public view returns (int256) {
		int256 index = getIndexOf(stakerAddr);
		if (index != -1) {
			return index;
		} else {
			revert StakerNotFound();
		}
	}

	/// @notice Get index of the staker
	/// @return staker index or -1 if the value was not found
	function getIndexOf(address stakerAddr) public view returns (int256) {
		return int256(getUint(keccak256(abi.encodePacked("staker.index", stakerAddr)))) - 1;
	}

	/// @notice Gets the staker information using the staker's index
	/// @param stakerIndex Index of the staker
	/// @return staker struct containing the staker's properties
	function getStaker(int256 stakerIndex) public view returns (Staker memory staker) {
		staker.ggpStaked = getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".ggpStaked")));
		staker.avaxAssigned = getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxAssigned")));
		staker.avaxStaked = getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxStaked")));
		staker.avaxValidating = getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxValidating")));
		staker.stakerAddr = getAddress(keccak256(abi.encodePacked("staker.item", stakerIndex, ".stakerAddr")));
		staker.minipoolCount = getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".minipoolCount")));
		staker.rewardsStartTime = getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".rewardsStartTime")));
		staker.ggpRewards = getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".ggpRewards")));
		staker.lastRewardsCycleCompleted = getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".lastRewardsCycleCompleted")));
	}

	/// @notice Get stakers in the protocol (limit=0 means no pagination)
	/// @param offset The number the result should be offset by
	/// @param limit The limit to the amount of minipools that should be returned
	/// @return stakers in the protocol that adhear to the paramaters
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
