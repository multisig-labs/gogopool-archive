pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import {Storage} from "./Storage.sol";
import {MinipoolManager} from "./MinipoolManager.sol";
import {Vault} from "./Vault.sol";
import {TokenGGP} from "./tokens/TokenGGP.sol";
import {SafeTransferLib} from "@rari-capital/solmate/src/utils/SafeTransferLib.sol";
import {Oracle} from "./Oracle.sol";
import {NOPClaim} from "./rewards/claims/NOPClaim.sol";

import {ERC20, ERC4626} from "@rari-capital/solmate/src/mixins/ERC4626.sol";
import "./Base.sol";

contract Staking is Base {
	using SafeTransferLib for ERC20;
	using SafeTransferLib for address;

	uint256 internal constant WAD = 1e18; // The scalar of ETH and most ERC20s.
	uint256 internal constant maxCollateralizationPercent = 150;
	uint256 internal constant minCollateralizationPercent = 10;

	ERC20 public immutable ggp;

	/// @notice This index does not exist
	error IndexNotFound();

	/// @notice Cannot Withdraw GGp if under 150% collateralization ratio
	error CannotWithdrawUnder150CollateralizationRatio();

	// Not used for storage, just for returning data from view functions
	struct User {
		uint256 totalGGPStaked;
		uint256 totalAvaxStaked;
		uint256 totalAvaxBorrowed;
		address walletAddress;
	}

	event GGPStaked(address indexed from, uint256 amount, uint256 time);
	event GGPWithdrawn(address indexed to, uint256 amount, uint256 time);
	event GGPSlashed(address indexed userWalletAddress, uint256 amount, uint256 avaxValue, uint256 time);

	constructor(Storage storageAddress, ERC20 _ggp) Base(storageAddress) {
		version = 1;
		ggp = _ggp;
	}

	function getTotalGGPStake() public view returns (uint256) {
		Vault vault = Vault(getContractAddress("Vault"));
		TokenGGP ggpToken = TokenGGP(getContractAddress("TokenGGP"));
		return vault.balanceOfToken("Staking", ggpToken);
	}

	/* USER'S GGP STAKE */
	function getUserGGPStake(address userWalletAddress) public view returns (uint256) {
		int256 index = requireValidIndex(userWalletAddress);
		return getUint(keccak256(abi.encodePacked("user.", index, ".totalGGPStaked")));
	}

	function increaseUserGGPStake(address userWalletAddress, uint256 amount) public {
		int256 index = requireValidIndex(userWalletAddress);
		addUint(keccak256(abi.encodePacked("user.", index, ".totalGGPStaked")), amount);
	}

	function decreaseUserGGPStake(address userWalletAddress, uint256 amount) public {
		int256 index = requireValidIndex(userWalletAddress);
		subUint(keccak256(abi.encodePacked("user.", index, ".totalGGPStaked")), amount);
	}

	/* AVAX STAKE */
	function getUserAvaxStake(address userWalletAddress) public view returns (uint256) {
		int256 index = requireValidIndex(userWalletAddress);
		return getUint(keccak256(abi.encodePacked("user.", index, ".totalAvaxStaked")));
	}

	function increaseUserAvaxStake(address userWalletAddress, uint256 amount) public {
		int256 index = requireValidIndex(userWalletAddress);
		addUint(keccak256(abi.encodePacked("user.", index, ".totalAvaxStaked")), amount);
	}

	function decreaseUserAvaxStake(address userWalletAddress, uint256 amount) public {
		int256 index = requireValidIndex(userWalletAddress);
		subUint(keccak256(abi.encodePacked("user.", index, ".totalAvaxStaked")), amount);
	}

	/* AVAX BORROWED */
	function getUserAvaxBorrowed(address userWalletAddress) public view returns (uint256) {
		int256 index = requireValidIndex(userWalletAddress);
		return getUint(keccak256(abi.encodePacked("user.", index, ".totalAvaxBorrowed")));
	}

	function increaseUserAvaxBorrowed(address userWalletAddress, uint256 amount) public {
		int256 index = requireValidIndex(userWalletAddress);
		addUint(keccak256(abi.encodePacked("user.", index, ".totalAvaxBorrowed")), amount);
	}

	function decreaseUserAvaxBorrowed(address userWalletAddress, uint256 amount) public {
		int256 index = requireValidIndex(userWalletAddress);
		subUint(keccak256(abi.encodePacked("user.", index, ".totalAvaxBorrowed")), amount);
	}

	/* WALLET ADDRESS */
	function getUserrWalletAddress(address userWalletAddress) public view returns (address) {
		int256 index = requireValidIndex(userWalletAddress);
		return getAddress(keccak256(abi.encodePacked("user.", index, ".walletAddress")));
	}

	// Get a user's minimum ggp stake to collateralize their minipools. Returned in GGP
	function getUserMinimumGGPStake(address userWalletAddress) external view returns (uint256) {
		Oracle oracle = Oracle(getContractAddress("Oracle"));
		(uint256 ggpPriceInAvax, ) = oracle.getGGPPrice();

		return getUserAvaxBorrowed(userWalletAddress) / ggpPriceInAvax / minCollateralizationPercent;
	}

	// Get a User's amount of ggp staked up until 150% of avax borrowed
	function getUserEffectiveGGPStake(address userWalletAddress) public view returns (uint256) {
		// TODO include the DelegationManager inside of this to count up how much avax (if any) the user put up thru the DM?
		// ^ not sure if this is a thing
		Oracle oracle = Oracle(getContractAddress("Oracle"));
		(uint256 ggpPriceInAvax, ) = oracle.getGGPPrice();

		uint256 userGGPStaked = getUserGGPStake(userWalletAddress);
		uint256 userGGPStakedInAvax = userGGPStaked * ggpPriceInAvax;
		uint256 userAvaxBorrowed = getUserAvaxBorrowed(userWalletAddress);
		uint256 ggpToAvaxBorrowedPercent = (userGGPStakedInAvax / userAvaxBorrowed) * 100;

		if (ggpToAvaxBorrowedPercent > maxCollateralizationPercent) {
			//calculate 150 percent of the ggpStaked
			uint256 userEffectiveGGPStakeInAvax = (maxCollateralizationPercent * userAvaxBorrowed) / 100;
			//return the effective stake back in ggp
			return userEffectiveGGPStakeInAvax / ggpPriceInAvax;
		} else {
			return userGGPStaked;
		}
	}

	// Get the protocol's amount of ggp staked up until 150% of avax borrowed
	function getTotalEffectiveGGPStake() external view returns (uint256) {
		MinipoolManager minipoolManager = MinipoolManager(getContractAddress("MinipoolManager"));
		uint256 totalAvaxBorrowed = minipoolManager.getTotalAvaxLiquidStakerAmt();

		Oracle oracle = Oracle(getContractAddress("Oracle"));
		(uint256 ggpPriceInAvax, ) = oracle.getGGPPrice();

		//check valut for the ggp under staking contract
		uint256 totalGGPStaked = getTotalGGPStake();
		uint256 totalGGPStakedInAvax = totalGGPStaked * ggpPriceInAvax;

		uint256 ggpToAvaxBorrowedPercent = (totalGGPStakedInAvax / totalAvaxBorrowed) * 100;

		if (ggpToAvaxBorrowedPercent > maxCollateralizationPercent) {
			//calculate 150 percent of the ggpStaked
			uint256 userEffectiveGGPStakeInAvax = (maxCollateralizationPercent * totalAvaxBorrowed) / 100;
			//return the effective stake back in ggp
			return userEffectiveGGPStakeInAvax / ggpPriceInAvax;
		} else {
			return totalGGPStaked;
		}
	}

	// Accept a GGP stake
	// user must approve the transfer request for amount first
	function stakeGGP(uint256 amount) external {
		// Load contracts
		Vault vault = Vault(getContractAddress("Vault"));

		// Transfer GGP tokens
		require(ggp.transferFrom(msg.sender, address(this), amount), "Could not transfer GGP to staking contract");

		// Deposit GGP tokens to vault
		require(ggp.approve(address(vault), amount), "Could not approve vault GGP deposit");
		vault.depositToken("Staking", ggp, amount);

		// If user exists, add to the existing stake. If it doesnt, set the stake and time.
		// getIndexOf returns -1 if node does not exist, so have to use signed type int256 here
		int256 index = getIndexOf(msg.sender);
		if (index != -1) {
			// add to the staked amt
			increaseUserGGPStake(msg.sender, amount);
			//TODO: something with stakedTime value?
		} else {
			//create index for the user
			index = int256(getUint(keccak256("user.count")));
			//set the totalGGPStaked amt
			setUint(keccak256(abi.encodePacked("user.", index, ".totalGGPStaked")), amount);
			setAddress(keccak256(abi.encodePacked("user.item", index, ".walletAddress")), msg.sender);

			// NOTE the index is actually 1 more than where it is actually stored. The 1 is subtracted in getIndexOf().
			// Copied from RP, probably so they can use "-1" to signify that something doesnt exist
			setUint(keccak256(abi.encodePacked("user.index", msg.sender)), uint256(index + 1));
			addUint(keccak256("user.count"), 1);
		}

		// Emit GGP staked event
		emit GGPStaked(msg.sender, amount, block.timestamp);
	}

	function withdrawGGP(uint256 amount) external {
		Vault vault = Vault(getContractAddress("Vault"));

		uint256 effectiveGGPStake = getUserEffectiveGGPStake(msg.sender);
		uint256 totalGGPStake = getUserGGPStake(msg.sender);

		if (effectiveGGPStake < totalGGPStake) {
			uint256 withdrawableGGPAmt = totalGGPStake - effectiveGGPStake;
			vault.withdrawToken(msg.sender, ggp, withdrawableGGPAmt);
		} else {
			revert CannotWithdrawUnder150CollateralizationRatio();
		}
	}

	function requireValidIndex(address userWalletAddress) public view returns (int256) {
		int256 index = getIndexOf(userWalletAddress);
		if (index != -1) {
			return index;
		} else {
			revert IndexNotFound();
		}
	}

	// The index of an item
	// Returns -1 if the value is not found
	function getIndexOf(address userWalletAddress) public view returns (int256) {
		return int256(getUint(keccak256(abi.encodePacked("user.index", userWalletAddress)))) - 1;
	}

	//Minipool Manager will call this if a minipool ended and was not in good standing
	function slashGGP(address userWalletAddress, uint256 amount) public {
		decreaseUserGGPStake(userWalletAddress, amount);
		Oracle oracle = Oracle(getContractAddress("Oracle"));
		(uint256 ggpPriceInAvax, ) = oracle.getGGPPrice();
		uint256 amtInAvax = amount / ggpPriceInAvax;
		emit GGPSlashed(userWalletAddress, amount, amtInAvax, block.timestamp);
	}

	function getUser(int256 index) public view returns (User memory user) {
		user.totalGGPStaked = getUint(keccak256(abi.encodePacked("user.", index, ".totalGGPStaked")));
		user.totalAvaxBorrowed = getUint(keccak256(abi.encodePacked("user.", index, ".totalAvaxBorrowed")));
		user.totalAvaxStaked = getUint(keccak256(abi.encodePacked("user.", index, ".totalAvaxStaked")));
		user.walletAddress = getAddress(keccak256(abi.encodePacked("user.", index, ".walletAddress")));
	}
}
