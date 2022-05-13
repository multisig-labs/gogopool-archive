// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.0;

import "../Base.sol";
import "../tokens/TokenGGP.sol";

// TODO: Add actual DAO functionality.

contract ProtocolDAO is Base {
	string private constant DAO_NAMESPACE = "dao.protocol.";
	string private constant DAO_SETTING_PATH = "dao.protocol.setting.";
	bytes32 private settingNamespace;

	constructor(Storage storageAddress) Base(storageAddress) {
		version = 1;
		settingNamespace = keccak256(abi.encodePacked(DAO_SETTING_PATH, DAO_NAMESPACE));
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
			// GGP Inflation settings
			// these may change when we finialize tokenomics
			setSettingUint("ggp.inflation.interval.rate", 1000133680617113500); // 5% annual calculated on a daily interval - Calculate in js example: let dailyInflation = web3.utils.toBN((1 + 0.05) ** (1 / (365)) * 1e18);
			setSettingUint("ggp.inflation.interval.start", block.timestamp + 1 days); // Set the default start date for inflation to begin as 1 day after deployment
			// Deployment check
			setBool(keccak256(abi.encodePacked(settingNamespace, "deployed")), true); // Flag that this contract has been deployed, so default settings don't get reapplied on a contract upgrade
		}
	}

	/// @dev set settings for the protocol
	// Update a Uint setting
	function setSettingUint(string memory _settingPath, uint256 _value) private {
		// Update setting now
		setUint(keccak256(abi.encodePacked(settingNamespace, _settingPath)), _value);
	}

	// updates a bool setting
	function setSettingBool(string memory _settingPath, bool _value) private {
		// Update setting now
		setBool(keccak256(abi.encodePacked(settingNamespace, _settingPath)), _value);
	}

	// updates an address setting
	function setSettingAddress(string memory _settingPath, address _value) private {
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
}
