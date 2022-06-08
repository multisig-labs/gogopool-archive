/* eslint-disable no-undef */
// hardhat ensures hre is always in scope, no need to require
const { get, log, logf, getNamedAccounts, formatAddr } = require("./lib/utils");

const MAX_ENTRIES = 10;

task("multisig:list", "List all registered multisigs").setAction(async () => {
	const multisigManager = await get("MultisigManager");
	logf("%-12s %-10s %-10s", "Multisig", "Enabled", "C-Chain AVAX Balance");
	for (let i = 0; i < MAX_ENTRIES; i++) {
		try {
			const { addr, enabled } = await multisigManager.getMultisig(i);
			if (addr === hre.ethers.constants.AddressZero) break;
			const bal = await hre.ethers.provider.getBalance(addr);
			logf(
				"%-12s %-10s %-10.4d",
				formatAddr(addr),
				enabled,
				hre.ethers.utils.formatUnits(bal)
			);
		} catch (e) {
			log("error", e);
		}
	}
});

task("multisig:register", "Register and enable a multisig address")
	.addParam("name", "Named account")
	.setAction(async ({ name }) => {
		const addr = (await getNamedAccounts())[name].address;
		const multisigManager = await get("MultisigManager");
		try {
			await multisigManager.registerMultisig(addr);
			await multisigManager.enableMultisig(addr);
		} catch (e) {
			log(`Error: ${e}`);
		}
		const ms = await multisigManager.getNextActiveMultisig();
		log(`Multisig Registered: ${ms}`);
	});

task("multisig:requireValidSignature", "Example for how to sign things")
	.addParam("pk", "private key")
	.setAction(async ({ pk }) => {
		const key = new hre.ethers.utils.SigningKey(pk);
		const addr = hre.ethers.utils.computeAddress(key.publicKey);
		const msg = "Woot!";
		const msgBytes = hre.ethers.utils.toUtf8Bytes(msg);
		const msgDigest = hre.ethers.utils.keccak256(msgBytes);
		const sig = key.signDigest(msgDigest).compact;

		const multisigManager = await get("MultisigManager");
		try {
			await multisigManager.requireValidSignature(addr, msgDigest, sig);
		} catch (e) {
			log("error", e);
		}
		log("Success! ", sig);
	});
