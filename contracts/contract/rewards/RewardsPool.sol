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
		//TODO: change to 28 days after alpha
		setUint("rewards.pool.reward.cycle.length", 3 minutes); // The time in which a claim period will span in seconds - 28 days by default
		setUint("ggp.total.circulating.supply", 18000000 ether);
		// setUint("ggp.total.inflation.calculated.time", 0 seconds);
		setUint(keccak256(abi.encodePacked("rewards.percentage", "ProtocolDAOClaim")), 0.10 ether);
		setUint(keccak256(abi.encodePacked("rewards.percentage", "NOPClaim")), 0.70 ether);
		setUint(keccak256(abi.encodePacked("rewards.percentage", "RialtoClaim")), 0.20 ether);
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

	/* INFLATION */

	/**
	 * The amount of ggp that has been released so far
	 * @return uint256 The supply of ggp that is in circulation
	 */
	function getTotalGGPCirculatingSupply() public view returns (uint256) {
		return getUint("ggp.total.circulating.supply");
	}

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
				uint256 totalSupplyCurrent = getTotalGGPCirculatingSupply();
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
		uint256 totalCirculatingSupply = getTotalGGPCirculatingSupply();
		totalCirculatingSupply = totalCirculatingSupply + newTokens;
		// Update last inflation calculation timestamp even if inflation rate is 0
		//why isnt this set to the current time?
		inflationCalcTime = inflationLastCalcTime + (inflationInterval * intervalsSinceLastMint); // Check if actually need to mint tokens (e.g. inflation rate > 0)
		setUint(keccak256("rewards.pool.reward.cycle.total.amount"), newTokens);
	}

	/* REWARDS */

	/**
	 * Get the current reward cycle start time
	 * @return uint256 Last set start timestamp for a reward cycle
	 */
	function getRewardCycleStartTime() public view returns (uint256) {
		return getUint(keccak256("rewards.pool.reward.cycle.start.time"));
	}

	/**
	 * Get how many seconds in a reward cycle
	 * @return uint256 Number of seconds in a reward interval
	 */
	// TODO implement dao settings
	function getRewardCycleLength() public view returns (uint256) {
		// Get from the DAO settings
		return getUint("rewards.pool.reward.cycle.length");
	}

	/**
	 * Get the approx amount of rewards available for this cycle
	 * @return uint256 Rewards amount for current cycle
	 */
	function getRewardCycleTotalAmount() public view returns (uint256) {
		return getUint(keccak256("rewards.pool.reward.cycle.total.amount"));
	}

	/**
	 * Compute intervals since last rewards cycle
	 * @return uint256 Time intervals since last distribution of rewards
	 */
	function getRewardCyclesPassed() public view returns (uint256) {
		return _getRewardCyclesPassed(getRewardCycleStartTime(), getRewardCycleLength());
	}

	function _getRewardCyclesPassed(uint256 _rewardCycleStartTime, uint256 _rewardCycleLength) private view returns (uint256) {
		return (block.timestamp - _rewardCycleStartTime).divWadDown(_rewardCycleLength);
	}

	/**
	 * Get the percentage a contract is owed this reward cycle
	 * @return uint256 Rewards percentage a contract will recieve this cycle
	 */
	// TODO implement
	function getClaimingContractPerc(string memory _claimingContract) public view returns (uint256) {
		return getUint(keccak256(abi.encodePacked("rewards.percentage", _claimingContract)));
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

		// Has it been atleast 28 days since the last distribution? If so, set the rewards total for this interval
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

		// Has it been atleast 28 days since the last distribution?
		if (rewardCyclesPassed >= 1 ether) {
			// Mint any new tokens from GGP inflation
			// note: this will always 'mint' (release) new tokens if the reward cycle length requirement is met
			// since inflation is on a 1 day interval and it needs atleast one cycle since last calculation
			inflationMintTokens();

			// Set this as the start of the new rewards cycle
			//TODO: need to add something to ANR to continuously send transactions so that 'time' actually passes for the cycles calculations.
			setUint(keccak256("rewards.pool.reward.cycle.start.time"), block.timestamp);

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
