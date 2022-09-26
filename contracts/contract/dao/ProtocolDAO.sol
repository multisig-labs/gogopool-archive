// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.13;

import {TokenGGP} from "../tokens/TokenGGP.sol";
import {Base} from "../Base.sol";
import {Storage} from "../Storage.sol";

// TODO: Add actual DAO functionality.

contract ProtocolDAO is Base {
	bytes32 private settingNamespace;

	constructor(Storage storageAddress) Base(storageAddress) {
		version = 1;
		settingNamespace = keccak256(abi.encodePacked("dao.protocol.setting."));
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
		if (!getBool(keccak256(abi.encodePacked(settingNamespace, "deployed")))) {
			setSettingUint("avalanche.expectedRewardRate", 0.1 ether); // Annual rate as pct of 1 avax
			// GGP Inflation settings
			// these may change when we finialize tokenomics
			setSettingUint("ggp.inflation.interval.rate", 1000133680617113500); // 5% annual calculated on a daily interval - Calculate in js example: let dailyInflation = web3.utils.toBN((1 + 0.05) ** (1 / (365)) * 1e18);
			setSettingUint("ggp.inflation.interval.start", (block.timestamp + 1 days)); // Set the default start date for inflation to begin as 1 day after deployment
			setSettingUint("ggp.inflation.interval", 1 days);
			setSettingUint("ggavax.reserve.target", 0.1 ether); // 10% collateral held in reserver
			//Delegation duration limit set to 2 Months
			setSettingUint("delegation.maxDuration", 5097600);

			// Minipool Settings
			setSettingUint("minipool.maxAvaxAssignment", 10_000 ether);
			setSettingUint("minipool.minAvaxAssignment", 1_000 ether);
			setSettingUint("minipool.ggpCollateralRate", 0.1 ether);

			// Deployment check
			setBool(keccak256(abi.encodePacked(settingNamespace, "deployed")), true); // Flag that this contract has been deployed, so default settings don't get reapplied on a contract upgrade
		}
	}

	// TODO Should we use dedicated funcs like this to access values?
	function getDelegationDurationLimit() public view returns (uint256) {
		return getSettingUint(settingNamespace, "delegation.maxDuration");
	}

	// TODO Should we use dedicated funcs like this to access values?
	function getExpectedRewardRate() public view returns (uint256) {
		return getSettingUint(settingNamespace, "avalanche.expectedRewardRate");
	}

	// TODO security modifiers for below

	/// @dev set settings for the protocol
	// Update a Uint setting
	function setSettingUint(string memory _settingPath, uint256 _value) public {
		// Update setting now
		setUint(keccak256(abi.encodePacked(settingNamespace, _settingPath)), _value);
	}

	// updates a bool setting
	function setSettingBool(string memory _settingPath, bool _value) public {
		// Update setting now
		setBool(keccak256(abi.encodePacked(settingNamespace, _settingPath)), _value);
	}

	// updates an address setting
	function setSettingAddress(string memory _settingPath, address _value) public {
		// Update setting now
		setAddress(keccak256(abi.encodePacked(settingNamespace, _settingPath)), _value);
	}

	/**
	 * The current inflation rate per interval (eg 1000133680617113500 = 5% annual)
	 * @return uint256 The current inflation rate per interval
	 */
	function getInflationIntervalRate() external view returns (uint256) {
		// Inflation rate controlled by the DAO
		return getSettingUint(settingNamespace, "ggp.inflation.interval.rate");
	}

	/**
	 * The current block to begin inflation at
	 * @return uint256 The current block to begin inflation at
	 */
	function getInflationIntervalStartTime() external view returns (uint256) {
		// Inflation rate start time controlled by the DAO
		return getSettingUint(settingNamespace, "ggp.inflation.interval.start");
	}

	/**
	 * How many seconds to calculate inflation at
	 * @return uint256 how many seconds to calculate inflation at
	 */
	function getInflationInterval() public view returns (uint256) {
		return getSettingUint(settingNamespace, "ggp.inflation.interval");
	}

	/**
	 * The target percentage of ggAVAX to hold in TokenggAVAX contract
	 * 1 ether = 100%
	 * 0.1 ether = 10%
	 * @return uint256 The current target reserve rate
	 */
	function getTargetggAVAXReserveRate() external view returns (uint256) {
		return getSettingUint(settingNamespace, "ggavax.reserve.target");
	}

	function setTargetggAVAXReserveRate(uint256 reserveRate) external {
		setSettingUint("ggavax.reserve.target", reserveRate); // 10% collateral held in reserve
	}

	// Minipool Settings
	// Maximum AVAX a Node Operator can be assigned from liquid staking funds
	function getMinipoolAvaxAssignmentMax() public view returns (uint256) {
		return getSettingUint(settingNamespace, "minipool.maxAvaxAssignment");
	}

	// Minimum AVAX a Node Operator can be assigned from liquid staking funds
	function getMinipoolAvaxAssignmentMin() public view returns (uint256) {
		return getSettingUint(settingNamespace, "minipool.minAvaxAssignment");
	}

	// Minimum GGP collateralization for assigned liquid staker AVAX
	function getMinipoolGgpCollateralRate() public view returns (uint256) {
		return getSettingUint(settingNamespace, "minipool.ggpCollateralRate");
	}
}
