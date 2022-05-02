// SPDX-License-Identifier: MIT
// Copied from https://github.com/fei-protocol/ERC4626/blob/main/src/xERC4626.sol
// Rewards logic inspired by xERC20 (https://github.com/ZeframLou/playpen/blob/main/src/xERC20.sol)

pragma solidity ^0.8.0;

import {ERC20, ERC4626} from "@rari-capital/solmate/src/mixins/ERC4626.sol";
import {SafeCastLib} from "@rari-capital/solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "@rari-capital/solmate/src/utils/SafeTransferLib.sol";

import {IWAVAX} from "../../interface/IWAVAX.sol";
import "../Base.sol";

// [GGP] Notes
/*
	Interesting technique to prevent user from sending to this token addr by accident: https://github.com/element-fi/council/blob/13b02be0f7/contracts/libraries/ERC20Permit.sol#L45

	From https://github.com/pangolindex/exchange-contracts/blob/main/contracts/pangolin-periphery/PangolinRouter.sol#L28
	address public immutable override WAVAX;
	constructor(address _factory, address _WAVAX) public {
			factory = _factory;
			WAVAX = _WAVAX;
	}
	receive() external payable {
			assert(msg.sender == WAVAX); // only accept AVAX via fallback from the WAVAX contract
	}
	function addLiquidityAVAX( ... ) external payable
		IWAVAX(WAVAX).deposit{value: amountAVAX}();
		assert(IWAVAX(WAVAX).transfer(pair, amountAVAX));
	also
	IWAVAX(WAVAX).withdraw(amounts[amounts.length - 1]);
	TransferHelper.safeTransferAVAX(to, amounts[amounts.length - 1]);

	function safeTransferAVAX(address to, uint256 value) internal {
			(bool success, ) = to.call{value: value}(new bytes(0));
			require(success, 'TransferHelper: AVAX_TRANSFER_FAILED');
	}

	function safeTransferETH(address to, uint256 amount) internal {
		bool success;
		assembly {
			// Transfer the ETH and store if it succeeded or not.
			success := call(gas(), to, amount, 0, 0, 0, 0)
		}
		require(success, "ETH_TRANSFER_FAILED");
	}

*/

