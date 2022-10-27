// SPDX-License-Identifier: GPL-3.0-only
// Copied from https://github.com/fei-protocol/ERC4626/blob/main/src/xERC4626.sol
// Rewards logic inspired by xERC20 (https://github.com/ZeframLou/playpen/blob/main/src/xERC20.sol)
pragma solidity 0.8.17;

import "../BaseUpgradeable.sol";
import {Storage} from "../Storage.sol";
import {ProtocolDAO} from "../dao/ProtocolDAO.sol";

import {IWAVAX} from "../../interface/IWAVAX.sol";
import {IWithdrawer} from "../../interface/IWithdrawer.sol";

import {ERC20, ERC4626} from "@rari-capital/solmate/src/mixins/ERC4626.sol";
import {SafeCastLib} from "@rari-capital/solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "@rari-capital/solmate/src/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";

import {ERC20Upgradeable} from "./upgradeable/ERC20Upgradeable.sol";
import {ERC4626Upgradeable} from "./upgradeable/ERC4626Upgradeable.sol";
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
	event NewRewardsCycle(uint256 indexed cycleEnd, uint256 rewardsAmount);

	/// @notice the amount of avax removed for staking by a multisig
	event WithdrawForStaking(address indexed caller, uint256 assets);

	/// @notice the amount of (non-rewards) avax deposited from staking by a multisig
	event DepositFromStaking(address indexed caller, uint256 baseAmt, uint256 rewardsAmt);

	/// @notice the effective start of the current cycle
	uint32 public lastSync;

	/// @notice the maximum length of a rewards cycle
	uint32 public rewardsCycleLength;

	/// @notice the end of the current cycle. Will always be evenly divisible by `rewardsCycleLength`.
	uint32 public rewardsCycleEnd;

	/// @notice the amount of rewards distributed in a the most recent cycle.
	uint192 public lastRewardsAmount;

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

	function initialize(Storage storageAddress, ERC20 asset) public initializer {
		__ERC4626Upgradeable_init(asset, "GoGoPool Liquid Staking Token", "ggAVAX");
		__BaseUpgradeable_init(storageAddress);
		__Ownable_init();
		__UUPSUpgradeable_init();

		rewardsCycleLength = 14 days;

		// seed initial rewardsCycleEnd
		rewardsCycleEnd = (block.timestamp.safeCastTo32() / rewardsCycleLength) * rewardsCycleLength;
	}

	// TODO got this from Pangolin, probably shouldnt accept any avax outside of a deposit?
	receive() external payable {
		assert(msg.sender == address(asset)); // only accept AVAX via fallback from the WAVAX contract
	}

	// REWARDS SYNC LOGIC

	/// @notice Distributes rewards to xERC4626 holders.
	/// All surplus `asset` balance of the contract over the internal balance becomes queued for the next cycle.
	function syncRewards() public {
		uint192 lastRewardsAmount_ = lastRewardsAmount;
		uint32 timestamp = block.timestamp.safeCastTo32();

		if (timestamp < rewardsCycleEnd) revert SyncError();

		uint256 totalReleasedAssets_ = totalReleasedAssets;
		uint256 stakingTotalAssets_ = stakingTotalAssets;
		uint256 nextRewards = (asset.balanceOf(address(this)) + stakingTotalAssets_) - totalReleasedAssets_ - lastRewardsAmount_;

		totalReleasedAssets = totalReleasedAssets_ + lastRewardsAmount_; // SSTORE

		uint32 end = timestamp + rewardsCycleLength;

		// Combined single SSTORE
		lastRewardsAmount = nextRewards.safeCastTo192();
		lastSync = timestamp;
		rewardsCycleEnd = end;

		emit NewRewardsCycle(end, nextRewards);
	}

	/// @notice Compute the amount of tokens available to share holders.
	///         Increases linearly during a reward distribution period from the sync call, not the cycle start.
	function totalAssets() public view override returns (uint256) {
		// cache global vars
		uint256 totalReleasedAssets_ = totalReleasedAssets;
		uint192 lastRewardsAmount_ = lastRewardsAmount;
		uint32 rewardsCycleEnd_ = rewardsCycleEnd;
		uint32 lastSync_ = lastSync;

		if (block.timestamp >= rewardsCycleEnd_) {
			// no rewards or rewards fully unlocked
			// entire reward amount is available
			return totalReleasedAssets_ + lastRewardsAmount_;
		}

		// rewards not fully unlocked
		// add unlocked rewards to stored total
		uint256 unlockedRewards = (lastRewardsAmount_ * (block.timestamp - lastSync_)) / (rewardsCycleEnd_ - lastSync_);
		return totalReleasedAssets_ + unlockedRewards;
	}

	// TODO delete this everwhere and just use amountAvailableForStaking
	function totalFloat() public view returns (uint256) {
		return amountAvailableForStaking();
	}

	function amountAvailableForStaking() public view returns (uint256) {
		ProtocolDAO protocolDAO = ProtocolDAO(getContractAddress("ProtocolDAO"));
		uint256 targetCollateralRate = protocolDAO.getTargetGGAVAXReserveRate();

		uint256 totalAssets_ = totalAssets();

		uint256 reservedAssets = totalAssets_.mulDivDown(targetCollateralRate, 1 ether);
		return totalAssets_ - reservedAssets - stakingTotalAssets;
	}

	function depositFromStaking(uint256 baseAmt, uint256 rewardAmt) public payable onlyLatestContract("MinipoolManager", msg.sender) {
		uint256 totalAmt = msg.value;
		if (totalAmt != (baseAmt + rewardAmt) || baseAmt > stakingTotalAssets) {
			revert TodoBetterMsg();
		}
		stakingTotalAssets -= baseAmt;
		IWAVAX(address(asset)).deposit{value: totalAmt}();
		emit DepositFromStaking(msg.sender, baseAmt, rewardAmt);
	}

	function withdrawForStaking(uint256 assets) public onlyLatestContract("MinipoolManager", msg.sender) {
		if (assets > amountAvailableForStaking()) {
			revert WithdrawAmountTooLarge();
		}
		stakingTotalAssets += assets;
		emit WithdrawForStaking(msg.sender, assets);
		IWAVAX(address(asset)).withdraw(assets);
		IWithdrawer withdrawer = IWithdrawer(msg.sender);
		withdrawer.receiveWithdrawalAVAX{value: assets}();
	}

	// Accept raw AVAX from a depositor and mint them ggAVAX
	function depositAVAX() public payable whenNotPaused returns (uint256 shares) {
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
	// TODO most people will want to redeem shares, not withdraw avax, right? So can we rm this method?
	function withdrawAVAX(uint256 assets) public whenNotPaused returns (uint256 shares) {
		shares = previewWithdraw(assets); // No need to check for rounding error, previewWithdraw rounds up.
		beforeWithdraw(assets, shares);
		_burn(msg.sender, shares);
		emit Withdraw(msg.sender, msg.sender, msg.sender, assets, shares);
		IWAVAX(address(asset)).withdraw(assets);
		// TODO will this work for smart contract wallets? like a gnosis multisig?
		msg.sender.safeTransferETH(assets);
	}

	// Allow depositor to burn ggAVAX and withdraw raw AVAX (subject to reserves)
	function redeemAVAX(uint256 shares) public whenNotPaused returns (uint256 assets) {
		// Check for rounding error since we round down in previewRedeem.
		require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");
		beforeWithdraw(assets, shares);
		_burn(msg.sender, shares);
		emit Withdraw(msg.sender, msg.sender, msg.sender, assets, shares);
		IWAVAX(address(asset)).withdraw(assets);
		// TODO will this work for smart contract wallets? like a gnosis multisig?
		msg.sender.safeTransferETH(assets);
	}

	// ERC4626 Overrides

	function deposit(uint256 assets, address receiver) public override whenNotPaused returns (uint256 shares) {
		return super.deposit(assets, receiver);
	}

	function mint(uint256 shares, address receiver) public override whenNotPaused returns (uint256 assets) {
		return super.mint(shares, receiver);
	}

	function withdraw(
		uint256 assets,
		address receiver,
		address owner
	) public override whenNotPaused returns (uint256 shares) {
		return super.withdraw(assets, receiver, owner);
	}

	function redeem(
		uint256 shares,
		address receiver,
		address owner
	) public override whenNotPaused returns (uint256 assets) {
		return super.redeem(shares, receiver, owner);
	}

	// Update totalReleasedAssets on withdraw/redeem
	function beforeWithdraw(uint256 amount, uint256 shares) internal override {
		super.beforeWithdraw(amount, shares);
		totalReleasedAssets -= amount;
	}

	// Update totalReleasedAssets on deposit/mint
	function afterDeposit(uint256 amount, uint256 shares) internal override {
		totalReleasedAssets += amount;
		super.afterDeposit(amount, shares);
	}

	function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
