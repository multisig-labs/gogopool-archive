// SPDX-License-Identifier: MIT
// Copied from https://github.com/fei-protocol/ERC4626/blob/main/src/xERC4626.sol
// Rewards logic inspired by xERC20 (https://github.com/ZeframLou/playpen/blob/main/src/xERC20.sol)

pragma solidity ^0.8.13;

import {ProtocolDAO} from "../dao/ProtocolDAO.sol";
import {BaseUpgradeable} from "../BaseUpgradeable.sol";

import {ERC20Upgradeable} from "./upgradeable/ERC20Upgradeable.sol";
import {ERC4626Upgradeable} from "./upgradeable/ERC4626Upgradeable.sol";

import {IStorage} from "../../interface/IStorage.sol";
import {IWAVAX} from "../../interface/IWAVAX.sol";
import {IWithdrawer} from "../../interface/IWithdrawer.sol";

import {ERC20, ERC4626} from "@rari-capital/solmate/src/mixins/ERC4626.sol";
import {SafeCastLib} from "@rari-capital/solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "@rari-capital/solmate/src/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

// [GGP] Notes
/*
	This contract **MUST** be deployed behind a proxy https://docs.openzeppelin.com/contracts/4.x/api/proxy#TransparentUpgradeableProxy
	This will enable the token addr to stay the same but still allow upgrades to this contract.

	TODO figure out how the storage layout for proxys work. We need to make sure we never change the order of the inherited
	contracts, and also we cant change the order (or delete) any storage variables in this contract. We should probably put them
	all at the top with a warning.
	TODO Dont think you can have constructor with the proxys? Need a "setup" func instead?
*/

