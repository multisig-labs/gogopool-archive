pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "../Base.sol";
import {Storage} from "../Storage.sol";
import {Vault} from "../Vault.sol";
import {TokenGGP} from "../tokens/TokenGGP.sol";
import "../dao/protocol/settings/ProtocolDAOSettingsInflation.sol";

// GGP Rewards claiming by the DAO
contract RewardsPool is Base {
	// this contract mints staking rewards
	// or maybe is minted staking rewards

	constructor(Storage storageAddress) Base(storageAddress) {
		version = 1;
		setUint("ggp.rewards.claim.period.time", 28 days); // The time in which a claim period will span in seconds - 28 days by default
		setUint("ggp.inflation.interval.rate", 1000133680617113500); // 5% annual calculated on a daily interval - Calculate in js example: let dailyInflation = web3.utils.toBN((1 + 0.05) ** (1 / (365)) * 1e18);
		setUint("ggp.inflation.interval.start", block.timestamp + 1 days); // Set the default start date for inflation to begin as 1 day after deployment
		setUint(keccak256(abi.encodePacked("ProtocolDAOClaim", "rewards.claims", "group.amount", "ProtocolDAOClaim")), .10 ether);
		setUint(keccak256(abi.encodePacked("NOPClaim", "rewards.claims", "group.amount", "NOPClaim")), .70 ether);
		setUint(keccak256(abi.encodePacked("RialtoClaim", "rewards.claims", "group.amount", "RialtoClaim")), .20 ether);
	}

	/**** Properties ***********/

	// How many GGP tokens protocol is starting with
	uint256 constant totalInitialSupply = 18000000000000000000000000;
	// How many GGP tokens are in circulation (all tokens - unreleased reward tokens)
	uint256 private totalCirculatingSupply = 18000000000000000000000000;
	// The GGP inflation interval
	uint256 constant inflationInterval = 1 days;

	// Timestamp of last block inflation was calculated at
	uint256 private inflationCalcTime = 0;

	/**** Events ***********/

	event GGPInflationLog(address sender, uint256 value, uint256 inflationCalcTime);

	/**
	 * Get the last time that inflation was calculated at
	 * @return uint256 Last timestamp since inflation was calculated
	 */
	function getInflationCalcTime() public view returns (uint256) {
		// Get the last time inflation was calculated if it has even started
		uint256 inflationStartTime = getInflationIntervalStartTime();
		// If inflation has just begun but not been calculated previously, use the start block as the last calculated point if it has passed
		return inflationCalcTime == 0 && inflationStartTime < block.timestamp ? inflationStartTime : inflationCalcTime;
	}

	/**
	 * How many seconds to calculate inflation at
	 * @return uint256 how many seconds to calculate inflation at
	 */
	function getInflationIntervalTime() external pure returns (uint256) {
		return inflationInterval;
	}

	/**
	 * The current inflation rate per interval (eg 1000133680617113500 = 5% annual)
	 * @return uint256 The current inflation rate per interval
	 */
	function getInflationIntervalRate() public view returns (uint256) {
		// Inflation rate controlled by the DAO
		return getUint("ggp.inflation.interval.rate");
	}

	/**
	 * The current block to begin inflation at
	 * @return uint256 The current block to begin inflation at
	 */
	function getInflationIntervalStartTime() public view returns (uint256) {
		// Inflation rate start time controlled by the DAO
		return getUint("ggp.inflation.interval.start");
	}

	/**
	 * The current rewards pool address that receives the inflation
	 * @return address The rewards pool contract address
	 */
	function getInflationRewardsContractAddress() external view returns (address) {
		// Inflation rate start block controlled by the DAO
		return getContractAddress("RewardsPool");
	}

	/**
	 * Compute interval since last inflation update (on call)
	 * @return uint256 Time intervals since last update
	 */
	function getInflationIntervalsPassed() public view returns (uint256) {
		// The time that inflation was last calculated at
		uint256 inflationLastCalculatedTime = getInflationCalcTime();
		return _getInflationIntervalsPassed(inflationLastCalculatedTime);
	}

	function _getInflationIntervalsPassed(uint256 _inflationLastCalcTime) private view returns (uint256) {
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
		// The inflation amount
		uint256 inflationTokenAmount = 0;

		// Only update  if last interval has passed and inflation rate is > 0
		if (_intervalsSinceLastMint > 0) {
			// Optimisation
			uint256 inflationRate = getInflationIntervalRate();
			if (inflationRate > 0) {
				// Get the total supply now
				uint256 totalSupplyCurrent = totalCirculatingSupply;
				uint256 newTotalSupply = totalSupplyCurrent;

				// Compute inflation for total inflation intervals elapsed
				for (uint256 i = 0; i < _intervalsSinceLastMint; i++) {
					newTotalSupply = (newTotalSupply * inflationRate) / (10**18);
				}

				// Return inflation amount
				inflationTokenAmount = newTotalSupply - (totalSupplyCurrent);
			}
		}
		// Done
		return inflationTokenAmount;
	}

	// An account must be registered to claim from the rewards pool. They must wait one claim interval before they can collect.
	// Also keeps track of total
	// TODO onlyClaimContract
	function registerClaimer(address _claimerAddress, bool _enabled) external {
		// The name of the claiming contract
		string memory contractName = getContractName(msg.sender);
		// Record the time they are registering at
		uint256 registeredTime = 0;
		// How many users are to be included in next interval
		uint256 claimersIntervalTotalUpdate = getClaimingContractUserTotalNext(contractName);
		// Ok register
		if (_enabled) {
			// Make sure they are not already registered
			require(getClaimingContractUserRegisteredTime(contractName, _claimerAddress) == 0, "Claimer is already registered");
			// Update time
			registeredTime = block.timestamp;
			// Update the total registered claimers for next interval
			setUint(keccak256(abi.encodePacked("rewards.pool.claim.interval.claimers.total.next", contractName)), claimersIntervalTotalUpdate + 1);
		} else {
			// Make sure they are already registered
			require(getClaimingContractUserRegisteredTime(contractName, _claimerAddress) != 0, "Claimer is not registered");
			// Update the total registered claimers for next interval
			setUint(keccak256(abi.encodePacked("rewards.pool.claim.interval.claimers.total.next", contractName)), claimersIntervalTotalUpdate - 1);
		}
		// Save the registered time
		setUint(keccak256(abi.encodePacked("rewards.pool.claim.contract.registered.time", contractName, _claimerAddress)), registeredTime);
	}

	/**
	 * @dev Mint new tokens if enough time has elapsed since last mint
	 */
	function inflationMintTokens() internal {
		// Only run inflation process if at least 1 interval has passed (function returns 0 otherwise)
		uint256 inflationLastCalcTime = getInflationCalcTime();
		uint256 intervalsSinceLastMint = _getInflationIntervalsPassed(inflationLastCalcTime);

		uint256 newTokens = _inflationCalculate(intervalsSinceLastMint);
		totalCirculatingSupply = totalCirculatingSupply + newTokens;
		// Update last inflation calculation timestamp even if inflation rate is 0
		inflationCalcTime = inflationLastCalcTime + (inflationInterval * intervalsSinceLastMint); // Check if actually need to mint tokens (e.g. inflation rate > 0)
		setUint(keccak256("rewards.pool.claim.interval.total"), newTokens);
	}

	function getGGPBalance() external view returns (uint256) {
		// Get the vault contract instance
		Vault vault = Vault(getContractAddress("Vault"));
		TokenGGP ggp = TokenGGP(getContractAddress("TokenGGP"));
		// Check per contract
		return vault.balanceOfToken("RewardsPool", ggp);
	}

	/**
	 * Get the last set interval start time
	 * @return uint256 Last set start timestamp for a claim interval
	 */
	function getClaimIntervalTimeStart() public view returns (uint256) {
		return getUint(keccak256("rewards.pool.claim.interval.time.start"));
	}

	/**
	 * Compute the current start time before a claim is made, takes into account intervals that may have passed
	 * @return uint256 Computed starting timestamp for next possible claim
	 */
	function getClaimIntervalTimeStartComputed() public view returns (uint256) {
		// If intervals have passed, a new start timestamp will be used for the next claim, if it's the same interval then return that
		uint256 claimIntervalTimeStart = getClaimIntervalTimeStart();
		uint256 claimIntervalTime = getClaimIntervalTime();
		return _getClaimIntervalTimeStartComputed(claimIntervalTimeStart, claimIntervalTime);
	}

	function _getClaimIntervalTimeStartComputed(uint256 _claimIntervalTimeStart, uint256 _claimIntervalTime) private view returns (uint256) {
		uint256 claimIntervalsPassed = _getClaimIntervalsPassed(_claimIntervalTimeStart, _claimIntervalTime);
		return claimIntervalsPassed == 0 ? _claimIntervalTimeStart : _claimIntervalTimeStart + (_claimIntervalTime * (claimIntervalsPassed));
	}

	/**
	 * Compute intervals since last claim period
	 * @return uint256 Time intervals since last update
	 */
	function getClaimIntervalsPassed() public view returns (uint256) {
		// Calculate now if inflation has begun
		return _getClaimIntervalsPassed(getClaimIntervalTimeStart(), getClaimIntervalTime());
	}

	// TODO double check that this order of operations works as intended
	function _getClaimIntervalsPassed(uint256 _claimIntervalTimeStart, uint256 _claimIntervalTime) private view returns (uint256) {
		return block.timestamp - (_claimIntervalTimeStart) / (_claimIntervalTime);
	}

	/**
	 * Get how many seconds in a claim interval
	 * @return uint256 Number of seconds in a claim interval
	 */
	// TODO implement dao settings
	function getClaimIntervalTime() public view returns (uint256) {
		// Get from the DAO settings
		// RocketDAOProtocolSettingsRewardsInterface daoSettingsRewards = RocketDAOProtocolSettingsRewardsInterface(getContractAddress("rocketDAOProtocolSettingsRewards"));
		// return daoSettingsRewards.getRewardsClaimIntervalTime();
		return getUint("ggp.rewards.claim.period.time");
	}

	/**
	 * Get the last time a claim was made
	 * @return uint256 Last time a claim was made
	 */
	function getClaimTimeLastMade() external view returns (uint256) {
		return getUint(keccak256("rewards.pool.claim.interval.time.last"));
	}

	/**
	 * Get the number of claimers that will be added/removed on the next interval
	 * @return uint256 Returns the number of claimers that will be added/removed on the next interval
	 */
	function getClaimingContractUserTotalNext(string memory _claimingContract) public view returns (uint256) {
		return getUint(keccak256(abi.encodePacked("rewards.pool.claim.interval.claimers.total.next", _claimingContract)));
	}

	// Check whether a claiming contract exists
	// TODO implement
	function getClaimingContractExists(string memory _contractName) public pure returns (bool) {
		// RocketDAOProtocolSettingsRewardsInterface daoSettingsRewards = RocketDAOProtocolSettingsRewardsInterface(getContractAddress("rocketDAOProtocolSettingsRewards"));
		// return (daoSettingsRewards.getRewardsClaimerPercTimeUpdated(_contractName) > 0);
		_contractName;
		return true;
	}

	// TODO implement
	// If the claiming contact has a % allocated to it higher than 0, it can claim
	function getClaimingContractEnabled(string memory _contractName) public pure returns (bool) {
		// Load contract
		// RocketDAOProtocolSettingsRewardsInterface daoSettingsRewards = RocketDAOProtocolSettingsRewardsInterface(getContractAddress("rocketDAOProtocolSettingsRewards"));
		// Now verify this contract can claim by having a claim perc > 0
		// return daoSettingsRewards.getRewardsClaimerPerc(_contractName) > 0 ? true : false;
		_contractName;
		return true;
	}

	/**
	 * The current claim amount total for this interval per claiming contract
	 * @return uint256 The current claim amount for this interval for the claiming contract
	 */
	function getClaimingContractTotalClaimed(string memory _claimingContract) external view returns (uint256) {
		return _getClaimingContractTotalClaimed(_claimingContract, getClaimIntervalTimeStartComputed());
	}

	function _getClaimingContractTotalClaimed(string memory _claimingContract, uint256 _claimIntervalTimeStartComputed) private view returns (uint256) {
		return getUint(keccak256(abi.encodePacked("rewards.pool.claim.interval.contract.total", _claimIntervalTimeStartComputed, _claimingContract)));
	}

	/**
	 * Have they claimed already during this interval?
	 * @return bool Returns true if they can claim during this interval
	 */
	function getClaimingContractUserHasClaimed(
		uint256 _claimIntervalStartTime,
		string memory _claimingContract,
		address _claimerAddress
	) public view returns (bool) {
		// Check per contract
		// return false;
		// TODO implement
		return
			getBool(
				keccak256(abi.encodePacked("rewards.pool.claim.interval.claimer.address", _claimIntervalStartTime, _claimingContract, _claimerAddress))
			);
	}

	/**
	 * Get the time this account registered as a claimer at
	 * @return uint256 Returns the time the account was registered at
	 */
	function getClaimingContractUserRegisteredTime(string memory _claimingContract, address _claimerAddress) public view returns (uint256) {
		return getUint(keccak256(abi.encodePacked("rewards.pool.claim.contract.registered.time", _claimingContract, _claimerAddress)));
	}

	/**
	 * Get whether this address can currently make a claim
	 * @return bool Returns true if the _claimerAddress can make a claim
	 */
	function getClaimingContractUserCanClaim(string memory _claimingContract, address _claimerAddress) public view returns (bool) {
		return _getClaimingContractUserCanClaim(_claimingContract, _claimerAddress, getClaimIntervalTime());
	}

	function _getClaimingContractUserCanClaim(
		string memory _claimingContract,
		address _claimerAddress,
		uint256 _claimIntervalTime
	) private view returns (bool) {
		// Get the time they registered at
		uint256 registeredTime = getClaimingContractUserRegisteredTime(_claimingContract, _claimerAddress);

		// prettier-ignore
		return
			registeredTime > 0
			&& registeredTime + (_claimIntervalTime) <= block.timestamp
			&& getClaimingContractPerc(_claimingContract) > 0;
	}

	/**
	 * Get the percentage this contract can claim in this interval
	 * @return uint256 Rewards percentage this contract can claim in this interval
	 */
	// TODO implement
	function getClaimingContractPerc(string memory _claimingContract) public view returns (uint256) {
		return getUint(keccak256(abi.encodePacked(_claimingContract, "rewards.claims", "group.amount", _claimingContract)));
	}

	/**
	 * Get the approx amount of rewards available for this claim interval
	 * @return uint256 Rewards amount for current claim interval
	 */
	// TODO handle the case where there are leftover rewards from the last period.
	// Rocketpool did this b cehcking the balance of the rewards pool contract in the vault
	// but since we already have all the rewards minted, this needs to be handled differently.
	function getClaimIntervalRewardsTotal() public view returns (uint256) {
		return getUint(keccak256("rewards.pool.claim.interval.total"));
	}

	/**
	 * Get the approx amount of rewards available for this claim interval per claiming contract
	 * @return uint256 Rewards amount for current claim interval per claiming contract
	 */
	function getClaimingContractAllowance(string memory _claimingContract) public view returns (uint256) {
		// Get the % amount this claim contract will get
		uint256 claimContractPerc = getClaimingContractPerc(_claimingContract);
		// How much rewards are available for this claim interval?
		uint256 claimIntervalRewardsTotal = getClaimIntervalRewardsTotal();

		// How much this claiming contract is entitled to in perc
		uint256 contractClaimTotal = 0;
		// Check now
		if (claimContractPerc > 0 && claimIntervalRewardsTotal > 0) {
			// Calculate how much rewards this claimer will receive based on their claiming perc
			contractClaimTotal = (claimContractPerc * (claimIntervalRewardsTotal)) / (CALC_BASE);
		}
		// Done
		return contractClaimTotal;
	}

	// How much this claimer is entitled to claim, checks parameters that claim() will check
	function getClaimAmount(
		string memory _claimingContract,
		address _claimerAddress,
		uint256 _claimerAmountPerc
	) external view returns (uint256) {
		if (!getClaimingContractUserCanClaim(_claimingContract, _claimerAddress)) {
			return 0;
		}
		uint256 claimIntervalTimeStartComptued = getClaimIntervalTimeStartComputed();
		uint256 claimingContractTotalClaimed = _getClaimingContractTotalClaimed(_claimingContract, claimIntervalTimeStartComptued);
		return _getClaimAmount(_claimingContract, _claimerAddress, _claimerAmountPerc, claimIntervalTimeStartComptued, claimingContractTotalClaimed);
	}

	function _getClaimAmount(
		string memory _claimingContract,
		address _claimerAddress,
		uint256 _claimerAmountPerc,
		uint256 _claimIntervalTimeStartComputed,
		uint256 _claimingContractTotalClaimed
	) private view returns (uint256) {
		// Get the total rewards available for this claiming contract
		uint256 contractClaimTotal = getClaimingContractAllowance(_claimingContract);
		// How much of the above that this claimer will receive
		uint256 claimerTotal = 0;
		// Are we good to proceed?
		if (
			contractClaimTotal > 0 &&
			_claimerAmountPerc > 0 &&
			_claimerAmountPerc <= 1 ether &&
			_claimerAddress != address(0x0) &&
			getClaimingContractEnabled(_claimingContract) &&
			!getClaimingContractUserHasClaimed(_claimIntervalTimeStartComputed, _claimingContract, _claimerAddress)
		) {
			// Now calculate how much this claimer would receive
			claimerTotal = (_claimerAmountPerc * contractClaimTotal) / (CALC_BASE);
			// Is it more than currently available + the amount claimed already for this claim interval?
			claimerTotal = claimerTotal + (_claimingContractTotalClaimed) <= contractClaimTotal ? claimerTotal : 0;
		}
		// Done
		return claimerTotal;
	}

	// A claiming contract claiming for a user and the percentage of the rewards they are allowed to receive
	// TODO modifier onlyEnabledClaimContract
	function claim(
		address _claimerAddress,
		address _toAddress,
		uint256 _claimerAmountPerc
	) external {
		// The name of the claiming contract
		string memory contractName = getContractName(msg.sender);
		// Check to see if this registered claimer has waited one interval before collecting
		uint256 claimIntervalTime = getClaimIntervalTime();
		require(
			_getClaimingContractUserCanClaim(contractName, _claimerAddress, claimIntervalTime),
			"Registered claimer is not registered to claim or has not waited one claim interval"
		);
		TokenGGP ggp = TokenGGP(getContractAddress("TokenGGP"));
		// Get the vault contract instance
		Vault vault = Vault(getContractAddress("Vault"));
		// Get the start of the last claim interval as this may have just changed for a new interval beginning
		uint256 claimIntervalTimeStart = getClaimIntervalTimeStart();
		uint256 claimIntervalTimeStartComputed = _getClaimIntervalTimeStartComputed(claimIntervalTimeStart, claimIntervalTime);
		uint256 claimIntervalsPassed = _getClaimIntervalsPassed(claimIntervalTimeStart, claimIntervalTime);

		// Is this the first claim of this interval? If so, set the rewards total for this interval
		if (claimIntervalsPassed > 0) {
			// Mint any new tokens from GGP inflation
			inflationMintTokens();
			// Set this as the start of the new claim interval
			setUint(keccak256("rewards.pool.claim.interval.time.start"), claimIntervalTimeStartComputed);
			// Soon as we mint new tokens, send the DAO's share to it's claiming contract, then attempt to transfer them to the dao if possible
			uint256 daoClaimContractAllowance = getClaimingContractAllowance("ProtocolDAOClaim");

			// Are we sending any?
			if (daoClaimContractAllowance > 0) {
				// address daoClaimContractAddress = getContractAddress("ProtocolDAOClaim");

				// Transfers the DAO's tokens to it's claiming contract from the rewards pool
				vault.transferToken("ProtocolDAOClaim", ggp, daoClaimContractAllowance);

				// Set the current claim percentage this contract is entitled to for this interval
				setUint(
					keccak256(abi.encodePacked("rewards.pool.claim.interval.contract.perc.current", "ProtocolDAOClaim")),
					getClaimingContractPerc("ProtocolDAOClaim")
				);
				// Store the total GGP rewards claim for this claiming contract in this interval
				setUint(
					keccak256(abi.encodePacked("rewards.pool.claim.interval.contract.total", claimIntervalTimeStartComputed, "ProtocolDAOClaim")),
					_getClaimingContractTotalClaimed("ProtocolDAOClaim", claimIntervalTimeStartComputed) + (daoClaimContractAllowance)
				);
				// Log it
				// emit RPLTokensClaimed(daoClaimContractAddress, daoClaimContractAddress, daoClaimContractAllowance, block.timestamp);
			}
		}
		// Has anyone claimed from this contract so far in this interval? If not then set the interval settings for the contract
		if (_getClaimingContractTotalClaimed(contractName, claimIntervalTimeStartComputed) == 0) {
			// Get the amount allocated to this claim contract
			uint256 claimContractAllowance = getClaimingContractAllowance(contractName);
			// Make sure this is ok
			require(claimContractAllowance > 0, "Claiming contract must have an allowance of more than 0");
			// Set the current claim percentage this contract is entitled too for this interval
			setUint(keccak256(abi.encodePacked("rewards.pool.claim.interval.contract.perc.current", contractName)), getClaimingContractPerc(contractName));
			// Set the current claim allowance amount for this contract for this claim interval (if the claim amount is changed, it will kick in on the next interval)
			setUint(keccak256(abi.encodePacked("rewards.pool.claim.interval.contract.allowance", contractName)), claimContractAllowance);
			// Set the current amount of claimers for this interval
			setUint(
				keccak256(abi.encodePacked("rewards.pool.claim.interval.claimers.total.current", contractName)),
				getClaimingContractUserTotalNext(contractName)
			);
		}
		// Check if they have a valid claim amount
		uint256 claimingContractTotalClaimed = _getClaimingContractTotalClaimed(contractName, claimIntervalTimeStartComputed);
		uint256 claimAmount = _getClaimAmount(
			contractName,
			_claimerAddress,
			_claimerAmountPerc,
			claimIntervalTimeStartComputed,
			claimingContractTotalClaimed
		);

		// First initial checks
		require(
			claimAmount > 0,
			"Claimer is not entitled to tokens, they have already claimed in this interval or they are claiming more rewards than available to this claiming contract."
		);
		// Send tokens now
		vault.withdrawToken(_toAddress, ggp, claimAmount);
		// Store the claiming record for this interval and claiming contract
		setBool(
			keccak256(abi.encodePacked("rewards.pool.claim.interval.claimer.address", claimIntervalTimeStartComputed, contractName, _claimerAddress)),
			true
		);
		// Store the total GGP rewards claim for this claiming contract in this interval
		setUint(
			keccak256(abi.encodePacked("rewards.pool.claim.interval.contract.total", claimIntervalTimeStartComputed, contractName)),
			claimingContractTotalClaimed + claimAmount
		);
		// Store the last time a claim was made
		setUint(keccak256("rewards.pool.claim.interval.time.last"), block.timestamp);
		// Log it
		// emit RPLTokensClaimed(getContractAddress(contractName), _claimerAddress, claimAmount, block.timestamp);
	}
}
