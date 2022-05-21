/* eslint-disable no-undef */
// hardhat ensures hre is always in scope, no need to require
const { addrs, get, log, logf } = require("./lib/utils");

task("vault:list", "List vault").setAction(async () => {
	const vault = await get("Vault");
	logf("%-20s %-10s", "Contract", "AVAX Balance");
	for (const name in addrs) {
		const bal = await vault.balanceOf(name);
		logf("%-20s %-10d", name, hre.ethers.utils.formatUnits(bal));
	}
	log("\n");
	logf("%-20s %-10s", "Contract", "GGP Balance");
	for (const name in addrs) {
		const bal = await vault.balanceOfToken(name, addrs.TokenGGP);
		logf("%-20s %-10d", name, hre.ethers.utils.formatUnits(bal));
	}
});
