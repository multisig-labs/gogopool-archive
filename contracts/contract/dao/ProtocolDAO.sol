// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.13;

import {TokenGGP} from "../tokens/TokenGGP.sol";
import {Base} from "../Base.sol";
import {Storage} from "../Storage.sol";

contract ProtocolDAO is Base {
	constructor(Storage storageAddress) Base(storageAddress) {
		version = 1;
	}

	// modifier that checks if the caller is a dao member
	modifier isDaoMember() {
		// create an instance of the token contract
		TokenGGP token = TokenGGP(getContractAddress("tokenGGP"));
		// check that the sender's balance is greater than 0
		require(token.balanceOf(msg.sender) > 0, "You do not own any GGP tokens");
		_;
	}

	function initialize() external onlyGuardian {
		if (!getBool(keccak256("protocolDAO.deployed"))) {
			//NOPClaim settings
			setBool(keccak256("NOPClaim.enabled"), true);
			setUint(keccak256("ggp.rewards.eligibilityMinLength"), 0 days);

			//ProtocolDAOClaim settings
			setBool(keccak256("ProtocolDAOClaim.enabled"), true);

			//RewardsPool Settings
			setBool(keccak256("RewardsPool.enabled"), true);
			setUint(keccak256("ggp.rewards.cycleLength"), 3 minutes); // The time in which a claim period will span in seconds - 28 days by default
			setUint(keccak256("ggp.circulatingSupply"), 18000000 ether);
			setUint(keccak256("ggp.rewards.percentageProtocolDAOClaim"), 0.10 ether);
			setUint(keccak256("ggp.rewards.percentageNOPClaim"), 0.70 ether);
			setUint(keccak256("ggp.rewards.percentageRialtoClaim"), 0.20 ether);

			// GGP Inflation settings
			// these may change when we finialize tokenomics
			setUint(keccak256("ggp.inflation.intervalRate"), 1000133680617113500); // 5% annual calculated on a daily interval - Calculate in js example: let dailyInflation = web3.utils.toBN((1 + 0.05) ** (1 / (365)) * 1e18);
			setUint(keccak256("ggp.inflation.intervalStart"), (block.timestamp + 1 days)); // Set the default start date for inflation to begin as 1 day after deployment
			setUint(keccak256("ggp.inflation.interval"), 1 minutes);

			//TokenGGAvax settings
			setUint(keccak256("ggAvax.rewards.cycleLength"), 10 days);
			setUint(keccak256("ggAvax.reserveTarget"), 0.1 ether); // 10% collateral held in reserver

			//TokenGGP settings

			//Minipool settings
			setUint(keccak256("minipool.minStakingAmount"), 2000 ether);
			setUint(keccak256("minipool.nodeCommision"), 0.15 ether);
			setUint(keccak256("minipool.maxAvaxAssignment"), 10_000 ether);
			setUint(keccak256("minipool.minAvaxAssignment"), 1_000 ether);
			setUint(keccak256("avalanche.expectedRewardRate"), 0.1 ether); // Annual rate as pct of 1 avax

			// Staking settings
			setUint(keccak256("ggp.maxCollateralizationRatio"), 1.5 ether);
			setUint(keccak256("ggp.minCollateralizationRatio"), 0.1 ether);

			//Delegation Settings
			//Delegation duration limit set to 2 Months
			setUint(keccak256("delegation.maxDuration"), 5097600);

			// Deployment check
			setBool(keccak256("protocolDAO.deployed"), true); // Flag that this contract has been deployed, so default settings don't get reapplied on a contract upgrade
		}
	}

	function getContractEnabled(string memory contractName) public view returns (bool) {
		return getBool(keccak256(abi.encodePacked(contractName, ".enabled")));
	}

	// *** Rewards Pool ***

	function getGGPRewardsEligibilityMinLength() public view returns (uint256) {
		return getUint(keccak256("ggp.rewards.eligibilityMinLength"));
	}

	/**
	 * Get how many seconds in a reward cycle
	 * @return uint256 Number of seconds in a reward interval
	 */
	function getGGPRewardCycleLength() public view returns (uint256) {
		return getUint(keccak256("ggp.rewards.cycleLength"));
	}

	/**
	 * The amount of ggp that has been released so far
	 * @return uint256 The supply of ggp that is in circulation
	 */
	function getTotalGGPCirculatingSupply() public view returns (uint256) {
		return getUint(keccak256("ggp.circulatingSupply"));
	}

	//TODO: restrict who can access this
	function setTotalGGPCirculatingSupply(uint256 amount) public {
		return setUint(keccak256("ggp.circulatingSupply"), amount);
	}

	/**
	 * Get the percentage a contract is owed this reward cycle
	 * @return uint256 Rewards percentage a contract will recieve this cycle
	 */
	function getClaimingContractPerc(string memory _claimingContract) public view returns (uint256) {
		return getUint(keccak256(abi.encodePacked("ggp.rewards.percentage", _claimingContract)));
	}

	//TODO: restrict who can set this
	function setClaimingContractPerc(string memory _claimingContract, uint256 decimal) public {
		setUint(keccak256(abi.encodePacked("ggp.rewards.percentage", _claimingContract)), decimal);
	}

	//*** GGP Inflation */

	/**
	 * The current inflation rate per interval (eg 1000133680617113500 = 5% annual)
	 * @return uint256 The current inflation rate per interval
	 */
	function getInflationIntervalRate() external view returns (uint256) {
		// Inflation rate controlled by the DAO
		return getUint(keccak256("ggp.inflation.intervalRate"));
	}

	/**
	 * The current block to begin inflation at
	 * @return uint256 The current block to begin inflation at
	 */
	function getInflationIntervalStartTime() external view returns (uint256) {
		// Inflation rate start time controlled by the DAO
		return getUint(keccak256("ggp.inflation.intervalStart"));
	}

	/**
	 * How many seconds to calculate inflation at
	 * @return uint256 how many seconds to calculate inflation at
	 */
	function getInflationInterval() public view returns (uint256) {
		return getUint(keccak256("ggp.inflation.interval"));
	}

	//*** GGAVAX ***
	/**
	 * Get how many seconds in a reward cycle
	 * @return uint256 Number of seconds in a reward interval
	 */
	function getGGAVAXRewardCycleLength() public view returns (uint256) {
		return getUint(keccak256("ggAvax.rewards.cycleLength"));
	}

	// *** Minipool Settings ***

	function getMinipoolMinStakingAmount() public view returns (uint256) {
		return getUint(keccak256("minipool.minStakingAmount"));
	}

	function getMinipoolNodeCommissionFeePercentage() public view returns (uint256) {
		return getUint(keccak256("minipool.nodeCommision"));
	}

	// Maximum AVAX a Node Operator can be assigned from liquid staking funds
	function getMinipoolAvaxAssignmentMax() public view returns (uint256) {
		return getUint(keccak256("minipool.maxAvaxAssignment"));
	}

	// Minimum AVAX a Node Operator can be assigned from liquid staking funds
	function getMinipoolAvaxAssignmentMin() public view returns (uint256) {
		return getUint(keccak256("minipool.minAvaxAssignment"));
	}

	function getExpectedRewardRate() public view returns (uint256) {
		return getUint(keccak256("avalanche.expectedRewardRate"));
	}

	//This is used in a test
	function setExpectedRewardRate(uint256 rate) public {
		setUint(keccak256("avalanche.expectedRewardRate"), rate);
	}

	//*** Staking ***
	function getMaxCollateralizationRatio() public view returns (uint256) {
		return getUint(keccak256("ggp.maxCollateralizationRatio"));
	}

	function getMinCollateralizationRatio() public view returns (uint256) {
		return getUint(keccak256("ggp.minCollateralizationRatio"));
	}

	// *** Delegation Settings ***
	function getDelegationDurationLimit() public view returns (uint256) {
		return getUint(keccak256("delegation.maxDuration"));
	}

	/**
	 * The target percentage of ggAVAX to hold in TokenggAVAX contract
	 * 1 ether = 100%
	 * 0.1 ether = 10%
	 * @return uint256 The current target reserve rate
	 */
	function getTargetGGAVAXReserveRate() external view returns (uint256) {
		return getUint(keccak256("ggAvax.reserveTarget"));
	}

	//This is used in a test
	function setTargetGGAVAXReserveRate(uint256 reserveRate) external {
		setUint(keccak256("ggAvax.reserveTarget"), reserveRate); // 10% collateral held in reserve
	}
}
