pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import {ERC20, ERC20Burnable} from "./ERC20Burnable.sol";
import {Vault} from "../Vault.sol";
import "../Base.sol";

// GGP Governance and utility token
// Inflationary with rate determined by DAO

contract TokenGGP is Base, ERC20Burnable {
	/**** Properties ***********/

	// RP has 18 million to start because of their fixed supply tokens
	// how many should we have since we're starting from 0?
	uint256 private constant TOTAL_INITIAL_SUPPLY = 1000000 ether;
	// The GGP inflation interval
	uint256 private constant INFLATION_INTERVAL = 1 days;

	// Timestamp of last block inflation was calculated at
	uint256 private inflationCalcTime = 0;

	// setting namespace
	bytes32 private settingNamespace;

	/**** Events ***********/

	event GGPInflationLog(address sender, uint256 value, uint256 inflationCalcTime);
	event GGPFixedSupplyBurn(address indexed from, uint256 amount, uint256 time);
	event MintGGPToken(address _minter, address _address, uint256 _value);

	constructor(Storage storageAddress) Base(storageAddress) ERC20("GoGoPool Protocol", "GGP", 18) {
		version = 1;
		settingNamespace = keccak256(abi.encodePacked("dao.protocol.setting.", "dao.protocol."));
		_mint(msg.sender, TOTAL_INITIAL_SUPPLY);
	}

	function _getInflationCalcTime() private view returns (uint256) {
		// Get the last time inflation was calculated if it has even started
		uint256 inflationStartTime = getInflationIntervalStartTime();
		// If inflation has just begun but not been calculated previously, use the start block as the last calculated point if it has passed
		return inflationCalcTime == 0 && inflationStartTime < block.timestamp ? inflationStartTime : inflationCalcTime;
	}

	/**
	 * Get the last time that inflation was calculated at
	 * @return uint256 Last timestamp since inflation was calculated
	 */
	function getInflationCalcTime() external view returns (uint256) {
		return _getInflationCalcTime();
	}

	/**
	 * How many seconds to calculate inflation at
	 * @return uint256 how many seconds to calculate inflation at
	 */
	function getInflationIntervalTime() external pure returns (uint256) {
		return INFLATION_INTERVAL;
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
	function getInflationIntervalStartTime() public view returns (uint256) {
		// Inflation rate start time controlled by the DAO
		return getSettingUint(settingNamespace, "ggp.inflation.interval.start");
	}

	function _getIntervalsSinceLastMint() private view returns (uint256) {
		uint256 inflationLastCalculatedTime = _getInflationCalcTime();
		return _getInflationIntervalsPassed(inflationLastCalculatedTime);
	}

	/**
	 * Compute interval since last inflation update (on call)
	 * @return uint256 Time intervals since last update
	 */
	function getInflationIntervalsPassed() external view returns (uint256) {
		return _getIntervalsSinceLastMint();
	}

	function _getInflationIntervalsPassed(uint256 _inflationLastCalcTime) private view returns (uint256) {
		// Calculate now if inflation has begun
		if (_inflationLastCalcTime > 0) {
			return ((block.timestamp) - (_inflationLastCalcTime)) / INFLATION_INTERVAL;
		} else {
			return 0;
		}
	}

	function getInflationRewardsContractAddress() external view returns (address) {
		// Inflation rewards contract address controlled by the DAO
		// does not exist yet
		return getContractAddress("rewards");
	}

	/**
	 * @dev Function to compute how many tokens should be minted
	 * @return A uint256 specifying number of new tokens to mint
	 */
	function inflationCalculate() external view returns (uint256) {
		return _inflationCalculate(_getIntervalsSinceLastMint());
	}

	function _inflationCalculate(uint256 _intervalsSinceLastMint) private view returns (uint256) {
		// The inflation amount
		uint256 inflationTokenAmount = 0;
		// Only update  if last interval has passed and inflation rate is > 0
		if (_intervalsSinceLastMint > 0) {
			// Optimisation
			uint256 inflationRate = getSettingUint(settingNamespace, "ggp.inflation.interval.rate");
			if (inflationRate > 0) {
				// Get the total supply now
				uint256 totalSupplyCurrent = totalSupply;
				uint256 newTotalSupply = totalSupplyCurrent;
				// Compute inflation for total inflation intervals elapsed
				for (uint256 i = 0; i < _intervalsSinceLastMint; i++) {
					newTotalSupply = (newTotalSupply * (inflationRate)) / (10**18);
				}
				// Return inflation amount
				inflationTokenAmount = newTotalSupply - totalSupplyCurrent;
			}
		}
		// Done
		return inflationTokenAmount;
	}

	/**
	 * @dev Mint new tokens if enough time has elapsed since last mint
	 * @return A uint256 specifying number of new tokens that were minted
	 */
	function inflationMintTokens() external returns (uint256) {
		// Only run inflation process if at least 1 interval has passed (function returns 0 otherwise)
		uint256 inflationLastCalcTime = _getInflationCalcTime();
		uint256 intervalsSinceLastMint = _getInflationIntervalsPassed(inflationLastCalcTime);
		if (intervalsSinceLastMint == 0) {
			return 0;
		}
		// Address of the vault where to send tokens
		address vaultAddress = getContractAddress("Vault");
		require(vaultAddress != address(0x0), "Vault address not set");
		// Only mint if we have new tokens to mint since last interval and an address is set to receive them
		Vault vaultContract = Vault(vaultAddress);
		// Calculate the amount of tokens now based on inflation rate
		uint256 newTokens = _inflationCalculate(intervalsSinceLastMint);
		// Update last inflation calculation timestamp even if inflation rate is 0
		inflationCalcTime = (inflationLastCalcTime + INFLATION_INTERVAL) * intervalsSinceLastMint;
		// Check if actually need to mint tokens (e.g. inflation rate > 0)
		if (newTokens > 0) {
			// Mint to itself, then allocate tokens for transfer to rewards contract, this will update balance & supply
			_mint(address(this), newTokens);
			// Let vault know it can move these tokens to itself now and credit the balance to the GGP rewards pool contract
			// TODO Fix this to work for GoGo
			vaultContract.depositToken("rocketRewardsPool", ERC20(address(this)), newTokens);
		}
		// Log it
		emit GGPInflationLog(msg.sender, newTokens, inflationCalcTime);
		// return number minted
		return newTokens;
	}
}
