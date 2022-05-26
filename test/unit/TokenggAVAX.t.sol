pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";

contract TokenggAVAXTest is GGPTest {
	address alice;
	address bob;
	address rialto;

	function setUp() public override {
		super.setUp();

		alice = getActorWithWAVAX(0, type(uint128).max);
		deal(alice, type(uint128).max);

		rialto = getActor(1);
		deal(rialto, type(uint128).max);

		bob = getActor(2);
	}

	function testRevertOnUserMistake() public {
		vm.prank(alice);
		ggAVAX.deposit(1 ether, address(ggAVAX));
	}

	function testSingleDepositWithdraw(uint128 amount) public {
		if (amount == 0) amount = 1;

		uint256 aliceUnderlyingAmount = amount;

		uint256 alicePreDepositBal = wavax.balanceOf(alice);

		vm.prank(alice);
		uint256 aliceShareAmount = ggAVAX.deposit(aliceUnderlyingAmount, alice);

		// Expect exchange rate to be 1:1 on initial deposit.
		assertEq(aliceUnderlyingAmount, aliceShareAmount);
		assertEq(ggAVAX.previewWithdraw(aliceShareAmount), aliceUnderlyingAmount);
		assertEq(ggAVAX.previewDeposit(aliceUnderlyingAmount), aliceShareAmount);
		assertEq(ggAVAX.totalSupply(), aliceShareAmount);
		assertEq(ggAVAX.totalAssets(), aliceUnderlyingAmount);
		assertEq(ggAVAX.balanceOf(alice), aliceShareAmount);
		assertEq(ggAVAX.convertToAssets(ggAVAX.balanceOf(alice)), aliceUnderlyingAmount);
		assertEq(wavax.balanceOf(alice), alicePreDepositBal - aliceUnderlyingAmount);

		vm.prank(alice);
		ggAVAX.withdraw(aliceUnderlyingAmount, alice, alice);

		assertEq(ggAVAX.totalAssets(), 0);
		assertEq(ggAVAX.balanceOf(alice), 0);
		assertEq(ggAVAX.convertToAssets(ggAVAX.balanceOf(alice)), 0);
		assertEq(wavax.balanceOf(alice), alicePreDepositBal);
	}

	function testSingleDepositWithdrawAVAX(uint128 amount) public {
		if (amount == 0) amount = 1;

		uint256 aliceUnderlyingAmount = amount;

		uint256 alicePreDepositBal = alice.balance;

		vm.prank(alice);
		uint256 aliceShareAmount = ggAVAX.depositAVAX{value: aliceUnderlyingAmount}();

		// Expect exchange rate to be 1:1 on initial deposit.
		assertEq(aliceUnderlyingAmount, aliceShareAmount);
		assertEq(ggAVAX.previewWithdraw(aliceShareAmount), aliceUnderlyingAmount);
		assertEq(ggAVAX.previewDeposit(aliceUnderlyingAmount), aliceShareAmount);
		assertEq(ggAVAX.totalSupply(), aliceShareAmount);
		assertEq(ggAVAX.totalAssets(), aliceUnderlyingAmount);
		assertEq(ggAVAX.balanceOf(alice), aliceShareAmount);
		assertEq(ggAVAX.convertToAssets(ggAVAX.balanceOf(alice)), aliceUnderlyingAmount);
		assertEq(alice.balance, alicePreDepositBal - aliceUnderlyingAmount);

		vm.prank(alice);
		ggAVAX.withdrawAVAX(aliceUnderlyingAmount);

		assertEq(ggAVAX.totalAssets(), 0);
		assertEq(ggAVAX.balanceOf(alice), 0);
		assertEq(ggAVAX.convertToAssets(ggAVAX.balanceOf(alice)), 0);
		assertEq(alice.balance, alicePreDepositBal);
	}

	function testSingleMintRedeem(uint128 amount) public {
		if (amount == 0) amount = 1;

		uint256 aliceShareAmount = amount;

		uint256 alicePreDepositBal = wavax.balanceOf(alice);

		vm.prank(alice);
		uint256 aliceUnderlyingAmount = ggAVAX.mint(aliceShareAmount, alice);

		// Expect exchange rate to be 1:1 on initial mint.
		assertEq(aliceShareAmount, aliceUnderlyingAmount);
		assertEq(ggAVAX.previewWithdraw(aliceShareAmount), aliceUnderlyingAmount);
		assertEq(ggAVAX.previewDeposit(aliceUnderlyingAmount), aliceShareAmount);
		assertEq(ggAVAX.totalSupply(), aliceShareAmount);
		assertEq(ggAVAX.totalAssets(), aliceUnderlyingAmount);
		assertEq(ggAVAX.balanceOf(alice), aliceUnderlyingAmount);
		assertEq(ggAVAX.convertToAssets(ggAVAX.balanceOf(alice)), aliceUnderlyingAmount);
		assertEq(wavax.balanceOf(alice), alicePreDepositBal - aliceUnderlyingAmount);

		vm.prank(alice);
		ggAVAX.redeem(aliceShareAmount, alice, alice);

		assertEq(ggAVAX.totalAssets(), 0);
		assertEq(ggAVAX.balanceOf(alice), 0);
		assertEq(ggAVAX.convertToAssets(ggAVAX.balanceOf(alice)), 0);
		assertEq(wavax.balanceOf(alice), alicePreDepositBal);
	}

	function testSingleDepositThenRewards(uint128 amount, uint128 rewards) public {
		// function testSingleDepositThenRewards() public {
		// uint128 amount = 100;
		// uint128 rewards = 10;
		if (amount == 0) amount = 1;
		if (rewards == 0) rewards = 1;

		uint256 aliceUnderlyingAmount = amount;

		vm.prank(alice);
		uint256 aliceShareAmount = ggAVAX.deposit(aliceUnderlyingAmount, alice);
		assertEq(aliceUnderlyingAmount, aliceShareAmount);

		console.log("block.timestamp", block.timestamp);
		console.log("rewardsCycleEnd", ggAVAX.rewardsCycleEnd());
		console.log("lastSync", ggAVAX.lastSync());
		console.log("lastRewardAmount", ggAVAX.lastRewardAmount());
		console.log("totalAssets", ggAVAX.totalAssets());
		console.log("totalFloat", ggAVAX.totalFloat());

		// Deposit some rewards from rialto
		uint256 rialtoRewardsAmount = rewards;
		vm.prank(rialto);
		ggAVAX.depositRewards{value: rialtoRewardsAmount}();
		// Rewards dont show up in totalAssets yet
		assertEq(ggAVAX.totalAssets(), aliceUnderlyingAmount);

		console.log("skip 1 reward cycle");
		skip(ggAVAX.rewardsCycleEnd() - block.timestamp);
		console.log("syncRewards");
		ggAVAX.syncRewards();
		// Rewards still dont show up in totalAssets yet, but will accrue over the next cycle
		assertEq(ggAVAX.totalAssets(), aliceUnderlyingAmount);

		console.log("block.timestamp", block.timestamp);
		console.log("rewardsCycleEnd", ggAVAX.rewardsCycleEnd());
		console.log("lastSync", ggAVAX.lastSync());
		console.log("lastRewardAmount", ggAVAX.lastRewardAmount());
		console.log("totalAssets", ggAVAX.totalAssets());
		console.log("totalFloat", ggAVAX.totalFloat());

		console.log("skip ahead half of a reward cycle");
		skip(ggAVAX.rewardsCycleLength() / 2);
		console.log("block.timestamp", block.timestamp);
		console.log("rewardsCycleEnd", ggAVAX.rewardsCycleEnd());
		console.log("lastSync", ggAVAX.lastSync());
		console.log("lastRewardAmount", ggAVAX.lastRewardAmount());
		console.log("totalAssets", ggAVAX.totalAssets());
		console.log("totalFloat", ggAVAX.totalFloat());
		assertEq(ggAVAX.totalAssets(), aliceUnderlyingAmount + rialtoRewardsAmount / 2);
		console.log("skip ahead to end of reward cycle");
		skip(ggAVAX.rewardsCycleLength() / 2);
		assertEq(ggAVAX.totalAssets(), aliceUnderlyingAmount + rialtoRewardsAmount);
	}

	function testDepositStakingRewards() public {
		// Scenario:
		// 1. Bob mints 4000 shares (costs 4000 tokens)
		// 2. 1000 tokens are withdrawn for staking
		// 3. 1000 rewards deposited
		// 4. 1 rewards cycle pass, no rewards are distributed to
		// 		totalReleasedAssets
		// 5. Sync rewards
		// 6. Skip ahead 1/3 a cycle, bob's 4000 shares convert to
		//		4333 assets.
		// 7. Skip ahead remaining 2/3 of the rewards cycle,
		//		all rewards should be distributed

		uint256 depositAmount = 4000;
		uint256 stakingWithdrawAmount = 1000;
		uint256 rewardsAmount = 1000;

		// 1. Bob mints 4000 shares
		vm.deal(bob, depositAmount);
		vm.startPrank(bob);
		wavax.deposit{value: depositAmount}();
		wavax.approve(address(ggAVAX), depositAmount);
		ggAVAX.mint(depositAmount, bob);
		vm.stopPrank();

		assertEq(wavax.balanceOf(bob), 0);
		assertEq(ggAVAX.balanceOf(bob), depositAmount);
		assertEq(ggAVAX.convertToShares(ggAVAX.balanceOf(bob)), depositAmount);

		// 2. 1000 tokens are withdrawn for staking
		vm.prank(rialto);
		ggAVAX.withdrawForStaking(stakingWithdrawAmount);
		assertEq(ggAVAX.totalAssets(), depositAmount);
		assertEq(ggAVAX.totalFloat(), depositAmount - stakingWithdrawAmount);
		assertEq(ggAVAX.stakingTotalAssets(), stakingWithdrawAmount);

		// 3. 1000 rewards are deposited
		// None of these rewards should be distributed yet
		vm.prank(rialto);
		ggAVAX.depositRewards{value: 1000}();

		assertEq(ggAVAX.totalAssets(), depositAmount);
		assertEq(ggAVAX.totalFloat(), depositAmount - stakingWithdrawAmount + rewardsAmount);
		assertEq(ggAVAX.convertToAssets(ggAVAX.balanceOf(bob)), depositAmount);

		// 4. Skip ahead one rewards cycle
		// Still no rewards should be distributed
		skip(ggAVAX.rewardsCycleEnd() - block.timestamp);
		assertEq(ggAVAX.totalAssets(), depositAmount);
		assertEq(ggAVAX.totalFloat(), depositAmount - stakingWithdrawAmount + rewardsAmount);
		assertEq(ggAVAX.convertToAssets(ggAVAX.balanceOf(bob)), depositAmount);

		// 5. Sync rewards and see an update to half the rewards
		ggAVAX.syncRewards();
		assertEq(ggAVAX.totalAssets(), depositAmount);
		assertEq(ggAVAX.totalFloat(), depositAmount - stakingWithdrawAmount + rewardsAmount);
		assertEq(ggAVAX.convertToAssets(ggAVAX.balanceOf(bob)), depositAmount);
		assertEq(ggAVAX.lastRewardAmount(), rewardsAmount);

		// 6. Skip 1/3 of rewards length and see 1/3 rewards in totalReleasedAssets
		skip(ggAVAX.rewardsCycleLength() / 3);
		uint256 oneThirdRewards = rewardsAmount / 3;
		assertEq(ggAVAX.totalAssets(), depositAmount + oneThirdRewards);
		assertEq(ggAVAX.totalFloat(), depositAmount - stakingWithdrawAmount + rewardsAmount);
		assertEq(ggAVAX.convertToAssets(ggAVAX.balanceOf(bob)), depositAmount + oneThirdRewards);
		assertEq(ggAVAX.lastRewardAmount(), rewardsAmount);

		// 7. Skip 2/3 of rewards length
		// Rewards should be fully distributed
		skip((ggAVAX.rewardsCycleLength() * 2) / 3);
		assertEq(ggAVAX.totalAssets(), depositAmount + rewardsAmount);
		assertEq(ggAVAX.totalFloat(), depositAmount - stakingWithdrawAmount + rewardsAmount);
		assertEq(ggAVAX.convertToAssets(ggAVAX.balanceOf(bob)), depositAmount + rewardsAmount);
	}

	function printState(string memory message) internal view {
		console.log("");
		console.log("STEP", message);
		console.log("---timestamps---");
		console.log("block timestamp", block.timestamp);
		console.log("rewards cycle end", ggAVAX.rewardsCycleEnd());
		console.log("last sync", ggAVAX.lastSync());

		console.log("---assets---");
		console.log("total assets", ggAVAX.totalAssets());
		console.log("total float", ggAVAX.totalFloat());
		console.log("staking assets", ggAVAX.stakingTotalAssets());

		console.log("---rewards---");
		console.log("last reward amount", ggAVAX.lastRewardAmount());
	}

	function ggAVAXStateAsserts(
		uint256 depositAmount,
		uint256 stakingWithdrawAmount,
		uint256 rewardsAmount
	) internal {
		assertEq(ggAVAX.totalAssets(), depositAmount);
		assertEq(ggAVAX.totalFloat(), depositAmount - stakingWithdrawAmount + rewardsAmount);
	}

	uint256 AVAX = 1e18;

	// function testFloat() public {
	// 	uint256 float = 1e17; // 1e18 * 10%;
	// 	uint256 amountDeposited = 2200 * AVAX;

	// 	vm.prank(alice);
	// 	ggAVAX.deposit(amountDeposited, alice);
	// 	assertEq(ggAVAX.stakingTotalAssets(), 0);
	// 	assertEq(ggAVAX.totalFloat(), amountDeposited);
	// 	assertEq(ggAVAX.amountAvailableForStaking(), 200 * AVAX);
	// }
}
