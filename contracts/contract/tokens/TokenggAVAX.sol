// SPDX-License-Identifier: GPL-3.0-only
// Copied from https://github.com/fei-protocol/ERC4626/blob/main/src/xERC4626.sol
// Rewards logic inspired by xERC20 (https://github.com/ZeframLou/playpen/blob/main/src/xERC20.sol)
pragma solidity ^0.8.13;

import "../BaseUpgradeable.sol";
import {ERC20Upgradeable} from "./upgradeable/ERC20Upgradeable.sol";
import {ERC4626Upgradeable} from "./upgradeable/ERC4626Upgradeable.sol";
import {IWithdrawer} from "../../interface/IWithdrawer.sol";
import {ProtocolDAO} from "../dao/ProtocolDAO.sol";
import {Storage} from "../Storage.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import {ERC20} from "@rari-capital/solmate/src/mixins/ERC4626.sol";
import {FixedPointMathLib} from "@rari-capital/solmate/src/utils/FixedPointMathLib.sol";
import {IWAVAX} from "../../interface/IWAVAX.sol";
import {SafeCastLib} from "@rari-capital/solmate/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "@rari-capital/solmate/src/utils/SafeTransferLib.sol";

/// @dev Local variables and parent contracts must remain in order between contract upgrades
contract TokenggAVAX is ERC20Upgradeable, ERC4626Upgradeable, BaseUpgradeable, Initializable, UUPSUpgradeable, OwnableUpgradeable {
	using SafeTransferLib for ERC20;
	using SafeTransferLib for address;
	using SafeCastLib for *;
	using FixedPointMathLib for uint256;

	error SyncError();
	error ZeroShares();
	error ZeroAssets();
	error InvalidStakingDeposit();
	error WithdrawAmountTooLarge();

	event NewRewardsCycle(uint256 indexed cycleEnd, uint256 rewardsAmount);
	event WithdrawnForStaking(address indexed caller, uint256 assets);
	event DepositedFromStaking(address indexed caller, uint256 baseAmt, uint256 rewardsAmt);

	/// @notice the effective start of the current cycle
	uint32 public lastSync;

	/// @notice the maximum length of a rewards cycle
	uint32 public rewardsCycleLength;

	/// @notice the end of the current cycle. Will always be evenly divisible by `rewardsCycleLength`.
	uint32 public rewardsCycleEnd;

	/// @notice the amount of rewards distributed in a the most recent cycle.
	uint192 public lastRewardsAmt;

	/// @notice the total amount of avax (including avax sent out for staking and all incoming rewards)
	uint256 public totalReleasedAssets;

	/// @notice total amount of avax currently out for staking (not including any rewards)
	uint256 public stakingTotalAssets;

	/// @custom:oz-upgrades-unsafe-allow constructor
	constructor() {
		// The constructor is exectued only when creating implementation contract
		// so prevent it's reinitialization
		_disableInitializers();
	}

	function initialize(Storage storageAddress, ERC20 asset) public initializer {
		__ERC4626Upgradeable_init(asset, "GoGoPool Liquid Staking Token", "ggAVAX");
		__BaseUpgradeable_init(storageAddress);
		__Ownable_init();
		__UUPSUpgradeable_init();

		rewardsCycleLength = 14 days;
		rewardsCycleEnd = block.timestamp.safeCastTo32();
	}

	/// @notice only accept AVAX via fallback from the WAVAX contract
	receive() external payable {
		assert(msg.sender == address(asset));
	}

	/// @notice Distributes rewards to xERC4626 holders.
	/// 				All surplus `asset` balance of the contract over the internal balance becomes queued for the next cycle.
	function syncRewards() public {
		uint32 timestamp = block.timestamp.safeCastTo32();

		if (timestamp < rewardsCycleEnd) {
			revert SyncError();
		}

		uint192 lastRewardsAmt_ = lastRewardsAmt;
		uint256 totalReleasedAssets_ = totalReleasedAssets;
		uint256 stakingTotalAssets_ = stakingTotalAssets;

		uint256 nextRewardsAmt = (asset.balanceOf(address(this)) + stakingTotalAssets_) - totalReleasedAssets_ - lastRewardsAmt_;
		uint32 nextRewardsCycleEnd = timestamp + rewardsCycleLength;

		lastRewardsAmt = nextRewardsAmt.safeCastTo192();
		lastSync = timestamp;
		rewardsCycleEnd = nextRewardsCycleEnd;
		totalReleasedAssets = totalReleasedAssets_ + lastRewardsAmt_;
		emit NewRewardsCycle(nextRewardsCycleEnd, nextRewardsAmt);
	}

	/// @notice Compute the amount of tokens available to share holders.
	///         Increases linearly during a reward distribution period from the sync call, not the cycle start.
	function totalAssets() public view override returns (uint256) {
		// cache global vars
		uint256 totalReleasedAssets_ = totalReleasedAssets;
		uint192 lastRewardsAmt_ = lastRewardsAmt;
		uint32 rewardsCycleEnd_ = rewardsCycleEnd;
		uint32 lastSync_ = lastSync;

		if (block.timestamp >= rewardsCycleEnd_) {
			// no rewards or rewards are fully unlocked
			// entire reward amount is available
			return totalReleasedAssets_ + lastRewardsAmt_;
		}

		// rewards are not fully unlocked
		// return unlocked rewards and stored total
		uint256 unlockedRewards = (lastRewardsAmt_ * (block.timestamp - lastSync_)) / (rewardsCycleEnd_ - lastSync_);
		return totalReleasedAssets_ + unlockedRewards;
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
			revert InvalidStakingDeposit();
		}

		emit DepositedFromStaking(msg.sender, baseAmt, rewardAmt);
		stakingTotalAssets -= baseAmt;
		IWAVAX(address(asset)).deposit{value: totalAmt}();
	}

	function withdrawForStaking(uint256 assets) public onlyLatestContract("MinipoolManager", msg.sender) {
		if (assets > amountAvailableForStaking()) {
			revert WithdrawAmountTooLarge();
		}

		emit WithdrawnForStaking(msg.sender, assets);

		stakingTotalAssets += assets;
		IWAVAX(address(asset)).withdraw(assets);
		IWithdrawer withdrawer = IWithdrawer(msg.sender);
		withdrawer.receiveWithdrawalAVAX{value: assets}();
	}

	function depositAVAX() public payable whenNotPaused returns (uint256 shares) {
		uint256 assets = msg.value;
		// Check for rounding error since we round down in previewDeposit.
		if ((shares = previewDeposit(assets)) == 0) {
			revert ZeroShares();
		}

		emit Deposit(msg.sender, msg.sender, assets, shares);

		IWAVAX(address(asset)).deposit{value: assets}();
		_mint(msg.sender, shares);
		afterDeposit(assets, shares);
	}

	function withdrawAVAX(uint256 assets) public whenNotPaused returns (uint256 shares) {
		shares = previewWithdraw(assets); // No need to check for rounding error, previewWithdraw rounds up.
		beforeWithdraw(assets, shares);
		_burn(msg.sender, shares);

		emit Withdraw(msg.sender, msg.sender, msg.sender, assets, shares);

		IWAVAX(address(asset)).withdraw(assets);
		msg.sender.safeTransferETH(assets);
	}

	function redeemAVAX(uint256 shares) public whenNotPaused returns (uint256 assets) {
		// Check for rounding error since we round down in previewRedeem.
		if ((assets = previewRedeem(shares)) == 0) {
			revert ZeroAssets();
		}
		beforeWithdraw(assets, shares);
		_burn(msg.sender, shares);

		emit Withdraw(msg.sender, msg.sender, msg.sender, assets, shares);

		IWAVAX(address(asset)).withdraw(assets);
		msg.sender.safeTransferETH(assets);
	}

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

	function beforeWithdraw(uint256 amount, uint256 shares) internal override {
		totalReleasedAssets -= amount;
	}

	function afterDeposit(uint256 amount, uint256 shares) internal override {
		totalReleasedAssets += amount;
	}

	function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
