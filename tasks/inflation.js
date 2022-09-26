/* eslint-disable no-undef */
// hardhat ensures hre is always in scope, no need to require
const { utils } = require("ethers");
const { get, log, logtx, getNamedAccounts } = require("./lib/utils");

task("inflation:canCycleStart", "Can a new rewards cycle start")
	.addParam("actor", "Account used to send tx")
	.setAction(async ({ actor }) => {
		const signer = (await getNamedAccounts())[actor];
		const rewardsPool = await get("RewardsPool", signer);
		const canStart = await rewardsPool.canCycleStart();
		log(`Can a new rewards cycle start?: ${canStart}`);
	});

// be sure to skip ahead 2 days for this to work successfully
task("inflation:startCycle", "start a new rewards cycle")
	.addParam("actor", "Account used to send tx")
	.setAction(async ({ actor }) => {
		const signer = (await getNamedAccounts())[actor];
		const rewardsPool = await get("RewardsPool", signer);
		tx = await rewardsPool.startCycle();
		await logtx(tx);
		// log how much was distributed to each contract and total
		const totalRewardsThisCycle = utils.formatEther(
			`${await rewardsPool.getRewardCycleTotalAmount()}`
		);
		const daoAllowance = utils.formatEther(
			`${await rewardsPool.getClaimingContractDistribution("ProtocolDAOClaim")}`
		);
		const nopClaimContractAllowance = utils.formatEther(
			`${await rewardsPool.getClaimingContractDistribution("NOPClaim")}`
		);
		log(
			`Total Rewards this cycle: ${totalRewardsThisCycle} GGP. Rewards tranfered to the Protocal DAO: ${daoAllowance} GGP. Rewards transferred to the NOPClaim: ${nopClaimContractAllowance} GGP`
		);
	});

// Will need to do this before you can start cycle
task(
	"inflation:transferGGP",
	"transfer GGP to the vault from the deployer"
).setAction(async () => {
	const ggp = await get("TokenGGP");
	const vault = await get("Vault");

	tx = await ggp.approve(vault.address, utils.parseEther("18000000"));
	await logtx(tx);
	tx = await vault.depositToken(
		"RewardsPool",
		ggp.address,
		utils.parseEther("18000000")
	);
	await logtx(tx);
	const transferedAmt = await vault.balanceOfToken("RewardsPool", ggp.address);

	log(`Rewards Pool now contains ${transferedAmt} GGP`);
});
