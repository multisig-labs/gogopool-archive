/* eslint-disable no-undef */
// hardhat ensures hre is always in scope, no need to require
const { task } = require("hardhat/config");
const { get, getNamedAccounts } = require("./lib/utils");

task("staking:total_stake", "Total GGP Staked").setAction(async () => {
	const staking = await get("Staking");
	const totalStake = await staking.getTotalGGPStake();
	console.log(totalStake);
});

task("staking:user_stake", "GGP Staked for actor")
	.addParam("actor", "Actor to check stake")
	.setAction(async ({ actor }) => {
		const signer = (await getNamedAccounts())[actor];
		const staking = await get("Staking");
		const userStake = await staking.getUserGGPStake(signer.address);
		console.log(ethers.utils.formatUnits(userStake));
	});

task("staking:get_user_min_stake", "Minimum GGP stake required for actor")
	.addParam("actor", "Balance to check")
	.setAction(async ({ actor }) => {
		const signer = (await getNamedAccounts())[actor];
		const staking = await get("Staking");

		const minStakeAmt = await staking.getUserMinimumGGPStake(signer.address);
		console.log("Min stake amount", ethers.utils.formatUnits(minStakeAmt));
	});

task("staking:get_ggp", "Send GGP from deployer to actor")
	.addParam("actor", "Actor to recieve ggp")
	.addParam("amt", "Amount")
	.setAction(async ({ actor, amt }) => {
		const a = (await getNamedAccounts())[actor];
		const deployer = (await getNamedAccounts()).deployer;

		const deployerGgp = await get("TokenGGP", deployer);
		const actorGgp = await get("TokenGGP", a);
		const staking = await get("Staking");
		console.log("staking address", staking.address);

		console.log("as ether", ethers.utils.formatUnits(amt));
		await deployerGgp.transfer(a.address, ethers.utils.parseEther(amt));
		await actorGgp.approve(staking.address, ethers.utils.parseEther(amt));
	});

task("staking:stake_ggp", "Stake ggp for actor")
	.addParam("actor", "Account used to send tx")
	.addParam("ggp", "Amount of ggp to stake")
	.setAction(async ({ actor, ggp }) => {
		const a = (await getNamedAccounts())[actor];
		const staking = await get("Staking", a);
		await staking.callStatic.stakeGGP(ethers.utils.parseEther(ggp));
		await staking.stakeGGP(ethers.utils.parseEther(ggp));
	});
