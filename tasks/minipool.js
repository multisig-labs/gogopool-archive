/* eslint-disable no-undef */
// hardhat ensures hre is always in scope, no need to require
const {
	get,
	hash,
	formatAddr,
	log,
	logf,
	nodeIDs,
	getNamedAccounts,
} = require("./lib/utils");
const MAX_ENTRIES = 10;

task("minipool:list", "List all minipools").setAction(async () => {
	const accounts = await getNamedAccounts();
	const minipoolManager = await get("MinipoolManager");
	logf(
		"%-13s %-6s %-8s %-8s %-8s %-8s %-15s %-15s %-15s %-18s %-19s %-19s %-8s %-8s",
		"nodeID",
		"status",
		"dur",
		"start",
		"end",
		"fee",
		"ggpBondAmt",
		"avaxNodeOpAmt",
		"avaxUserAmt",
		"avaxTotalRewardAmt",
		"avaxNodeOpRewardAmt",
		"avaxUserRewardAmt",
		"owner",
		"multisig"
	);
	for (let i = 0; i < MAX_ENTRIES; i++) {
		try {
			const {
				nodeID,
				status,
				duration,
				startTime,
				endTime,
				delegationFee,
				ggpBondAmt,
				avaxNodeOpAmt,
				avaxUserAmt,
				avaxTotalRewardAmt,
				avaxNodeOpRewardAmt,
				avaxUserRewardAmt,
				owner,
				multisigAddr,
			} = await minipoolManager.getMinipool(i);
			if (nodeID === hre.ethers.constants.AddressZero) break;
			logf(
				"%-13s %-6s %-8s %-8s %-8s %-8s %-15s %-15s %-15s %-18s %-19s %-19s %-8s %-8s",
				formatAddr(nodeID),
				status.toNumber(),
				duration.toNumber(),
				startTime.toNumber(),
				endTime.toNumber(),
				delegationFee.toNumber(),
				ethers.utils.formatUnits(ggpBondAmt),
				ethers.utils.formatUnits(avaxNodeOpAmt),
				ethers.utils.formatUnits(avaxUserAmt),
				ethers.utils.formatUnits(avaxTotalRewardAmt),
				ethers.utils.formatUnits(avaxNodeOpRewardAmt),
				ethers.utils.formatUnits(avaxUserRewardAmt),
				formatAddr(owner, accounts),
				formatAddr(multisigAddr, accounts)
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
		log(`Queue start: ${start}  end: ${end}  len: ${len}`);
		for (let i = start; i < end; i++) {
			try {
				const nodeID = await minipoolQueue.getItem(i);
				if (nodeID === hre.ethers.constants.AddressZero) break;
				log(`[${i}] ${nodeID}`);
			} catch (e) {
				log("error", e);
			}
		}
	}
);

task("minipool:create", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name")
	.addParam("duration", "Duration (in seconds)", 100000, types.int)
	.addParam("fee", "", 0, types.int)
	.addParam("ggp", "", "0")
	.addParam("avax", "Amt of AVAX to send (units are AVAX)", "2000")
	.setAction(async ({ actor, node, duration, fee, ggp, avax }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		await minipoolManager.createMinipool(
			nodeIDs[node],
			duration,
			fee,
			hre.ethers.utils.parseEther(ggp),
			{
				value: hre.ethers.utils.parseEther(avax),
			}
		);
		log(`Minipool created for node ${node}: ${nodeIDs[node]}`);
	});

task("minipool:add_avax", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name")
	.addParam("amt", "AVAX amount")
	.setAction(async ({ actor, node, amt }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		await minipoolManager.updateMinipoolStatus(nodeIDs[node], status);
	});

task("minipool:update_status", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name")
	.addParam("status", "", 0, types.int)
	.setAction(async ({ actor, node, status }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		await minipoolManager.updateMinipoolStatus(nodeIDs[node], status);
		log(`Minipool status updated to ${status} for ${node}`);
	});

task("minipool:cancel", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name")
	.setAction(async ({ actor, node }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		await minipoolManager.cancelMinipool(nodeIDs[node]);
		log(`Minipool canceled`);
	});

task("minipool:claim", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name")
	.setAction(async ({ actor, node }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		await minipoolManager.claimAndInitiateStaking(nodeIDs[node], {
			gasPrice: 18000000,
			gasLimit: 3000000,
		});
		log(`Minipool claimed for ${node}`);
	});

task("minipool:recordStakingStart", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name")
	.addParam("start", "staking start time")
	.setAction(async ({ actor, node, start }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		await minipoolManager.recordStakingStart(nodeIDs[node], start);
	});

task("minipool:recordStakingEnd", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name")
	.addParam("end", "staking end time")
	.addParam("avax", "AVAX amount to return (excluding rewards)", 0, types.int)
	.addParam("reward", "AVAX Reward amount", 0, types.int)
	.setAction(async ({ actor, node, end, avax, reward }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		await minipoolManager.recordStakingEnd(
			nodeIDs[node],
			end,
			hre.ethers.utils.parseEther(reward.toString()),
			{
				value: hre.ethers.utils.parseEther((avax + reward).toString()),
			}
		);
	});

task("minipool:withdrawMinipoolFunds", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name")
	.setAction(async ({ actor, node }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		await minipoolManager.withdrawMinipoolFunds(nodeIDs[node]);
	});