contract TokenggpAVAX is Base, ERC20, ERC4626 {
	using SafeTransferLib for ERC20;
	using SafeTransferLib for address;
	using SafeCastLib for *;

	/// @dev thrown when syncing before cycle ends.
	error SyncError();

	/// @dev emit every time a new rewards cycle starts
	event NewRewardsCycle(uint32 indexed cycleEnd, uint256 rewardAmount);

	// address public immutable WAVAX;

	/// @notice the maximum length of a rewards cycle
	uint32 public rewardsCycleLength;

	/// @notice the effective start of the current cycle
	uint32 public lastSync;

	/// @notice the end of the current cycle. Will always be evenly divisible by `rewardsCycleLength`.
	uint32 public rewardsCycleEnd;

	/// @notice the amount of rewards distributed in a the most recent cycle.
	uint192 public lastRewardAmount;

	uint256 internal storedTotalAssets;

	// Total amount out for staking (not including any rewards)
	uint256 public stakingTotalAssets;

	constructor(Storage storageAddress, ERC20 asset) Base(storageAddress) ERC4626(asset, "GoGoPool Liquid Staking Token", "ggpAVAX") {
		version = 1; // for storage
		// TODO get this value from storage instead of constructor? DAO decides the cycle? Can it change?
		rewardsCycleLength = 1 days;
		// seed initial rewardsCycleEnd
		rewardsCycleEnd = (block.timestamp.safeCastTo32() / rewardsCycleLength) * rewardsCycleLength;
	}

	function depositRewards() public payable {
		// Check for rounding error since we round down in previewDeposit.
		require(previewDeposit(msg.value) != 0, "ZERO_SHARES");
		IWAVAX(address(asset)).deposit{value: msg.value}();
		// We DONT mint since we are depositing rewards to be shared by all
		// _mint(receiver, shares);
		emit Deposit(msg.sender, address(this), msg.value, 0);
		// DONT call this either, we ONLY want to increase the balance
		// afterDeposit(assets, 0);
	}

	// Rialto calls this to claim funds for staking
	function withdrawForStaking(uint256 assets) public {}

	function amountAvailableForStaking() public view returns (uint256) {
		uint256 totalNetworkAssets = totalFloat() + stakingTotalAssets;
		uint256 amountAvailable = totalNetworkAssets * targetFloatPercent;
	}

	receive() external payable {
		assert(msg.sender == address(asset)); // only accept AVAX via fallback from the WAVAX contract
	}

	// Accept raw AVAX
	function deposit() public payable returns (uint256 shares) {
		uint256 assets = msg.value;
		// Check for rounding error since we round down in previewDeposit.
		require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");
		IWAVAX(address(asset)).deposit{value: assets}();
		_mint(msg.sender, shares);
		emit Deposit(msg.sender, msg.sender, assets, shares);
		afterDeposit(assets, shares);
	}

	function withdrawAVAX(uint256 assets) public returns (uint256 shares) {
		shares = previewWithdraw(assets); // No need to check for rounding error, previewWithdraw rounds up.

		beforeWithdraw(assets, shares);

		_burn(msg.sender, shares);

		emit Withdraw(msg.sender, msg.sender, msg.sender, assets, shares);

		IWAVAX(address(asset)).withdraw(assets);
		msg.sender.safeTransferETH(assets);
	}

	/*///////////////////////////////////////////////////////////////
                       TARGET FLOAT CONFIGURATION
    //////////////////////////////////////////////////////////////*/

	/// @notice The desired percentage of the Vault's holdings to keep as float.
	/// @dev A fixed point number where 1e18 represents 100% and 0 represents 0%.
	uint256 public targetFloatPercent;

	/// @notice Emitted when the target float percentage is updated.
	/// @param user The authorized user who triggered the update.
	/// @param newTargetFloatPercent The new target float percentage.
	event TargetFloatPercentUpdated(address indexed user, uint256 newTargetFloatPercent);

	/// @notice Set a new target float percentage.
	/// @param newTargetFloatPercent The new target float percentage.
	// TODO who can call this fn?
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

	/// @notice Compute the amount of tokens available to share holders.
	///         Increases linearly during a reward distribution period from the sync call, not the cycle start.
	function totalAssets() public view override returns (uint256) {
		// cache global vars
		uint256 storedTotalAssets_ = storedTotalAssets;
		uint192 lastRewardAmount_ = lastRewardAmount;
		uint32 rewardsCycleEnd_ = rewardsCycleEnd;
		uint32 lastSync_ = lastSync;

		if (block.timestamp >= rewardsCycleEnd_) {
			// no rewards or rewards fully unlocked
			// entire reward amount is available
			return storedTotalAssets_ + lastRewardAmount_;
		}

		// rewards not fully unlocked
		// add unlocked rewards to stored total
		uint256 unlockedRewards = (lastRewardAmount_ * (block.timestamp - lastSync_)) / (rewardsCycleEnd_ - lastSync_);
		return storedTotalAssets_ + unlockedRewards;
	}

	// Update storedTotalAssets on withdraw/redeem
	function beforeWithdraw(uint256 amount, uint256 shares) internal virtual override {
		super.beforeWithdraw(amount, shares);
		storedTotalAssets -= amount;
	}

	// Update storedTotalAssets on deposit/mint
	function afterDeposit(uint256 amount, uint256 shares) internal virtual override {
		storedTotalAssets += amount;
		super.afterDeposit(amount, shares);
	}

	/// @notice Distributes rewards to xERC4626 holders.
	/// All surplus `asset` balance of the contract over the internal balance becomes queued for the next cycle.
	function syncRewards() public virtual {
		uint192 lastRewardAmount_ = lastRewardAmount;
		uint32 timestamp = block.timestamp.safeCastTo32();

		if (timestamp < rewardsCycleEnd) revert SyncError();

		uint256 storedTotalAssets_ = storedTotalAssets;
		uint256 nextRewards = asset.balanceOf(address(this)) - storedTotalAssets_ - lastRewardAmount_;

		storedTotalAssets = storedTotalAssets_ + lastRewardAmount_; // SSTORE

		uint32 end = ((timestamp + rewardsCycleLength) / rewardsCycleLength) * rewardsCycleLength;

		// Combined single SSTORE
		lastRewardAmount = nextRewards.safeCastTo192();
		lastSync = timestamp;
		rewardsCycleEnd = end;

		emit NewRewardsCycle(end, nextRewards);
	}
}
