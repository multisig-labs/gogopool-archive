/* eslint-disable no-undef */
// hardhat ensures hre is always in scope, no need to require
const { addrs, get, hash, log } = require("./lib/utils");

task(
	"debug:setup",
	"Set up a multisig and a minipool, then claim it"
).setAction(async () => {
	await hre.run("multisig:register", { addr: process.env.RIALTO1 });
	await hre.run("minipool:create", {
		nodeid: process.env.NODEID1,
		duration: 10000000,
		fee: 0,
		ggp: 0,
		avax: 2000,
	});
	await hre.run("minipool:update_status", {
		nodeid: process.env.NODEID1,
		status: 1,
	});
	await hre.run("minipool:claim", {
		nodeid: process.env.NODEID1,
		pk: process.env.RIALTO1_PRIVATE_KEY,
	});
	log("Setup complete");
});

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
