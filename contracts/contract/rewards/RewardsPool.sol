pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "../Base.sol";
import {Storage} from "../Storage.sol";
import {Vault} from "../Vault.sol";
import {TokenGGP} from "../tokens/TokenGGP.sol";
import {NOPClaim} from "./claims/NOPClaim.sol";
import {ProtocolDAO} from "../dao/ProtocolDAO.sol";

import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";

// GGP Rewards claiming by the DAO
contract RewardsPool is Base {
	using FixedPointMathLib for uint256;

	/// @notice Distribution cannot exceed total rewards
	error IncorrectRewardsDistribution();
	error UnableToStartRewardsCycle();

	event GGPInflated(address sender, uint256 value, uint256 inflationCalcTime);
	event ProtocolDAORewardsTransfered(uint256 value);
	event NOPClaimRewardsTransfered(uint256 value);
	event NewRewardsCycleStarted(uint256 totalRewardsAmt);

	constructor(Storage storageAddress) Base(storageAddress) {
		version = 1;
	}

	function initialize() external onlyGuardian {
		if (getBool(keccak256("RewardsPool.initialized"))) {
			return;
		}
		setBool(keccak256("RewardsPool.initialized"), true);

		setUint(keccak256("RewardsPool.RewardsCycleStartTime"), block.timestamp);
		setUint(keccak256("RewardsPool.InflationCycleStartTime"), block.timestamp);
	}

	/* INFLATION */

	/**
	 * Get the last time that inflation was calculated at
	 * @return uint256 timestamp when inflation was last calculated
	 */
	function getInflationCycleStartTime() public view returns (uint256) {
		return getUint(keccak256("RewardsPool.InflationCycleStartTime"));
	}

	/**
	 * @return uint256 Number of intervals since last inflation cycle
	 */
	function getInflationIntervalsElapsed() public view returns (uint256) {
		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		return (block.timestamp - getInflationCycleStartTime()) / dao.getInflationInterval();
	}

	/**
	 * @dev Function to compute how many tokens should be minted
	 * @return A uint256 specifying number of new tokens to mint
	 */
	function getInflationAmt() public view returns (uint256, uint256) {
		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		uint256 inflationRate = dao.getInflationIntervalRate();
		uint256 inflationIntervalsElapsed = getInflationIntervalsElapsed();
		uint256 currentTotalSupply = dao.getTotalGGPCirculatingSupply();
		uint256 newTotalSupply = currentTotalSupply;

		// Compute inflation for total inflation intervals elapsed
		for (uint256 i = 0; i < inflationIntervalsElapsed; i++) {
			newTotalSupply = newTotalSupply.mulWadDown(inflationRate);
		}
		return (currentTotalSupply, newTotalSupply);
	}

	/**
	 * @dev Mint new tokens if enough time has elapsed since last mint
	 */
	function inflate() internal {
		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		(uint256 currentTotalSupply, uint256 newTotalSupply) = getInflationAmt();
		uint256 newTokens = newTotalSupply - currentTotalSupply;
		uint256 inflationCycleElapsedSeconds = (dao.getRewardsCycleSeconds() * getInflationIntervalsElapsed());

		dao.setTotalGGPCirculatingSupply(newTotalSupply);
		addUint(keccak256("RewardsPool.RewardsCycleStartTime"), inflationCycleElapsedSeconds);
		setUint(keccak256("RewardsPool.RewardsCycleTotalAmount"), newTokens);
	}

	/* REWARDS */

	/**
	 * Get the current rewards cycle start time
	 * @return uint256 Last set start timestamp for a rewards cycle
	 */
	function getRewardsCycleStartTime() public view returns (uint256) {
		return getUint(keccak256("RewardsPool.RewardsCycleStartTime"));
	}

	/**
	 * Get the amount of rewards available for this cycle
	 * @return uint256 Rewards amount for current cycle
	 */
	function getRewardsCycleTotalAmount() public view returns (uint256) {
		return getUint(keccak256("RewardsPool.RewardsCycleTotalAmount"));
	}

	/**
	 * @return uint256 Number of intervals since last distribution of rewards
	 */
	function getRewardsCyclesElapsed() public view returns (uint256) {
		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		return (block.timestamp - getRewardsCycleStartTime()) / dao.getRewardsCycleSeconds();
	}

	/**
	 * Get the approx amount of rewards owed for this cycle per claiming contract
	 * @return uint256 Rewards amount for current cycle per claiming contract
	 */
	function getClaimingContractDistribution(string memory _claimingContract) public view returns (uint256) {
		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		uint256 claimContractPerc = dao.getClaimingContractPct(_claimingContract);
		// How much rewards are available for this claim interval?
		uint256 currentCycleRewardsTotal = getRewardsCycleTotalAmount();

		// How much this claiming contract is entitled to in perc
		uint256 contractRewardsTotal = 0;
		if (claimContractPerc > 0 && currentCycleRewardsTotal > 0) {
			// Calculate how much rewards this claimer will receive based on their claiming perc
			contractRewardsTotal = claimContractPerc.mulWadDown(currentCycleRewardsTotal);
		}
		return contractRewardsTotal;
	}

	//Rialto calls this to see if at least one cycle has passed
	function canRewardsCycleStart() public view returns (bool) {
		return getRewardsCyclesElapsed() > 0 && getInflationIntervalsElapsed() > 0;
	}

	/* CYCLES */

	//Ralto calls this
	function startRewardsCycle() external {
		NOPClaim nopClaim = NOPClaim(getContractAddress("NOPClaim"));
		TokenGGP ggp = TokenGGP(getContractAddress("TokenGGP"));
		Vault vault = Vault(getContractAddress("Vault"));
		if (!canRewardsCycleStart()) {
			// Only Rialto will be calling, so if we fail make it noisy (by reverting) so we can investigate
			revert UnableToStartRewardsCycle();
		}

		// Set this as the start of the new rewards cycle
		setUint(keccak256("RewardsPool.RewardsCycleStartTime"), block.timestamp);

		// Mint any new tokens from GGP inflation
		// note: this will always 'mint' (release) new tokens if the rewards cycle length requirement is met
		// since inflation is on a 1 day interval and it needs atleast one cycle since last calculation
		inflate();

		// Soon as we mint new tokens, send the DAO's share to it's claiming contract, then attempt to transfer them to the dao if possible
		uint256 daoClaimContractAllotment = getClaimingContractDistribution("ProtocolDAOClaim");
		uint256 nopClaimContractAllotment = getClaimingContractDistribution("NOPClaim");

		if (daoClaimContractAllotment + nopClaimContractAllotment > getRewardsCycleTotalAmount()) {
			revert IncorrectRewardsDistribution();
		}

		if (daoClaimContractAllotment > 0) {
			// Transfers the DAO's tokens to it's claiming contract from the rewards pool
			vault.transferToken("ProtocolDAOClaim", ggp, daoClaimContractAllotment);

			emit ProtocolDAORewardsTransfered(daoClaimContractAllotment);
		}

		//TODO: add Rialto's Claim here

		if (nopClaimContractAllotment > 0) {
			// Transfers the DAO's tokens to it's claiming contract from the rewards pool
			vault.transferToken("NOPClaim", ggp, nopClaimContractAllotment);
			//set the total for this cycle in the contracts storage
			nopClaim.setRewardsCycleTotal(nopClaimContractAllotment);

			emit NOPClaimRewardsTransfered(nopClaimContractAllotment);
		}
		emit NewRewardsCycleStarted(getRewardsCycleTotalAmount());
	}
}
