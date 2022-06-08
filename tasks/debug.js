/* eslint-disable no-undef */
// hardhat ensures hre is always in scope, no need to require
const {
	addrs,
	get,
	hash,
	log,
	logf,
	getNamedAccounts,
} = require("./lib/utils");

task("debug:list_actor_balances").setAction(async () => {
	const actors = await getNamedAccounts();
	const ggAVAX = await get("TokenggAVAX");

	log("");
	logf("%-15s %-20s %-20s %-20s", "User", "AVAX", "ggAVAX", "equivAVAX");
	for (actor in actors) {
		const balAVAX = await hre.ethers.provider.getBalance(actors[actor].address);
		const balGGAVAX = await ggAVAX.balanceOf(actors[actor].address);
		const balEQAVAX = await ggAVAX.previewRedeem(balGGAVAX);
		logf(
			"%-15s %-20.6f %-20.6f %-20.6f",
			actor,
			hre.ethers.utils.formatUnits(balAVAX),
			hre.ethers.utils.formatUnits(balGGAVAX),
			hre.ethers.utils.formatUnits(balEQAVAX)
		);
	}
});

task("debug:list_vars", "List important system variables").setAction(
	async () => {
		const vault = await get("Vault");
		const ggAVAX = await get("TokenggAVAX");

		await hre.run("multisig:list");
		log("");

		let bal;
		logf("%-20s %-10s", "Contract", "AVAX Balance");
		for (const name of ["MinipoolManager", "TokenggAVAX"]) {
			bal = await vault.balanceOf(name);
			logf("%-20s %-10d", name, hre.ethers.utils.formatUnits(bal));
		}

		log("");
		log("ggAVAX Variables:");
		const rewardsCycleEnd = await ggAVAX.rewardsCycleEnd();
		const lastRewardAmount = await ggAVAX.lastRewardAmount();
		const networkTotalAssets = await ggAVAX.totalReleasedAssets();
		const stakingTotalAssets = await ggAVAX.stakingTotalAssets();
		const amountAvailableForStaking = await ggAVAX.amountAvailableForStaking();
		const totalAssets = await ggAVAX.totalAssets();
		logf(
			"%-15s %-15s %-15s %-15s %-15s %-15s",
			"rwdCycEnd",
			"lstRwdAmt",
			"totRelAss",
			"stakTotAss",
			"AmtAvlStak",
			"totAssets"
		);
		logf(
			"%-15s %-15.2f %-15.2f %-15.2f %-15.2f %-15.2f",
			rewardsCycleEnd,
			hre.ethers.utils.formatUnits(lastRewardAmount),
			hre.ethers.utils.formatUnits(networkTotalAssets),
			hre.ethers.utils.formatUnits(stakingTotalAssets),
			hre.ethers.utils.formatUnits(amountAvailableForStaking),
			hre.ethers.utils.formatUnits(totalAssets)
		);
	}
);

task(
	"debug:list_contracts",
	"List all contracts that are registered in storage"
).setAction(async () => {
	const storage = await get("Storage");
	for (const name in addrs) {
		try {
			const n = await storage.getString(
				hash(["string", "address"], ["contract.name", addrs[name]])
			);
			const exists = await storage.getBool(
				hash(["string", "address"], ["contract.exists", addrs[name]])
			);
			const address = await storage.getAddress(
				hash(["string", "string"], ["contract.address", name])
			);
			const emoji =
				exists && address === addrs[name] && n === name
					? "✅"
					: "(Not Registered)";
			if (address !== hre.ethers.constants.AddressZero) {
				log(name, address, emoji);
			}
		} catch (e) {
			log("error", e);
		}
	}
});
