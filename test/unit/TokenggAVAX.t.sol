pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/BaseTest.sol";

contract TokenggAVAXTest is BaseTest, IWithdrawer {
	using FixedPointMathLib for uint256;

	address private alice;
	address private bob;
	address private nodeID;
	uint256 private duration;
	uint256 private delegationFee;

	function setUp() public override {
		super.setUp();
		vm.prank(guardian, guardian);
		store.setUint(keccak256("ProtocolDAO.TargetGGAVAXReserveRate"), 0.0 ether);

		alice = getActorWithTokens("alice", MAX_AMT, MAX_AMT);
		bob = getActor("bob");

		nodeID = randAddress();
		duration = 2 weeks;
		delegationFee = 20_000;
		uint256 avaxAssignmentRequest = 1000 ether;
		vm.startPrank(alice);
		ggp.approve(address(staking), 100 ether);
		staking.stakeGGP(100 ether);
		minipoolMgr.createMinipool{value: 1000 ether}(nodeID, duration, delegationFee, avaxAssignmentRequest);
		vm.stopPrank();
	}

	// function testRevertOnUserMistake() public {
	// 	vm.prank(alice);
	// 	ggAVAX.deposit(1 ether, address(ggAVAX));
	// }

	function testSingleDepositWithdrawWAVAX(uint128 amount) public {
		vm.assume(amount != 0 && amount < MAX_AMT);

		uint256 aliceUnderlyingAmount = amount;

		uint256 alicePreDepositBal = wavax.balanceOf(alice);

		vm.startPrank(alice);
		wavax.approve(address(ggAVAX), aliceUnderlyingAmount);
		uint256 aliceShareAmount = ggAVAX.deposit(aliceUnderlyingAmount, alice);
		vm.stopPrank();

		// Expect exchange rate to be 1:1 on initial deposit.
		assertEq(aliceUnderlyingAmount, aliceShareAmount);
		assertEq(ggAVAX.previewWithdraw(aliceShareAmount), aliceUnderlyingAmount);
		assertEq(ggAVAX.previewDeposit(aliceUnderlyingAmount), aliceShareAmount);
		assertEq(ggAVAX.totalSupply(), aliceShareAmount);
		assertEq(ggAVAX.totalAssets(), aliceUnderlyingAmount);
		assertEq(ggAVAX.balanceOf(alice), aliceShareAmount);
		assertEq(ggAVAX.convertToAssets(ggAVAX.balanceOf(alice)), aliceUnderlyingAmount);
		assertEq(wavax.balanceOf(alice), alicePreDepositBal - aliceUnderlyingAmount);

		vm.startPrank(alice);
		wavax.approve(address(ggAVAX), aliceUnderlyingAmount);
		ggAVAX.withdraw(aliceUnderlyingAmount, alice, alice);
		vm.stopPrank();

		assertEq(ggAVAX.totalAssets(), 0);
		assertEq(ggAVAX.balanceOf(alice), 0);
		assertEq(ggAVAX.convertToAssets(ggAVAX.balanceOf(alice)), 0);
		assertEq(wavax.balanceOf(alice), alicePreDepositBal);
	}

	function testSingleDepositWithdrawAVAX(uint128 amount) public {
		vm.assume(amount != 0 && amount < MAX_AMT);

		uint256 aliceUnderlyingAmount = amount;
		uint256 alicePreDepositBal = alice.balance;
		vm.deal(alice, alicePreDepositBal + aliceUnderlyingAmount);

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
		assertEq(alice.balance, alicePreDepositBal);

		vm.prank(alice);
		ggAVAX.withdrawAVAX(aliceUnderlyingAmount);

		assertEq(ggAVAX.totalAssets(), 0);
		assertEq(ggAVAX.balanceOf(alice), 0);
		assertEq(ggAVAX.convertToAssets(ggAVAX.balanceOf(alice)), 0);
		assertEq(alice.balance, alicePreDepositBal + aliceUnderlyingAmount);
	}

	function testSingleMintRedeem(uint128 amount) public {
		vm.assume(amount != 0 && amount < MAX_AMT);

		uint256 aliceShareAmount = amount;

		uint256 alicePreDepositBal = wavax.balanceOf(alice);

		vm.startPrank(alice);
		wavax.approve(address(ggAVAX), aliceShareAmount);
		uint256 aliceUnderlyingAmount = ggAVAX.mint(aliceShareAmount, alice);
		vm.stopPrank();

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

	function receiveWithdrawalAVAX() external payable {}

	function testDepositStakingRewards() public {
		// Scenario:
		// 1. Bob mints 2000 shares (costs 2000 tokens)
		// 2. 1000 tokens are withdrawn for staking
		// 3. 1000 rewards deposited
		// 4. 1 rewards cycle pass, no rewards are distributed to
		// 		totalReleasedAssets
		// 5. Sync rewards
		// 6. Skip ahead 1/3 a cycle, bob's 4000 shares convert to
		//		4333 assets.
		// 7. Skip ahead remaining 2/3 of the rewards cycle,
		//		all rewards should be distributed

		uint256 depositAmount = 2000 ether;
		uint256 stakingWithdrawAmount = 1000 ether;
		uint256 totalStakedAmount = 2000 ether;

		uint256 rewardsAmount = 100 ether;
		uint256 liquidStakerRewards = 50 ether - ((50 ether * 15) / 100);

		uint256 rialtoInitBal = rialto.balance;

		// 1. Bob mints 1000 shares
		vm.deal(bob, depositAmount);
		vm.prank(bob);
		ggAVAX.depositAVAX{value: depositAmount}();

		assertEq(bob.balance, 0);
		assertEq(wavax.balanceOf(address(ggAVAX)), depositAmount);
		assertEq(ggAVAX.balanceOf(bob), depositAmount);
		assertEq(ggAVAX.convertToShares(ggAVAX.balanceOf(bob)), depositAmount);
		assertEq(ggAVAX.amountAvailableForStaking(), depositAmount - depositAmount.mulDivDown(dao.getTargetGGAVAXReserveRate(), 1 ether));

		// 2. 1000 tokens are withdrawn for staking
		vm.prank(rialto);
		minipoolMgr.claimAndInitiateStaking(nodeID);

		assertEq(rialto.balance, rialtoInitBal + totalStakedAmount);
		assertEq(ggAVAX.totalAssets(), depositAmount);
		assertEq(ggAVAX.stakingTotalAssets(), stakingWithdrawAmount);

		// 3. 1000 rewards are deposited
		// None of these rewards should be distributed yet
		vm.deal(rialto, rialto.balance + rewardsAmount);
		vm.startPrank(rialto);
		bytes32 txID = keccak256("txid");
		minipoolMgr.recordStakingStart(nodeID, txID, block.timestamp);
		int256 idx = minipoolMgr.getIndexOf(nodeID);
		MinipoolManager.Minipool memory mp = minipoolMgr.getMinipool(idx);
		uint256 endTime = block.timestamp + mp.duration;

		skip(mp.duration);
		minipoolMgr.recordStakingEnd{value: totalStakedAmount + rewardsAmount}(nodeID, endTime, rewardsAmount);
		vm.stopPrank();

		assertEq(rialto.balance, rialtoInitBal);
		assertEq(ggAVAX.totalAssets(), depositAmount);
		assertEq(ggAVAX.convertToAssets(ggAVAX.balanceOf(bob)), depositAmount);

		// 4. Skip ahead one rewards cycle
		// Still no rewards should be distributed
		skip(ggAVAX.rewardsCycleLength());
		assertEq(ggAVAX.totalAssets(), depositAmount);
		assertEq(ggAVAX.convertToAssets(ggAVAX.balanceOf(bob)), depositAmount);

		// 5. Sync rewards and see an update to half the rewards
		ggAVAX.syncRewards();
		assertEq(ggAVAX.totalAssets(), depositAmount);
		assertEq(ggAVAX.convertToAssets(ggAVAX.balanceOf(bob)), depositAmount);
		assertEq(ggAVAX.lastRewardsAmount(), liquidStakerRewards);

		// 6. Skip 1/3 of rewards length and see 1/3 rewards in totalReleasedAssets
		skip(ggAVAX.rewardsCycleLength() / 3);

		uint256 oneThirdRewards = liquidStakerRewards / 3;
		assertEq(ggAVAX.totalAssets(), depositAmount + oneThirdRewards);
		assertEq(ggAVAX.convertToAssets(ggAVAX.balanceOf(bob)), depositAmount + oneThirdRewards);
		assertEq(ggAVAX.lastRewardsAmount(), liquidStakerRewards);

		// 7. Skip 2/3 of rewards length
		// Rewards should be fully distributed
		skip((ggAVAX.rewardsCycleLength() * 2) / 3);
		assertEq(ggAVAX.totalAssets(), depositAmount + liquidStakerRewards);
		assertEq(ggAVAX.convertToAssets(ggAVAX.balanceOf(bob)), depositAmount + liquidStakerRewards);
	}

	function testAmountAvailableForStaking() public {
		uint256 depositAmount = 1000 ether;

		vm.deal(bob, depositAmount);
		vm.prank(bob);
		ggAVAX.depositAVAX{value: depositAmount}();

		assertEq(bob.balance, 0);
		assertEq(wavax.balanceOf(address(ggAVAX)), depositAmount);
		assertEq(ggAVAX.balanceOf(bob), depositAmount);
		assertEq(ggAVAX.convertToShares(ggAVAX.balanceOf(bob)), depositAmount);
		uint256 reservedAssets = ggAVAX.totalAssets().mulDivDown(dao.getTargetGGAVAXReserveRate(), 1 ether);
		assertEq(ggAVAX.amountAvailableForStaking(), depositAmount - reservedAssets);
	}

	function testWithdrawForStaking() public {
		// Deposit liquid staker funds
		uint256 depositAmount = 1000 ether;
		vm.deal(bob, depositAmount);
		vm.prank(bob);
		ggAVAX.depositAVAX{value: depositAmount}();

		uint256 reservedAssets = ggAVAX.totalAssets().mulDivDown(dao.getTargetGGAVAXReserveRate(), 1 ether);
		assertEq(ggAVAX.amountAvailableForStaking(), depositAmount - reservedAssets);

		// Create and claim minipool
		address nodeOp = getActorWithTokens("nodeOp", 1000 ether, 200 ether);
		uint256 duration = 2 weeks;
		uint256 depositAmt = 1000 ether;
		uint256 avaxAssignmentRequest = 1000 ether;
		uint128 ggpStakeAmt = 200 ether;

		vm.startPrank(nodeOp, nodeOp);
		ggp.approve(address(staking), ggpStakeAmt);
		staking.stakeGGP(ggpStakeAmt);
		MinipoolManager.Minipool memory mp = createMinipool(depositAmt, avaxAssignmentRequest, duration);
		vm.stopPrank();

		vm.prank(rialto);
		minipoolMgr.claimAndInitiateStaking(mp.nodeID);

		// Verify amount available for staking
		assertEq(ggAVAX.amountAvailableForStaking(), depositAmount - reservedAssets - depositAmt);
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
		console.log("last rewards amount", ggAVAX.lastRewardsAmount());
	}

	function ggAVAXStateAsserts(
		uint256 depositAmount,
		uint256 stakingWithdrawAmount,
		uint256 rewardsAmount
	) internal {
		assertEq(ggAVAX.totalAssets(), depositAmount);
		assertEq(ggAVAX.totalFloat(), depositAmount - stakingWithdrawAmount + rewardsAmount);
	}

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
