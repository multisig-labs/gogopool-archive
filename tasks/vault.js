/* eslint-disable no-undef */
// hardhat ensures hre is always in scope, no need to require
const { addrs, get, log, logf } = require("./lib/utils");

task("vault:list", "List contract balances").setAction(async () => {
	const vault = await get("Vault");
	log("=== VAULT BALANCES FOR CONTRACT NAMES ===");
	logf("%-20s %-10s %-10s %-10s", "Contract", "AVAX", "WAVAX", "GGP");
	for (const name in addrs) {
		const balAVAX = await vault.balanceOf(name);
		const balWAVAX = await vault.balanceOfToken(name, addrs.WAVAX);
		const balGGP = await vault.balanceOfToken(name, addrs.TokenGGP);
		logf(
			"%-20s %-10d %-10s %-10s",
			name,
			hre.ethers.utils.formatUnits(balAVAX),
			hre.ethers.utils.formatUnits(balWAVAX),
			hre.ethers.utils.formatUnits(balGGP)
		);
	}
	log("=== ggAVAX CONTRACT BALANCES ===");
	const wavax = await get("WAVAX");
	const balWAVAX = await wavax.balanceOf(addrs.TokenggAVAX);
	logf("%-20s %-10s", "WAVAX", hre.ethers.utils.formatUnits(balWAVAX));
});
