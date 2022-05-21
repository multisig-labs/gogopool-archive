/* eslint-disable no-undef */
// hardhat ensures hre is always in scope, no need to require
const { get, hash, formatAddr, log } = require("./lib/utils");
const MAX_ENTRIES = 10;

task("minipool:list", "List all minipools").setAction(async () => {
	const minipoolManager = await get("MinipoolManager");
	log(
		"%-42s %-6s %-8s %-8s %-7s %-7s %-12s %-12s",
		"nodeID",
		"status",
		"dur",
		"fee",
		"ggp",
		"avax",
		"owner",
		"multisig"
	);
	for (let i = 0; i < MAX_ENTRIES; i++) {
		try {
			const {
				nodeID,
				status,
				duration,
				delegationFee,
				ggpBondAmt,
				avaxAmt,
				owner,
				multisigAddr,
			} = await minipoolManager.getMinipool(i);
			if (nodeID === hre.ethers.constants.AddressZero) break;
			log(
				"%-42s %-6d %-8d %-8d %-7s %-7s %-12s %-12s",
				nodeID,
				status.toNumber(),
				duration.toNumber(),
				delegationFee.toNumber(),
				ethers.utils.formatUnits(ggpBondAmt),
				ethers.utils.formatUnits(avaxAmt),
				formatAddr(owner),
				formatAddr(multisigAddr)
			);
		} catch (e) {
			console.log("error", e);
		}
	}
});

task("minipool:queue", "List all minipools in the queue").setAction(
	async () => {
		const storage = await get("Storage");
		const start = await storage.getUint(
			hash(["string"], ["minipoolqueue.start"])
		);
		const end = await storage.getUint(hash(["string"], ["minipoolqueue.end"]));
		const minipoolQueue = await get("MinipoolQueue");
		const len = await minipoolQueue.getLength();
		console.log(`Queue start: ${start}  end: ${end}  len: ${len}`);
		for (let i = start; i < end; i++) {
			try {
				const nodeID = await minipoolQueue.getItem(i);
				if (nodeID === hre.ethers.constants.AddressZero) break;
				console.log(`[${i}] ${nodeID}`);
			} catch (e) {
				console.log("error", e);
			}
		}
	}
);

task("minipool:create", "")
	.addParam("nodeid", "NodeID")
	.addParam("duration", "Duration (in seconds)", 100000, types.int)
	.addParam("fee", "", 0, types.int)
	.addParam("ggp", "", 0, types.int)
	.addParam("avax", "Amt of AVAX to send (units are AVAX)", 2000, types.int)
	.setAction(async ({ nodeid, duration, fee, ggp, avax }) => {
		const minipoolManager = await get("MinipoolManager");
		await minipoolManager.createMinipool(
			nodeid,
			duration,
			fee,
			hre.ethers.utils.parseEther(ggp.toString()),
			{
				value: hre.ethers.utils.parseEther(avax.toString()),
			}
		);
		log(`Minipool created for nodeID: ${nodeid}`);
	});

task("minipool:add_avax", "")
	.addParam("nodeid", "NodeID")
	.addParam("amt", "AVAX amount")
	.setAction(async ({ nodeid, amt }) => {
		const minipoolManager = await get("MinipoolManager");
		await minipoolManager.updateMinipoolStatus(nodeid, status);
	});

task("minipool:update_status", "")
	.addParam("nodeid", "NodeID")
	.addParam("status", "", 0, types.int)
	.setAction(async ({ nodeid, status }) => {
		const minipoolManager = await get("MinipoolManager");
		await minipoolManager.updateMinipoolStatus(nodeid, status);
		log(`Minipool status updated to ${status} for ${nodeid}`);
	});

task("minipool:claim", "")
	.addParam("pk", "private key of minipool")
	.addParam("nodeid", "NodeID")
	.setAction(async ({ nodeid, pk }) => {
		// const key = new hre.ethers.utils.SigningKey(pk);
		// const addr = hre.ethers.utils.computeAddress(key.publicKey);

		let minipoolManager = await get("MinipoolManager");
		const wallet = new hre.ethers.Wallet(pk, minipoolManager.provider);
		minipoolManager = minipoolManager.connect(wallet);
		// const nonce = await minipoolManager.getNonce(addr);
		// TODO This is diff than what the solidity func returns?
		// const h = hash(
		// 	["address", "address", "uint256"],
		// 	[addrs.MinipoolManager, addr, nonce.toNumber()]
		// );
		// const h2 = await minipoolManager.formatClaimMessageHash(addr);
		// const msgHash = hre.ethers.utils.hashMessage(h2);
		// const sig = key.signDigest(h2).compact;
		await minipoolManager.claimAndInitiateStaking(nodeid, {
			gasPrice: 17150404,
			gasLimit: 3000000,
		});
		log(`Minipool claimed for ${nodeid}`);
	});