contract TokenggAVAX is ERC20Upgradeable, ERC4626Upgradeable, BaseUpgradeable, Initializable, UUPSUpgradeable, OwnableUpgradeable {
	using SafeTransferLib for ERC20;
	using SafeTransferLib for address;
	using SafeCastLib for *;
	using FixedPointMathLib for uint256;

	/// @dev thrown when syncing before cycle ends.
	error SyncError();
	error ZeroShares();
	error WithdrawAmountTooLarge();
	error TodoBetterMsg();

	/// @dev emit every time a new rewards cycle starts
	event NewRewardsCycle(uint32 indexed cycleEnd, uint256 rewardAmount);

	/// @notice the amount of avax removed for staking by a multisig
	event WithdrawForStaking(address indexed caller, uint256 assets);

	/// @notice the amount of (non-rewards) avax deposited from staking by a multisig
	event DepositFromStaking(address indexed caller, uint256 baseAmt, uint256 rewardAmt);

	/// @notice the maximum length of a rewards cycle
	uint32 public rewardsCycleLength;

	/// @notice the effective start of the current cycle
	uint32 public lastSync;

	/// @notice the end of the current cycle. Will always be evenly divisible by `rewardsCycleLength`.
	uint32 public rewardsCycleEnd;

	/// @notice the amount of rewards distributed in a the most recent cycle.
	uint192 public lastRewardAmount;

	/// @notice the total amount of avax (including avax sent out for staking and all incoming rewards)
	uint256 public totalReleasedAssets;

	// Total amount of avax currently out for staking (not including any rewards)
	uint256 public stakingTotalAssets;

	/// @custom:oz-upgrades-unsafe-allow constructor
	constructor() {
		/*
	  	Since the constructor is executed only when creating the
	  	implementation contract, prevent its re-initialization.
	  */
		_disableInitializers();
	}

	function initialize(IStorage storageAddress, ERC20 asset) public initializer {
		__ERC4626Upgradeable_init(asset, "GoGoPool Liquid Staking Token", "ggAVAX");
		__BaseUpgradeable_init(storageAddress);
		__Ownable_init();
		__UUPSUpgradeable_init();

		// make this a setting, should I set this from the settings or from the constructor
		rewardsCycleLength = 14 days;
		// seed initial rewardsCycleEnd
		rewardsCycleEnd = (block.timestamp.safeCastTo32() / rewardsCycleLength) * rewardsCycleLength;
	}

	// TODO got this from Pangolin, probably shouldnt accept any avax outside of a deposit?
	receive() external payable {
		assert(msg.sender == address(asset)); // only accept AVAX via fallback from the WAVAX contract
	}

	// TODO In addition to the ERC4626 which has deposit()/redeem() for WAVAX, we
	// also add the ability to deposit/redeem raw AVAX. If we add any modifiers (pauseable?) make sure we also
	// add them to the ERC4626 by overriding here and calling super()?

	// Accept raw AVAX from a depositor and mint them ggAVAX
	// TODO allow DAO to pause?
	function depositAVAX() public payable returns (uint256 shares) {
		uint256 assets = msg.value;
		// Check for rounding error since we round down in previewDeposit.
		if ((shares = previewDeposit(assets)) == 0) {
			revert ZeroShares();
		}
		IWAVAX(address(asset)).deposit{value: assets}();
		_mint(msg.sender, shares);
		emit Deposit(msg.sender, msg.sender, assets, shares);
		afterDeposit(assets, shares);
	}

	// Allow depositor to burn ggAVAX and withdraw raw AVAX (subject to reserves)
	// TODO allow DAO to pause?
	// TODO most people will want to redeem shares, not withdraw avax, right? So can we rm this method?
	function withdrawAVAX(uint256 assets) public returns (uint256 shares) {
		shares = previewWithdraw(assets); // No need to check for rounding error, previewWithdraw rounds up.
		beforeWithdraw(assets, shares);
		_burn(msg.sender, shares);
		emit Withdraw(msg.sender, msg.sender, msg.sender, assets, shares);
		IWAVAX(address(asset)).withdraw(assets);
		// TODO will this work for smart contract wallets? like a gnosis multisig?
		msg.sender.safeTransferETH(assets);
	}

	// Allow depositor to burn ggAVAX and withdraw raw AVAX (subject to reserves)
	// TODO allow DAO to pause?
	function redeemAVAX(uint256 shares) public returns (uint256 assets) {
		// Check for rounding error since we round down in previewRedeem.
		require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");
		beforeWithdraw(assets, shares);
		_burn(msg.sender, shares);
		emit Withdraw(msg.sender, msg.sender, msg.sender, assets, shares);
		IWAVAX(address(asset)).withdraw(assets);
		// TODO will this work for smart contract wallets? like a gnosis multisig?
		msg.sender.safeTransferETH(assets);
	}

	// TODO ONLY minipoolmanager and delegationManager? can call this, will xfer AVAX to msg.sender
	function withdrawForStaking(uint256 assets) public {
		if (assets > amountAvailableForStaking()) {
			revert WithdrawAmountTooLarge();
		}
		stakingTotalAssets += assets;
		emit WithdrawForStaking(msg.sender, assets);
		IWAVAX(address(asset)).withdraw(assets);
		IWithdrawer withdrawer = IWithdrawer(msg.sender);
		withdrawer.receiveWithdrawalAVAX{value: assets}();
	}

	// TODO ONLY minipoolmanager can call this, recvs avax from staking + rewards
	function depositFromStaking(uint256 baseAmt, uint256 rewardAmt) public payable {
		uint256 totalAmt = msg.value;
		if (totalAmt != (baseAmt + rewardAmt) || baseAmt > stakingTotalAssets) {
			revert TodoBetterMsg();
		}
		stakingTotalAssets -= baseAmt;
		IWAVAX(address(asset)).deposit{value: totalAmt}();
		emit DepositFromStaking(msg.sender, baseAmt, rewardAmt);
	}

	/*///////////////////////////////////////////////////////////////
                       TARGET FLOAT CONFIGURATION
    //////////////////////////////////////////////////////////////*/

	/// @notice The desired percentage of holdings to keep as float.
	/// @dev A fixed point number where 1e18 represents 100% and 0 represents 0%.
	uint256 public targetFloatPercent;

	/// @notice Emitted when the target float percentage is updated.
	/// @param user The authorized user who triggered the update.
	/// @param newTargetFloatPercent The new target float percentage.
	event TargetFloatPercentUpdated(address indexed user, uint256 newTargetFloatPercent);

	/// @notice Set a new target float percentage.
	/// @param newTargetFloatPercent The new target float percentage.
	// TODO who can call this fn? DAO?
	function setTargetFloatPercent(uint256 newTargetFloatPercent) external {
		// A target float percentage over 100% doesn't make sense.
		require(newTargetFloatPercent <= 1e18, "TARGET_TOO_HIGH");

		// Update the target float percentage.
		targetFloatPercent = newTargetFloatPercent;

		emit TargetFloatPercentUpdated(msg.sender, newTargetFloatPercent);
	}

	// TODO delete this everwhere and just use amountAvailableForStaking
	function totalFloat() public view returns (uint256) {
		return amountAvailableForStaking();
	}

	function amountAvailableForStaking() public view returns (uint256) {
		ProtocolDAO protocolDAO = ProtocolDAO(getContractAddress("ProtocolDAO"));
		uint256 targetCollateralRate = protocolDAO.getTargetggAVAXReserveRate();

		uint256 totalAssets_ = totalAssets();

		uint256 reservedAssets = totalAssets_.mulDivDown(targetCollateralRate, 1 ether);
		return totalAssets_ - reservedAssets;
	}

	// REWARDS SYNC LOGIC

	/// @notice Compute the amount of tokens available to share holders.
	///         Increases linearly during a reward distribution period from the sync call, not the cycle start.
	function totalAssets() public view override returns (uint256) {
		// cache global vars
		uint256 totalReleasedAssets_ = totalReleasedAssets;
		uint192 lastRewardAmount_ = lastRewardAmount;
		uint32 rewardsCycleEnd_ = rewardsCycleEnd;
		uint32 lastSync_ = lastSync;

		if (block.timestamp >= rewardsCycleEnd_) {
			// no rewards or rewards fully unlocked
			// entire reward amount is available
			return totalReleasedAssets_ + lastRewardAmount_;
		}

		// rewards not fully unlocked
		// add unlocked rewards to stored total
		uint256 unlockedRewards = (lastRewardAmount_ * (block.timestamp - lastSync_)) / (rewardsCycleEnd_ - lastSync_);
		return totalReleasedAssets_ + unlockedRewards;
	}

	// Update totalReleasedAssets on withdraw/redeem
	function beforeWithdraw(uint256 amount, uint256 shares) internal virtual override {
		super.beforeWithdraw(amount, shares);
		totalReleasedAssets -= amount;
	}

	// Update totalReleasedAssets on deposit/mint
	function afterDeposit(uint256 amount, uint256 shares) internal virtual override {
		totalReleasedAssets += amount;
		super.afterDeposit(amount, shares);
	}

	/// @notice Distributes rewards to xERC4626 holders.
	/// All surplus `asset` balance of the contract over the internal balance becomes queued for the next cycle.
	function syncRewards() public virtual {
		uint192 lastRewardAmount_ = lastRewardAmount;
		uint32 timestamp = block.timestamp.safeCastTo32();

		if (timestamp < rewardsCycleEnd) revert SyncError();

		uint256 totalReleasedAssets_ = totalReleasedAssets;
		uint256 stakingTotalAssets_ = stakingTotalAssets;
		uint256 nextRewards = (asset.balanceOf(address(this)) + stakingTotalAssets_) - totalReleasedAssets_ - lastRewardAmount_;

		totalReleasedAssets = totalReleasedAssets_ + lastRewardAmount_; // SSTORE

		uint32 end = timestamp + rewardsCycleLength;

		// Combined single SSTORE
		lastRewardAmount = nextRewards.safeCastTo192();
		lastSync = timestamp;
		rewardsCycleEnd = end;

		emit NewRewardsCycle(end, nextRewards);
	}

	function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
