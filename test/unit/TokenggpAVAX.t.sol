pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";

contract TokenggpAVAXTest is GGPTest {
	address alice;
	address rialto;

	function setUp() public override {
		super.setUp();
		alice = getActorWithWAVAX(0, type(uint128).max);
		deal(alice, type(uint128).max);
		rialto = getActor(1);
		deal(rialto, type(uint128).max);
	}

	function testRevertOnUserMistake() public {
		vm.prank(alice);
		ggpAVAX.deposit(1 ether, address(ggpAVAX));
	}

	function testSingleDepositWithdraw(uint128 amount) public {
		if (amount == 0) amount = 1;

		uint256 aliceUnderlyingAmount = amount;

		uint256 alicePreDepositBal = wavax.balanceOf(alice);

		vm.prank(alice);
		uint256 aliceShareAmount = ggpAVAX.deposit(aliceUnderlyingAmount, alice);

		// Expect exchange rate to be 1:1 on initial deposit.
		assertEq(aliceUnderlyingAmount, aliceShareAmount);
		assertEq(ggpAVAX.previewWithdraw(aliceShareAmount), aliceUnderlyingAmount);
		assertEq(ggpAVAX.previewDeposit(aliceUnderlyingAmount), aliceShareAmount);
		assertEq(ggpAVAX.totalSupply(), aliceShareAmount);
		assertEq(ggpAVAX.totalAssets(), aliceUnderlyingAmount);
		assertEq(ggpAVAX.balanceOf(alice), aliceShareAmount);
		assertEq(ggpAVAX.convertToAssets(ggpAVAX.balanceOf(alice)), aliceUnderlyingAmount);
		assertEq(wavax.balanceOf(alice), alicePreDepositBal - aliceUnderlyingAmount);

		vm.prank(alice);
		ggpAVAX.withdraw(aliceUnderlyingAmount, alice, alice);

		assertEq(ggpAVAX.totalAssets(), 0);
		assertEq(ggpAVAX.balanceOf(alice), 0);
		assertEq(ggpAVAX.convertToAssets(ggpAVAX.balanceOf(alice)), 0);
		assertEq(wavax.balanceOf(alice), alicePreDepositBal);
	}

	function testSingleDepositWithdrawAVAX(uint128 amount) public {
		if (amount == 0) amount = 1;

		uint256 aliceUnderlyingAmount = amount;

		uint256 alicePreDepositBal = alice.balance;

		vm.prank(alice);
		uint256 aliceShareAmount = ggpAVAX.depositAVAX{value: aliceUnderlyingAmount}();

		// Expect exchange rate to be 1:1 on initial deposit.
		assertEq(aliceUnderlyingAmount, aliceShareAmount);
		assertEq(ggpAVAX.previewWithdraw(aliceShareAmount), aliceUnderlyingAmount);
		assertEq(ggpAVAX.previewDeposit(aliceUnderlyingAmount), aliceShareAmount);
		assertEq(ggpAVAX.totalSupply(), aliceShareAmount);
		assertEq(ggpAVAX.totalAssets(), aliceUnderlyingAmount);
		assertEq(ggpAVAX.balanceOf(alice), aliceShareAmount);
		assertEq(ggpAVAX.convertToAssets(ggpAVAX.balanceOf(alice)), aliceUnderlyingAmount);
		assertEq(alice.balance, alicePreDepositBal - aliceUnderlyingAmount);

		vm.prank(alice);
		ggpAVAX.withdrawAVAX(aliceUnderlyingAmount);

		assertEq(ggpAVAX.totalAssets(), 0);
		assertEq(ggpAVAX.balanceOf(alice), 0);
		assertEq(ggpAVAX.convertToAssets(ggpAVAX.balanceOf(alice)), 0);
		assertEq(alice.balance, alicePreDepositBal);
	}

	function testSingleMintRedeem(uint128 amount) public {
		if (amount == 0) amount = 1;

		uint256 aliceShareAmount = amount;

		uint256 alicePreDepositBal = wavax.balanceOf(alice);

		vm.prank(alice);
		uint256 aliceUnderlyingAmount = ggpAVAX.mint(aliceShareAmount, alice);

		// Expect exchange rate to be 1:1 on initial mint.
		assertEq(aliceShareAmount, aliceUnderlyingAmount);
		assertEq(ggpAVAX.previewWithdraw(aliceShareAmount), aliceUnderlyingAmount);
		assertEq(ggpAVAX.previewDeposit(aliceUnderlyingAmount), aliceShareAmount);
		assertEq(ggpAVAX.totalSupply(), aliceShareAmount);
		assertEq(ggpAVAX.totalAssets(), aliceUnderlyingAmount);
		assertEq(ggpAVAX.balanceOf(alice), aliceUnderlyingAmount);
		assertEq(ggpAVAX.convertToAssets(ggpAVAX.balanceOf(alice)), aliceUnderlyingAmount);
		assertEq(wavax.balanceOf(alice), alicePreDepositBal - aliceUnderlyingAmount);

		vm.prank(alice);
		ggpAVAX.redeem(aliceShareAmount, alice, alice);

		assertEq(ggpAVAX.totalAssets(), 0);
		assertEq(ggpAVAX.balanceOf(alice), 0);
		assertEq(ggpAVAX.convertToAssets(ggpAVAX.balanceOf(alice)), 0);
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
		uint256 aliceShareAmount = ggpAVAX.deposit(aliceUnderlyingAmount, alice);
		assertEq(aliceUnderlyingAmount, aliceShareAmount);

		console.log("block.timestamp", block.timestamp);
		console.log("rewardsCycleEnd", ggpAVAX.rewardsCycleEnd());
		console.log("lastSync", ggpAVAX.lastSync());
		console.log("lastRewardAmount", ggpAVAX.lastRewardAmount());
		console.log("totalAssets", ggpAVAX.totalAssets());
		console.log("totalFloat", ggpAVAX.totalFloat());

		// Deposit some rewards from rialto
		uint256 rialtoRewardsAmount = rewards;
		vm.prank(rialto);
		ggpAVAX.depositRewards{value: rialtoRewardsAmount}();
		// Rewards dont show up in totalAssets yet
		assertEq(ggpAVAX.totalAssets(), aliceUnderlyingAmount);

		console.log("skip 1 reward cycle");
		skip(ggpAVAX.rewardsCycleEnd() - block.timestamp);
		console.log("syncRewards");
		ggpAVAX.syncRewards();
		// Rewards still dont show up in totalAssets yet, but will accrue over the next cycle
		assertEq(ggpAVAX.totalAssets(), aliceUnderlyingAmount);

		console.log("block.timestamp", block.timestamp);
		console.log("rewardsCycleEnd", ggpAVAX.rewardsCycleEnd());
		console.log("lastSync", ggpAVAX.lastSync());
		console.log("lastRewardAmount", ggpAVAX.lastRewardAmount());
		console.log("totalAssets", ggpAVAX.totalAssets());
		console.log("totalFloat", ggpAVAX.totalFloat());

		console.log("skip ahead half of a reward cycle");
		skip(ggpAVAX.rewardsCycleLength() / 2);
		console.log("block.timestamp", block.timestamp);
		console.log("rewardsCycleEnd", ggpAVAX.rewardsCycleEnd());
		console.log("lastSync", ggpAVAX.lastSync());
		console.log("lastRewardAmount", ggpAVAX.lastRewardAmount());
		console.log("totalAssets", ggpAVAX.totalAssets());
		console.log("totalFloat", ggpAVAX.totalFloat());
		assertEq(ggpAVAX.totalAssets(), aliceUnderlyingAmount + rialtoRewardsAmount / 2);
		console.log("skip ahead to end of reward cycle");
		skip(ggpAVAX.rewardsCycleLength() / 2);
		assertEq(ggpAVAX.totalAssets(), aliceUnderlyingAmount + rialtoRewardsAmount);
	}

	uint256 AVAX = 1e18;

	// function testFloat() public {
	// 	uint256 float = 1e17; // 1e18 * 10%;
	// 	uint256 amountDeposited = 2200 * AVAX;

	// 	vm.prank(alice);
	// 	ggpAVAX.deposit(amountDeposited, alice);
	// 	assertEq(ggpAVAX.stakingTotalAssets(), 0);
	// 	assertEq(ggpAVAX.totalFloat(), amountDeposited);
	// 	assertEq(ggpAVAX.amountAvailableForStaking(), 200 * AVAX);
	// }
}
