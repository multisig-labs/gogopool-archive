pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "../Base.sol";
import {Storage} from "../Storage.sol";
import {Vault} from "../Vault.sol";
import {TokenGGP} from "../tokens/TokenGGP.sol";
import {NOPClaim} from "./claims/NOPClaim.sol";
import "../dao/ProtocolDAO.sol";
import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";

// GGP Rewards claiming by the DAO
contract RewardsPool is Base {
	using FixedPointMathLib for uint256;

	constructor(Storage storageAddress) Base(storageAddress) {
		version = 1;
		// setUint("ggp.total.inflation.calculated.time", 0 seconds);
	}

	/**** Properties ***********/
	// Timestamp of last block inflation was calculated at
	//TODO: set this in storage and constructor. Tried but it throws error
	uint256 private inflationCalcTime = 0;

	/**** Events ***********/

	event GGPInflationLog(address sender, uint256 value, uint256 inflationCalcTime);
	event ProtocolDAORewardsTransfered(uint256 value);
	event NOPClaimRewardsTransfered(uint256 value);
	event NewRewardsCycleStarted(uint256 totalRewardAmt);
	/// @notice Distribution cannot exceed total rewards
	error IncorrectRewardDistribution();

	// Get whether the contract is enabled
	//TODO: integrate this to be used
	function getEnabled() external view returns (bool) {
		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		return dao.getContractEnabled("RewardsPool");
	}

	/* INFLATION */

	/**
	 * Get the last time that inflation was calculated at
	 * @return uint256 Last timestamp since inflation was calculated
	 */
	function getLastInflationCalcTime() public view returns (uint256) {
		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		// Get the last time inflation was calculated if it has even started
		uint256 inflationStartTime = dao.getInflationIntervalStartTime();
		return inflationCalcTime == 0 && inflationStartTime < block.timestamp ? inflationStartTime : inflationCalcTime;
	}

	/**
	 * Compute interval since last inflation update
	 * @return uint256 Time intervals since last update
	 */
	function getInflationIntervalsPassed() public view returns (uint256) {
		// The time that inflation was last calculated at
		uint256 inflationLastCalculatedTime = getLastInflationCalcTime();
		return _getInflationIntervalsPassed(inflationLastCalculatedTime);
	}

	function _getInflationIntervalsPassed(uint256 _inflationLastCalcTime) private view returns (uint256) {
		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		uint256 inflationInterval = dao.getInflationInterval();
		// Calculate now if inflation has begun
		if (_inflationLastCalcTime > 0) {
			return (block.timestamp - _inflationLastCalcTime) / inflationInterval;
		} else {
			return 0;
		}
	}

	/**
	 * @dev Function to compute how many tokens should be minted
	 * @return A uint256 specifying number of new tokens to mint
	 */
	function inflationCalculate() public view returns (uint256) {
		uint256 intervalsSinceLastMint = getInflationIntervalsPassed();
		return _inflationCalculate(intervalsSinceLastMint);
	}

	function _inflationCalculate(uint256 _intervalsSinceLastMint) private view returns (uint256) {
		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));

		// The inflation amount
		uint256 inflationTokenAmount = 0;

		// Only update  if last interval has passed and inflation rate is > 0
		if (_intervalsSinceLastMint > 0) {
			// Optimisation
			uint256 inflationRate = dao.getInflationIntervalRate();
			if (inflationRate > 0) {
				// Get the total supply now
				uint256 totalSupplyCurrent = dao.getTotalGGPCirculatingSupply();
				uint256 newTotalSupply = totalSupplyCurrent;

				// Compute inflation for total inflation intervals elapsed
				for (uint256 i = 0; i < _intervalsSinceLastMint; i++) {
					newTotalSupply = newTotalSupply.mulWadDown(inflationRate);
				}

				// Return inflation amount
				inflationTokenAmount = newTotalSupply - (totalSupplyCurrent);
			}
		}
		// Done
		return inflationTokenAmount;
	}

	/**
	 * @dev Mint new tokens if enough time has elapsed since last mint
	 */
	function inflationMintTokens() internal {
		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		uint256 inflationInterval = dao.getInflationInterval();
		// Only run inflation process if at least 1 interval has passed (function returns 0 otherwise)
		uint256 inflationLastCalcTime = getLastInflationCalcTime();
		uint256 intervalsSinceLastMint = _getInflationIntervalsPassed(inflationLastCalcTime);

		uint256 newTokens = _inflationCalculate(intervalsSinceLastMint);
		uint256 totalCirculatingSupply = dao.getTotalGGPCirculatingSupply();

		//set new circulating supply
		dao.setTotalGGPCirculatingSupply((totalCirculatingSupply + newTokens));
		// Update last inflation calculation timestamp even if inflation rate is 0
		//why isnt this set to the current time?
		inflationCalcTime = inflationLastCalcTime + (inflationInterval * intervalsSinceLastMint); // Check if actually need to mint tokens (e.g. inflation rate > 0)
		setUint(keccak256("rewardsPool.reward.cycle.total.amount"), newTokens);
	}

	/* REWARDS */

	/**
	 * Get the current reward cycle start time
	 * @return uint256 Last set start timestamp for a reward cycle
	 */
	function getRewardCycleStartTime() public view returns (uint256) {
		return getUint(keccak256("rewardsPool.reward.cycle.start.time"));
	}

	/**
	 * Get the approx amount of rewards available for this cycle
	 * @return uint256 Rewards amount for current cycle
	 */
	function getRewardCycleTotalAmount() public view returns (uint256) {
		return getUint(keccak256("rewardsPool.reward.cycle.total.amount"));
	}

	/**
	 * Compute intervals since last rewards cycle
	 * @return uint256 Time intervals since last distribution of rewards
	 */
	function getRewardCyclesPassed() public view returns (uint256) {
		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		return _getRewardCyclesPassed(getRewardCycleStartTime(), dao.getGGPRewardCycleLength());
	}

	function _getRewardCyclesPassed(uint256 _rewardCycleStartTime, uint256 _rewardCycleLength) private view returns (uint256) {
		// With two non-wad numbers, divWadDown results in a wad number.
		return (block.timestamp - _rewardCycleStartTime).divWadDown(_rewardCycleLength);
	}

	/**
	 * Get the percentage a contract is owed this reward cycle
	 * @return uint256 Rewards percentage a contract will recieve this cycle
	 */
	function getClaimingContractPerc(string memory _claimingContract) public view returns (uint256) {
		ProtocolDAO dao = ProtocolDAO(getContractAddress("ProtocolDAO"));
		if (dao.getContractEnabled(_claimingContract)) {
			return dao.getClaimingContractPerc(_claimingContract);
		}
		return 0 ether;
	}

	/**
	 * Get the approx amount of rewards owed for this cycle per claiming contract
	 * @return uint256 Rewards amount for current cycle per claiming contract
	 */
	function getClaimingContractDistribution(string memory _claimingContract) public view returns (uint256) {
		// Get the % amount the contract will get
		uint256 claimContractPerc = getClaimingContractPerc(_claimingContract);
		// How much rewards are available for this claim interval?
		uint256 currentCycleRewardTotal = getRewardCycleTotalAmount();

		// How much this claiming contract is entitled to in perc
		uint256 contractRewardTotal = 0;
		// Check now
		if (claimContractPerc > 0 && currentCycleRewardTotal > 0) {
			// Calculate how much rewards this claimer will receive based on their claiming perc
			contractRewardTotal = claimContractPerc.mulWadDown(currentCycleRewardTotal);
		}
		// Done
		return contractRewardTotal;
	}

	//Rialto calls this to see if the new cycle can start
	function canCycleStart() external view returns (bool) {
		uint256 cyclesPassed = getRewardCyclesPassed();
		// Has atleast one cycle passed?
		if (cyclesPassed >= 1 ether) {
			return true;
		}
		return false;
	}

	/* CYCLES */

	//Ralto calls this
	function startCycle() external {
		NOPClaim nopClaim = NOPClaim(getContractAddress("NOPClaim"));
		TokenGGP ggp = TokenGGP(getContractAddress("TokenGGP"));
		Vault vault = Vault(getContractAddress("Vault"));

		uint256 rewardCyclesPassed = getRewardCyclesPassed();

		// Has atleast one cycle passed?
		if (rewardCyclesPassed >= 1 ether) {
			// Mint any new tokens from GGP inflation
			// note: this will always 'mint' (release) new tokens if the reward cycle length requirement is met
			// since inflation is on a 1 day interval and it needs atleast one cycle since last calculation
			inflationMintTokens();

			// Set this as the start of the new rewards cycle
			setUint(keccak256("rewardsPool.reward.cycle.start.time"), block.timestamp);
			// Soon as we mint new tokens, send the DAO's share to it's claiming contract, then attempt to transfer them to the dao if possible
			uint256 daoClaimContractAllotment = getClaimingContractDistribution("ProtocolDAOClaim");
			uint256 nopClaimContractAllotment = getClaimingContractDistribution("NOPClaim");

			if (daoClaimContractAllotment + nopClaimContractAllotment > getRewardCycleTotalAmount()) {
				revert IncorrectRewardDistribution();
			}
			if (daoClaimContractAllotment > 0) // Are we sending any?
			{
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
			emit NewRewardsCycleStarted(getRewardCycleTotalAmount());
		}
	}
}
