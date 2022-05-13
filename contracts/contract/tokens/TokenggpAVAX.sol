// SPDX-License-Identifier: MIT
// Copied from https://github.com/fei-protocol/ERC4626/blob/main/src/xERC4626.sol
// Rewards logic inspired by xERC20 (https://github.com/ZeframLou/playpen/blob/main/src/xERC20.sol)

pragma solidity ^0.8.0;

import {ERC20, ERC4626} from "@rari-capital/solmate/src/mixins/ERC4626.sol";
import {SafeCastLib} from "@rari-capital/solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "@rari-capital/solmate/src/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";

import {IWAVAX} from "../../interface/IWAVAX.sol";
import "../Base.sol";

// [GGP] Notes
/*
	This contract **MUST** be deployed behind a proxy https://docs.openzeppelin.com/contracts/4.x/api/proxy#TransparentUpgradeableProxy
	This will enable the token addr to stay the same but still allow upgrades to this contract.

	TODO figure out how the storage layout for proxys work. We need to make sure we never change the order of the inherited
	contracts, and also we cant change the order (or delete) any storage variables in this contract. We should probably put them
	all at the top with a warning.
	TODO Dont think you can have constructor with the proxys? Need a "setup" func instead?
*/

contract TokenggpAVAX is Base, ERC20, ERC4626 {
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

	/// @notice the amount of avax rewards deposited by a multisig
	event DepositRewards(address indexed caller, uint256 assets);

	/// @notice the amount of avax removed for staking by a multisig
	event WithdrawForStaking(address indexed caller, uint256 assets);

	/// @notice the amount of (non-rewards) avax deposited from staking by a multisig
	event DepositFromStaking(address indexed caller, uint256 assets);

	/// @notice the maximum length of a rewards cycle
	uint32 public rewardsCycleLength;

	/// @notice the effective start of the current cycle
	uint32 public lastSync;

	/// @notice the end of the current cycle. Will always be evenly divisible by `rewardsCycleLength`.
	uint32 public rewardsCycleEnd;

	/// @notice the amount of rewards distributed in a the most recent cycle.
	uint192 public lastRewardAmount;

	/// @notice the total amount of avax (including avax sent out for staking and all incoming rewards)
	uint256 public networkTotalAssets;

	// Total amount of avax currently out for staking (not including any rewards)
	uint256 public stakingTotalAssets;

	constructor(Storage storageAddress, ERC20 asset) Base(storageAddress) ERC4626(asset, "GoGoPool Liquid Staking Token", "ggpAVAX") {
		version = 1; // for storage
		// TODO get this value from storage instead of constructor? DAO decides the cycle? Can it change?
		rewardsCycleLength = 1 days;
		// seed initial rewardsCycleEnd
		rewardsCycleEnd = (block.timestamp.safeCastTo32() / rewardsCycleLength) * rewardsCycleLength;
		targetFloatPercent = 1e17; // 1e18 * 10%;
	}

	// TODO got this from Pangolin, probably shouldnt accept any avax outside of a deposit?
	receive() external payable {
		assert(msg.sender == address(asset)); // only accept AVAX via fallback from the WAVAX contract
	}

	// Accept raw AVAX from a depositor and mint them ggpAVAX
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

	// Allow depositor to burn ggpAVAX and withdraw raw AVAX (subject to reserves)
	// TODO allow DAO to pause?
	function withdrawAVAX(uint256 assets) public returns (uint256 shares) {
		shares = previewWithdraw(assets); // No need to check for rounding error, previewWithdraw rounds up.
		beforeWithdraw(assets, shares);
		_burn(msg.sender, shares);
		emit Withdraw(msg.sender, msg.sender, msg.sender, assets, shares);
		IWAVAX(address(asset)).withdraw(assets);
		msg.sender.safeTransferETH(assets);
	}

	// TODO Withdraw excess to Vault
	function withdrawForStaking(uint256 assets) public {
		if (assets > amountAvailableForStaking()) {
			revert WithdrawAmountTooLarge();
		}
		// TODO allow only multisigs to call
		IWAVAX(address(asset)).withdraw(assets);
		msg.sender.safeTransferETH(assets);
		emit WithdrawForStaking(msg.sender, assets);
		stakingTotalAssets += assets;
	}

	// Accept raw AVAX deposits from Rialto.
	// Must ONLY be the rewards amount.
	// TODO maybe have sanity check to not allow deposit of more than approx rewards expected?
	function depositRewards() public payable {
		uint256 assets = msg.value;
		// Convert avax to wavax (wavax will be owned by this contract not the depositor)
		IWAVAX(address(asset)).deposit{value: assets}();
		// We DONT mint since we are depositing rewards to be shared by all
		// _mint(receiver, shares);
		emit DepositRewards(msg.sender, assets);
		// DONT call this either, we ONLY want to increase the balance
		// afterDeposit(assets, 0);
	}

	// Must ONLY be any amounts returned from base staking NOT any rewards
	function depositFromStaking() public payable {
		uint256 assets = msg.value;
		if (assets > stakingTotalAssets) {
			revert TodoBetterMsg();
		}
		stakingTotalAssets -= assets;

		// Convert avax to wavax (wavax will be owned by this contract not the depositor)
		IWAVAX(address(asset)).deposit{value: assets}();
		// We DONT mint since we are just replacing what we removed
		// _mint(receiver, shares);
		emit DepositFromStaking(msg.sender, assets);
		// DONT call this either, we ONLY want to increase the balance
		// afterDeposit(assets, 0);
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

	/// @notice Returns the amount of WAVAX that sit idle in this contract.
	/// @return The amount of WAVAX that sit idle in the contract.
	function totalFloat() public view returns (uint256) {
		return asset.balanceOf(address(this));
	}

	function amountAvailableForStaking() public view returns (uint256) {
		uint256 targetAmount = networkTotalAssets.mulDivDown(1, 100000);
		return targetAmount;
	}

	// REWARDS SYNC LOGIC

	/// @notice Compute the amount of tokens available to share holders.
	///         Increases linearly during a reward distribution period from the sync call, not the cycle start.
	function totalAssets() public view override returns (uint256) {
		// cache global vars
		uint256 networkTotalAssets_ = networkTotalAssets;
		uint192 lastRewardAmount_ = lastRewardAmount;
		uint32 rewardsCycleEnd_ = rewardsCycleEnd;
		uint32 lastSync_ = lastSync;

		if (block.timestamp >= rewardsCycleEnd_) {
			// no rewards or rewards fully unlocked
			// entire reward amount is available
			return networkTotalAssets_ + lastRewardAmount_;
		}

		// rewards not fully unlocked
		// add unlocked rewards to stored total
		uint256 unlockedRewards = (lastRewardAmount_ * (block.timestamp - lastSync_)) / (rewardsCycleEnd_ - lastSync_);
		return networkTotalAssets_ + unlockedRewards;
	}

	// Update networkTotalAssets on withdraw/redeem
	function beforeWithdraw(uint256 amount, uint256 shares) internal virtual override {
		super.beforeWithdraw(amount, shares);
		networkTotalAssets -= amount;
	}

	// Update networkTotalAssets on deposit/mint
	function afterDeposit(uint256 amount, uint256 shares) internal virtual override {
		networkTotalAssets += amount;
		super.afterDeposit(amount, shares);
	}

	/// @notice Distributes rewards to xERC4626 holders.
	/// All surplus `asset` balance of the contract over the internal balance becomes queued for the next cycle.
	function syncRewards() public virtual {
		uint192 lastRewardAmount_ = lastRewardAmount;
		uint32 timestamp = block.timestamp.safeCastTo32();

		if (timestamp < rewardsCycleEnd) revert SyncError();

		uint256 networkTotalAssets_ = networkTotalAssets;
		uint256 nextRewards = asset.balanceOf(address(this)) - networkTotalAssets_ - lastRewardAmount_;

		networkTotalAssets = networkTotalAssets_ + lastRewardAmount_; // SSTORE

		uint32 end = ((timestamp + rewardsCycleLength) / rewardsCycleLength) * rewardsCycleLength;

		// Combined single SSTORE
		lastRewardAmount = nextRewards.safeCastTo192();
		lastSync = timestamp;
		rewardsCycleEnd = end;

		emit NewRewardsCycle(end, nextRewards);
	}
}
