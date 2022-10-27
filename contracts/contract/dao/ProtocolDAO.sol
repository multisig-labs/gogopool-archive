// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;

import "../Base.sol";
import {TokenGGP} from "../tokens/TokenGGP.sol";
import {Storage} from "../Storage.sol";

contract ProtocolDAO is Base {
	error NotDAOMember();

	constructor(Storage storageAddress) Base(storageAddress) {
		version = 1;
	}

	// modifier that checks if the caller is a dao member
	modifier isDaoMember() {
		TokenGGP token = TokenGGP(getContractAddress("tokenGGP"));
		if (token.balanceOf(msg.sender) == 0) {
			revert NotDAOMember();
		}
		_;
	}

	function initialize() external onlyGuardian {
		if (getBool(keccak256("ProtocolDAO.initialized"))) {
			return;
		}
		setBool(keccak256("ProtocolDAO.initialized"), true);

		//NOPClaim settings
		setUint(keccak256("ProtocolDAO.RewardsEligibilityMinSeconds"), 14 days);

		//RewardsPool Settings
		setUint(keccak256("ProtocolDAO.RewardsCycleSeconds"), 28 days); // The time in which a claim period will span in seconds - 28 days by default
		setUint(keccak256("ProtocolDAO.TotalGGPCirculatingSupply"), 18_000_000 ether);
		setUint(keccak256("ProtocolDAO.ClaimingContractPct.ProtocolDAOClaim"), 0.10 ether);
		setUint(keccak256("ProtocolDAO.ClaimingContractPct.NOPClaim"), 0.70 ether);
		setUint(keccak256("ProtocolDAO.ClaimingContractPct.RialtoClaim"), 0.20 ether);

		// GGP Inflation settings
		setUint(keccak256("ProtocolDAO.InflationIntervalSeconds"), 1 days);
		setUint(keccak256("ProtocolDAO.InflationIntervalRate"), 1000133680617113500); // 5% annual calculated on a daily interval - Calculate in js example: let dailyInflation = web3.utils.toBN((1 + 0.05) ** (1 / (365)) * 1e18);

		//TokenGGAvax settings
		setUint(keccak256("ProtocolDAO.TargetGGAVAXReserveRate"), 0.1 ether); // 10% collateral held in reserve

		//TokenGGP settings

		//Minipool settings
		setUint(keccak256("ProtocolDAO.MinipoolMinStakingAmount"), 2_000 ether);
		setUint(keccak256("ProtocolDAO.MinipoolNodeCommissionFeePct"), 0.15 ether);
		setUint(keccak256("ProtocolDAO.MinipoolMaxAVAXAssignment"), 10_000 ether);
		setUint(keccak256("ProtocolDAO.MinipoolMinAVAXAssignment"), 1_000 ether);
		setUint(keccak256("ProtocolDAO.ExpectedAVAXRewardsRate"), 0.1 ether); // Annual rate as pct of 1 avax

		// Staking settings
		setUint(keccak256("ProtocolDAO.MaxCollateralizationRatio"), 1.5 ether);
		setUint(keccak256("ProtocolDAO.MinCollateralizationRatio"), 0.1 ether);
	}

	function getContractPaused(string memory contractName) public view returns (bool) {
		return getBool(keccak256(abi.encodePacked("contract.paused", contractName)));
	}

	function pauseContract(string memory contractName) public {
		setBool(keccak256(abi.encodePacked("contract.paused", contractName)), true);
	}

	function resumeContract(string memory contractName) public {
		setBool(keccak256(abi.encodePacked("contract.paused", contractName)), false);
	}

	// *** Rewards Pool ***

	function getRewardsEligibilityMinSeconds() public view returns (uint256) {
		return getUint(keccak256("ProtocolDAO.RewardsEligibilityMinSeconds"));
	}

	/**
	 * Get how many seconds in a rewards cycle
	 * @return uint256 Number of seconds in a rewards interval
	 */
	function getRewardsCycleSeconds() public view returns (uint256) {
		return getUint(keccak256("ProtocolDAO.RewardsCycleSeconds"));
	}

	/**
	 * The amount of ggp that has been released so far
	 * @return uint256 The supply of ggp that is in circulation
	 */
	function getTotalGGPCirculatingSupply() public view returns (uint256) {
		return getUint(keccak256("ProtocolDAO.TotalGGPCirculatingSupply"));
	}

	function setTotalGGPCirculatingSupply(uint256 amount) public onlyLatestContract("RewardsPool", msg.sender) {
		return setUint(keccak256("ProtocolDAO.TotalGGPCirculatingSupply"), amount);
	}

	/**
	 * Get the percentage a contract is owed this rewards cycle
	 * @return uint256 Rewards percentage a contract will receive this cycle
	 */
	function getClaimingContractPct(string memory claimingContract) public view returns (uint256) {
		return getUint(keccak256(abi.encodePacked("ProtocolDAO.ClaimingContractPct.", claimingContract)));
	}

	function setClaimingContractPct(string memory claimingContract, uint256 decimal) public onlyGuardian {
		setUint(keccak256(abi.encodePacked("ProtocolDAO.ClaimingContractPct.", claimingContract)), decimal);
	}

	//*** GGP Inflation */

	/**
	 * The current inflation rate per interval (eg 1000133680617113500 = 5% annual)
	 * @return uint256 The current inflation rate per interval (can never be < 1 ether)
	 */
	function getInflationIntervalRate() external view returns (uint256) {
		// Inflation rate controlled by the DAO
		uint256 rate = getUint(keccak256("ProtocolDAO.InflationIntervalRate"));
		return rate < 1 ether ? 1 ether : rate;
	}

	/**
	 * The current block to begin inflation at
	 * @return uint256 The current block to begin inflation at
	 */
	function getInflationIntervalStartTime() external view returns (uint256) {
		// Inflation rate start time controlled by the DAO
		return getUint(keccak256("ProtocolDAO.InflationIntervalStartTime"));
	}

	/**
	 * How many seconds to calculate inflation at
	 * @return uint256 how many seconds to calculate inflation at
	 */
	function getInflationIntervalSeconds() public view returns (uint256) {
		return getUint(keccak256("ProtocolDAO.InflationIntervalSeconds"));
	}

	// *** Minipool Settings ***

	function getMinipoolMinStakingAmount() public view returns (uint256) {
		return getUint(keccak256("ProtocolDAO.MinipoolMinStakingAmount"));
	}

	function getMinipoolNodeCommissionFeePct() public view returns (uint256) {
		return getUint(keccak256("ProtocolDAO.MinipoolNodeCommissionFeePct"));
	}

	// Maximum AVAX a Node Operator can be assigned from liquid staking funds
	function getMinipoolMaxAVAXAssignment() public view returns (uint256) {
		return getUint(keccak256("ProtocolDAO.MinipoolMaxAVAXAssignment"));
	}

	// Minimum AVAX a Node Operator can be assigned from liquid staking funds
	function getMinipoolMinAVAXAssignment() public view returns (uint256) {
		return getUint(keccak256("ProtocolDAO.MinipoolMinAVAXAssignment"));
	}

	function getExpectedAVAXRewardsRate() public view returns (uint256) {
		return getUint(keccak256("ProtocolDAO.ExpectedAVAXRewardsRate"));
	}

	//This is used in a test
	function setExpectedAVAXRewardsRate(uint256 rate) public {
		setUint(keccak256("ProtocolDAO.ExpectedAVAXRewardsRate"), rate);
	}

	//*** Staking ***
	function getMaxCollateralizationRatio() public view returns (uint256) {
		return getUint(keccak256("ProtocolDAO.MaxCollateralizationRatio"));
	}

	function getMinCollateralizationRatio() public view returns (uint256) {
		return getUint(keccak256("ProtocolDAO.MinCollateralizationRatio"));
	}

	/**
	 * The target percentage of ggAVAX to hold in TokenggAVAX contract
	 * 1 ether = 100%
	 * 0.1 ether = 10%
	 * @return uint256 The current target reserve rate
	 */
	function getTargetGGAVAXReserveRate() external view returns (uint256) {
		return getUint(keccak256("ProtocolDAO.TargetGGAVAXReserveRate"));
	}
}
