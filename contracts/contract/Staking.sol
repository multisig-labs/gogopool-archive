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
	staker.item<index>.avaxAssignedHighWater = Highest amt of liquid staker funds assigned during a GGP rewards cycle
*/

contract Staking is Base {
	using SafeTransferLib for ERC20;
	using SafeTransferLib for address;
	using FixedPointMathLib for uint256;

	error CannotWithdrawUnder150CollateralizationRatio();
	error InsufficientBalance();
	error StakerNotFound();

	event GGPStaked(address indexed from, uint256 amount);
	event GGPWithdrawn(address indexed to, uint256 amount);

	/// @dev Not used for storage, just for returning data from view functions
	struct Staker {
		address stakerAddr;
		uint256 ggpStaked;
		uint256 avaxStaked;
		uint256 avaxAssigned;
		uint256 avaxAssignedHighWater;
		uint256 minipoolCount;
		uint256 rewardsStartTime;
		uint256 ggpRewards;
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

	function getStakerCount() public view returns (uint256) {
		return getUint(keccak256("staker.count"));
	}

	/* GGP STAKE */

	function getGGPStake(address stakerAddr) public view returns (uint256) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		return getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".ggpStaked")));
	}

	function increaseGGPStake(address stakerAddr, uint256 amount) internal {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		addUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".ggpStaked")), amount);
	}

	function decreaseGGPStake(address stakerAddr, uint256 amount) internal {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		subUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".ggpStaked")), amount);
	}

	/* AVAX STAKE */

	function getAVAXStake(address stakerAddr) public view returns (uint256) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		return getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxStaked")));
	}

	function increaseAVAXStake(address stakerAddr, uint256 amount) public onlyLatestContract("MinipoolManager", msg.sender) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		addUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxStaked")), amount);
	}

	function decreaseAVAXStake(address stakerAddr, uint256 amount) public onlyLatestContract("MinipoolManager", msg.sender) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		subUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxStaked")), amount);
	}

	/* AVAX ASSIGNED */

	function getAVAXAssigned(address stakerAddr) public view returns (uint256) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		return getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxAssigned")));
	}

	/// @dev Also increases .avaxAssignedHighWater amount
	function increaseAVAXAssigned(address stakerAddr, uint256 amount) public onlyLatestContract("MinipoolManager", msg.sender) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		addUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxAssigned")), amount);

		uint256 currHighWater = getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxAssignedHighWater")));
		uint256 currAssigned = getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxAssigned")));
		if (currAssigned > currHighWater) {
			setUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxAssignedHighWater")), currAssigned);
		}
	}

	/// @dev Purposely does *not* decrease .avaxAssignedHighWater amount. That is done during GGP rewards payout
	function decreaseAVAXAssigned(address stakerAddr, uint256 amount) public onlyLatestContract("MinipoolManager", msg.sender) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		subUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxAssigned")), amount);
	}

	/* AVAX ASSIGNED HIGH-WATER */

	/// @notice Largest total AVAX amt assigned to a staker during a rewards period
	function getAVAXAssignedHighWater(address stakerAddr) public view returns (uint256) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		return getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxAssignedHighWater")));
	}

	/// @notice Reset the AVAXAssignedHighWater to what the current AVAXAssigned is for the staker
	function resetAVAXAssignedHighWater(address stakerAddr) public onlyLatestNetworkContract {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		uint256 currAVAXAssigned = getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxAssigned")));
		setUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxAssignedHighWater")), currAVAXAssigned);
	}

	/* MINIPOOL COUNT */

	function getMinipoolCount(address stakerAddr) public view returns (uint256) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		return getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".minipoolCount")));
	}

	/// @dev Also sets .rewardsStartTime if minipoolsCount goes from 0 -> 1
	function increaseMinipoolCount(address stakerAddr) public onlyLatestContract("MinipoolManager", msg.sender) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		addUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".minipoolCount")), 1);
	}

	function decreaseMinipoolCount(address stakerAddr) public onlyLatestContract("MinipoolManager", msg.sender) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		subUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".minipoolCount")), 1);
	}

	/* REWARDS START TIME */

	function getRewardsStartTime(address stakerAddr) public view returns (uint256) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		return getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".rewardsStartTime")));
	}

	// TODO cant use onlyLatestContract("ClaimNodeOp", msg.sender) since we also call from increaseMinipoolCount. Wat do?
	function setRewardsStartTime(address stakerAddr, uint256 time) public onlyLatestNetworkContract {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		setUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".rewardsStartTime")), time);
	}

	/* GGP REWARDS */

	function getGGPRewards(address stakerAddr) public view returns (uint256) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		return getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".ggpRewards")));
	}

	function increaseGGPRewards(address stakerAddr, uint256 amount) public onlyLatestContract("ClaimNodeOp", msg.sender) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		addUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".ggpRewards")), amount);
	}

	function decreaseGGPRewards(address stakerAddr, uint256 amount) public onlyLatestContract("ClaimNodeOp", msg.sender) {
		int256 stakerIndex = requireValidStaker(stakerAddr);
		subUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".ggpRewards")), amount);
	}

	/// @notice Get a stakers's minimum ggp stake to collateralize their minipools, based on current GGP price
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
	/// @return A ratio where 0 = 0%, 1 ether = 100%
	function getCollateralizationRatio(address stakerAddr) public view returns (uint256) {
		uint256 avaxAssigned = getAVAXAssigned(stakerAddr);
		if (avaxAssigned == 0) {
			// Infinite collat ratio
			return type(uint256).max;
		}
		Oracle oracle = Oracle(getContractAddress("Oracle"));
		(uint256 ggpPriceInAvax, ) = oracle.getGGPPriceInAVAX();
		uint256 ggpStaked = getGGPStake(stakerAddr);
		uint256 ggpStakedInAvax = ggpStaked.mulWadDown(ggpPriceInAvax);
		return ggpStakedInAvax.divWadDown(avaxAssigned);
	}

	/// @notice Returns effective collateralization ratio which will be used to pay out rewards
	///         based on current GGP price and AVAX high water mark. A staker can earn GGP rewards
	///         on up to 150% collat ratio
	/// @return Ratio is between 0%-150% (0-1.5 ether)
	function getEffectiveRewardsRatio(address stakerAddr) public view returns (uint256) {
		uint256 avaxAssignedHighWater = getAVAXAssignedHighWater(stakerAddr);
		if (avaxAssignedHighWater == 0) {
			return 0;
		}
		if (getCollateralizationRatio(stakerAddr) < TENTH) {
			return 0;
		}
		Oracle oracle = Oracle(getContractAddress("Oracle"));
		(uint256 ggpPriceInAvax, ) = oracle.getGGPPriceInAVAX();
		uint256 ggpStaked = getGGPStake(stakerAddr);
		uint256 ggpStakedInAvax = ggpStaked.mulWadDown(ggpPriceInAvax);
		uint256 ratio = ggpStakedInAvax.divWadDown(avaxAssignedHighWater);
		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		uint256 maxRatio = dao.getMaxCollateralizationRatio();
		ratio = (ratio > maxRatio) ? maxRatio : ratio;
		return ratio;
	}

	/// @notice GGP that will count towards rewards this cycle
	function getEffectiveGGPStaked(address stakerAddr) external view returns (uint256) {
		Oracle oracle = Oracle(getContractAddress("Oracle"));
		(uint256 ggpPriceInAvax, ) = oracle.getGGPPriceInAVAX();
		uint256 avaxAssignedHighWater = getAVAXAssignedHighWater(stakerAddr);
		uint256 ratio = getEffectiveRewardsRatio(stakerAddr);
		return avaxAssignedHighWater.mulWadDown(ratio).divWadDown(ggpPriceInAvax);
	}

	/// @notice Accept a GGP stake
	function stakeGGP(uint256 amount) external whenNotPaused {
		// Transfer GGP tokens from staker to this contract
		ggp.transferFrom(msg.sender, address(this), amount);
		_stakeGGP(msg.sender, amount);
	}

	/// @notice Convenience function to allow for restaking claimed GGP rewards
	function restakeGGP(address stakerAddress, uint256 amount) public onlyLatestContract("ClaimNodeOp", msg.sender) {
		// Transfer GGP tokens from the ClaimNodeOp contract to this contract
		ggp.transferFrom(msg.sender, address(this), amount);
		_stakeGGP(stakerAddress, amount);
	}

	function _stakeGGP(address stakerAddress, uint256 amount) internal {
		emit GGPStaked(stakerAddress, amount);

		// Deposit GGP tokens from this contract to vault
		Vault vault = Vault(getContractAddress("Vault"));
		ggp.approve(address(vault), amount);
		vault.depositToken("Staking", ggp, amount);

		int256 stakerIndex = getIndexOf(stakerAddress);
		if (stakerIndex == -1) {
			// create index for the new staker
			stakerIndex = int256(getUint(keccak256("staker.count")));
			addUint(keccak256("staker.count"), 1);
			setUint(keccak256(abi.encodePacked("staker.index", stakerAddress)), uint256(stakerIndex + 1));
			setAddress(keccak256(abi.encodePacked("staker.item", stakerIndex, ".stakerAddr")), stakerAddress);
		}
		increaseGGPStake(stakerAddress, amount);
	}

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

	//Minipool Manager will call this if a minipool ended and was not in good standing
	function slashGGP(address stakerAddr, uint256 ggpAmt) public onlyLatestContract("MinipoolManager", msg.sender) {
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

	function getStaker(int256 stakerIndex) public view returns (Staker memory staker) {
		staker.ggpStaked = getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".ggpStaked")));
		staker.avaxAssigned = getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxAssigned")));
		staker.avaxStaked = getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".avaxStaked")));
		staker.stakerAddr = getAddress(keccak256(abi.encodePacked("staker.item", stakerIndex, ".stakerAddr")));
		staker.minipoolCount = getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".minipoolCount")));
		staker.rewardsStartTime = getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".rewardsStartTime")));
		staker.ggpRewards = getUint(keccak256(abi.encodePacked("staker.item", stakerIndex, ".ggpRewards")));
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
