pragma solidity ^0.8.13;

import "../../../Base.sol";

// TODO: Add actual DAO functionality.

contract ProtocolDAOSettingsInflation is Base {
	// The namespace for a particular group of settings
	bytes32 settingNameSpace;

	// Only allow updating from the DAO proposals contract
	modifier onlyDAOProtocolProposal() {
		// If this contract has been initialised, only allow access from the proposals contract
		if (getBool(keccak256(abi.encodePacked(settingNameSpace, "deployed"))))
			require(getContractAddress("rocketDAOProtocolProposals") == msg.sender, "Only DAO Protocol Proposals contract can update a setting");
		_;
	}

	// Construct
	constructor(Storage storageAddress) Base(storageAddress) {
		version = 1;
		// Set some initial settings on first deployment
		if (!getBool(keccak256(abi.encodePacked(settingNameSpace, "deployed")))) {
			// RPL Inflation settings
			setSettingUint("ggp.inflation.interval.rate", 1000133680617113500); // 5% annual calculated on a daily interval - Calculate in js example: let dailyInflation = web3.utils.toBN((1 + 0.05) ** (1 / (365)) * 1e18);
			setSettingUint("ggp.inflation.interval.start", block.timestamp + 1 days); // Set the default start date for inflation to begin as 1 day after deployment
			// Deployment check
			setBool(keccak256(abi.encodePacked(settingNameSpace, "deployed")), true); // Flag that this contract has been deployed, so default settings don't get reapplied on a contract upgrade
		}
	}

	function getInflationIntervalRate() public view returns (uint256) {
		return getSettingUint("ggp.inflation.interval.rate");
	}

	function getInflationIntervalStartTime() public view returns (uint256) {
		return getSettingUint("ggp.inflation.interval.start");
	}

	/*** Uints  ****************/

	// A general method to return any setting given the setting path is correct, only accepts uints
	function getSettingUint(string memory _settingPath) public view returns (uint256) {
		return getUint(keccak256(abi.encodePacked(settingNameSpace, _settingPath)));
	}

	// Update a Uint setting, can only be executed by the DAO contract when a majority on a setting proposal has passed and been executed
	function setSettingUint(string memory _settingPath, uint256 _value) public virtual onlyDAOProtocolProposal {
		// Update setting now
		setUint(keccak256(abi.encodePacked(settingNameSpace, _settingPath)), _value);
	}

	/*** Bools  ****************/

	// A general method to return any setting given the setting path is correct, only accepts bools
	function getSettingBool(string memory _settingPath) public view returns (bool) {
		return getBool(keccak256(abi.encodePacked(settingNameSpace, _settingPath)));
	}

	// Update a setting, can only be executed by the DAO contract when a majority on a setting proposal has passed and been executed
	function setSettingBool(string memory _settingPath, bool _value) public virtual onlyDAOProtocolProposal {
		// Update setting now
		setBool(keccak256(abi.encodePacked(settingNameSpace, _settingPath)), _value);
	}

	/*** Addresses  ****************/

	// A general method to return any setting given the setting path is correct, only accepts addresses
	function getSettingAddress(string memory _settingPath) external view returns (address) {
		return getAddress(keccak256(abi.encodePacked(settingNameSpace, _settingPath)));
	}

	// Update a setting, can only be executed by the DAO contract when a majority on a setting proposal has passed and been executed
	function setSettingAddress(string memory _settingPath, address _value) external virtual onlyDAOProtocolProposal {
		// Update setting now
		setAddress(keccak256(abi.encodePacked(settingNameSpace, _settingPath)), _value);
	}
}
