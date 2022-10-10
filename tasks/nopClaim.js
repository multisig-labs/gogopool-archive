/* eslint-disable no-undef */
// hardhat ensures hre is always in scope, no need to require
const { ethers, utils } = require("ethers");
const {
	get,
	log,
	logtx,
	getNamedAccounts,
	getStakers,
} = require("./lib/utils");

task(
	"nopClaim:distributeRewards",
	"Calculate and distribute rewards to the node operators"
).setAction(async () => {
	const rialto = await getNamedAccounts().rialto1;
	const nopClaim = await get("NOPClaim", rialto);
	const stakers = await getStakers();

	eligibleStakers = [];
	let totalEligibleGGPStaked = ethers.BigNumber.from("0");
	for (staker of stakers) {
		const isEligible = await nopClaim.isEligible(staker.stakerAddr);
		log(`Eligible ${staker.stakerAddr} ${isEligible}`);
		if (isEligible) {
			// TODO: get their effective stake not their total staked
			// add their ggp staked to the total ggp staked
			totalEligibleGGPStaked = totalEligibleGGPStaked.add(staker.ggpStaked);
			// add them to the eligible stakers
			eligibleStakers.push(staker.stakerAddr);
		}
	}

	for (staker of eligibleStakers) {
		tx = await nopClaim.calculateAndDistributeRewards(
			staker,
			totalEligibleGGPStaked
		);
		logtx(tx);
	}
});

task("nopClaim:isEligible", "is a staker eligible")
	.addParam("staker", "Account used to send tx")
	.setAction(async ({ staker }) => {
		const signer = (await getNamedAccounts())[staker];
		const nopClaim = await get("NOPClaim");
		const staking = await get("Staking");
		log(signer.address);
		const index = await staking.getIndexOf(signer.address);
		const user = await staking.getStaker(index);
		log(
			utils.formatEther(
				`${await staking.getCollateralizationRatio(user.stakerAddr)}`
			)
		);
		const isEligible = await nopClaim.isEligible(user.stakerAddr);
		log(`Is ${staker} eligible for rewards?: ${isEligible}`);
	});

task("nopClaim:claimAndRestakeHalf", "claim rewards for the given user")
	.addParam("staker", "Account used to send tx")
	.setAction(async ({ staker }) => {
		const signer = (await getNamedAccounts())[staker];
		const nopClaim = await get("NOPClaim", signer);
		const staking = await get("Staking", signer);
		const rewardAmt = utils.formatEther(
			`${await staking.getGGPRewards(signer.address)}`
		);
		const halfRewardAmt = rewardAmt / 2;
		log(
			`${staker} has ${rewardAmt} in GGP rewards they can claim. Claiming half (${halfRewardAmt}) and restaking the other half`
		);
		try {
			tx = await nopClaim.claimAndRestake(utils.parseEther(`${halfRewardAmt}`));
			// tx = await staking.decreaseGGPRewards(
			// 	signer.address,
			// 	utils.parseEther(`${rewardAmt}`)
			// );
			logtx(tx);
		} catch (error) {
			log(error.reason);
		}
		const rewardAmtAfterClaim = utils.formatEther(
			`${await staking.getGGPRewards(signer.address)}`
		);
		log(
			`${staker} has claimed GGP rewards they now have ${rewardAmtAfterClaim} in GGP rewards`
		);
		const newGGPStaked = utils.formatEther(
			`${await staking.getGGPStake(signer.address)}`
		);
		log(`${staker} now has ${newGGPStaked} in GGP staked`);
	});
