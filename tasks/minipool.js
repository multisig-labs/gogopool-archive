/* eslint-disable no-undef */
// hardhat ensures hre is always in scope, no need to require
const {
	get,
	overrides,
	hash,
	log,
	logtx,
	nodeID,
	getNamedAccounts,
	getMinipoolsFor,
	logMinipools,
	parseDelta,
	now,
} = require("./lib/utils");

task("minipool:list", "List all minipools").setAction(async () => {
	for (let status = 0; status < 5; status++) {
		const mps = await getMinipoolsFor(status);
		if (mps.length > 0) logMinipools(mps);
	}
});

task("minipool:list_claimable", "List all claimable minipools")
	.addParam("actor", "multisig name")
	.setAction(async ({ actor }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipools = await getMinipoolsFor(0, signer.address);

		// Somehow Rialto will sort these by priority
		logMinipools(minipools);
	});

// task("minipool:queue", "List all minipools in the queue").setAction(
// 	async () => {
// 		const MINIPOOL_QUEUE_KEY = hash(["string"], ["minipoolQueue"]);

// 		const storage = await get("Storage");
// 		const start = await storage.getUint(
// 			hash(["bytes32", "string"], [MINIPOOL_QUEUE_KEY, ".start"])
// 		);
// 		const end = await storage.getUint(
// 			hash(["bytes32", "string"], [MINIPOOL_QUEUE_KEY, ".end"])
// 		);
// 		const minipoolQueue = await get("BaseQueue");
// 		const len = await minipoolQueue.getLength(MINIPOOL_QUEUE_KEY);
// 		log(`Queue start: ${start}  end: ${end}  len: ${len}`);
// 		for (let i = start; i < end; i++) {
// 			try {
// 				const nodeID = await minipoolQueue.getItem(MINIPOOL_QUEUE_KEY, i);
// 				if (nodeID === hre.ethers.constants.AddressZero) break;
// 				log(`[${i}] ${nodeID}`);
// 			} catch (e) {
// 				log("error", e);
// 			}
// 		}
// 	}
// );

task("minipool:create", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "Real NodeID or name to use as a random seed")
	.addParam("duration", "Duration", "2m", types.string)
	.addParam("fee", "2% is 20,000", 20000, types.int)
	.addParam("avax", "Amt of AVAX to send (units are AVAX)", "1000")
	.addParam("avaxRequested", "Amt of AVAX to request (units are AVAX)", "1000")
	.setAction(async ({ actor, node, duration, fee, avax, avaxRequested }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		await minipoolManager.callStatic.createMinipool(
			nodeID(node),
			parseDelta(duration),
			fee,
			hre.ethers.utils.parseEther(avaxRequested),
			{ ...overrides, value: hre.ethers.utils.parseEther(avax) }
		);
		tx = await minipoolManager.createMinipool(
			nodeID(node),
			parseDelta(duration),
			fee,
			hre.ethers.utils.parseEther(avaxRequested),
			{ ...overrides, value: hre.ethers.utils.parseEther(avax) }
		);
		await logtx(tx);
		log(`Minipool created for node ${node}: ${nodeID(node)}`);
	});

task("minipool:update_status", "Force into a particular status")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name")
	.addParam("status", "", 0, types.int)
	.setAction(async ({ actor, node, status }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		tx = await minipoolManager.updateMinipoolStatus(nodeID(node), status);
		await logtx(tx);
		log(`Minipool status updated to ${status} for ${node}`);
	});

task("minipool:cancel", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name")
	.setAction(async ({ actor, node }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		tx = await minipoolManager.cancelMinipool(nodeID(node));
		await logtx(tx);
		log(`Minipool canceled`);
	});

task("minipool:can_claim", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name", "")
	.addParam("nodeaddr", "NodeID address", "")
	.setAction(async ({ actor, node, nodeaddr }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		const n = node === "" ? nodeaddr : nodeID(node);
		const res = await minipoolManager.canClaimAndInitiateStaking(n, overrides);
		log(`Can claim ${node}: ${res}`);
	});

task("minipool:claim", "Claim minipools until funds run out")
	.addParam("actor", "Account used to send tx")
	.setAction(async ({ actor }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);

		const prelaunchStatus = 0;
		const minipools = await getMinipoolsFor(prelaunchStatus, signer.address); // 0=Prelaunch

		if (minipools.length === 0) {
			console.log("no minpools to claim");
		}

		// Somehow Rialto will sort these by priority
		for (mp of minipools) {
			const canClaim = await minipoolManager.canClaimAndInitiateStaking(
				mp.nodeID,
				overrides
			);
			if (canClaim) {
				log(`Claiming ${mp.nodeID}`);
				tx = await minipoolManager.claimAndInitiateStaking(
					mp.nodeID,
					overrides
				);
				await logtx(tx);
			} else {
				log("Nothing to do or not enough user funds");
			}
		}
	});

task("minipool:claim_one", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name")
	.setAction(async ({ actor, node }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		let tx = await minipoolManager.callStatic.claimAndInitiateStaking(
			nodeID(node),
			overrides
		);
		tx = await minipoolManager.claimAndInitiateStaking(nodeID(node), overrides);
		await logtx(tx);
		log(`Minipool claimed for ${node}`);
	});

task("minipool:recordStakingStart", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name")
	.addParam("start", "staking start time", 0, types.int)
	.addParam("txid", "txid of AddValidatorTx", "", types.string)
	.setAction(async ({ actor, node, start, txid }) => {
		if (start === 0) {
			start = await now();
		}
		if (txid === "") {
			txid = hre.ethers.constants.HashZero;
		}
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		let tx = await minipoolManager.callStatic.recordStakingStart(
			nodeID(node),
			txid,
			start,
			overrides
		);
		tx = await minipoolManager.recordStakingStart(
			nodeID(node),
			txid,
			start,
			overrides
		);
		await logtx(tx);
	});

task("minipool:recordStakingEnd", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name")
	.addParam("reward", "AVAX Reward amount", 0, types.int)
	.setAction(async ({ actor, node, reward }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		const i = await minipoolManager.getIndexOf(nodeID(node));
		const mp = await minipoolManager.getMinipool(i);
		const end = mp.startTime.add(mp.duration);

		const avax = mp.avaxNodeOpAmt.add(mp.avaxUserAmt);

		reward = hre.ethers.utils.parseEther(reward.toString());
		// Send rialto the reward funds from some other address to simulate Avalanche rewards,
		// so we can see rialtos actual balance
		const rewarder = (await getNamedAccounts()).rewarder;
		let tx = {
			to: signer.address,
			value: reward,
		};
		await rewarder.sendTransaction(tx);
		total = avax.add(reward);

		tx = await minipoolManager.callStatic.recordStakingEnd(
			nodeID(node),
			end,
			reward,
			{
				...overrides,
				value: total,
			}
		);
		tx = await minipoolManager.recordStakingEnd(nodeID(node), end, reward, {
			...overrides,
			value: total,
		});
		await logtx(tx);
	});

task("minipool:withdrawMinipoolFunds", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name")
	.setAction(async ({ actor, node }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		tx = await minipoolManager.withdrawMinipoolFunds(nodeID(node));
		await logtx(tx);
	});

task("minipool:expected_reward", "")
	.addParam("duration", "duration of validation period")
	.addParam("amt", "AVAX amount")
	.setAction(async ({ duration, amt }) => {
		parsedAmt = ethers.utils.parseEther(amt, "ether");
		parsedDuration = parseDelta(duration);
		const minipoolManager = await get("MinipoolManager");
		const expectedAmt = await minipoolManager.expectedRewardAmt(
			parsedDuration,
			parsedAmt
		);
		log(
			`${amt} of AVAX staked for ${duration} should yield ${hre.ethers.utils.formatUnits(
				expectedAmt
			)} AVAX`
		);
	});

task("minipool:calculate_slash", "")
	.addParam("amt", "Expected AVAX reward amount")
	.setAction(async ({ amt }) => {
		parsedAmt = ethers.utils.parseEther(amt, "ether");
		console.log(parsedAmt);
		const minipoolManager = await get("MinipoolManager");
		const slashAmt = await minipoolManager.calculateSlashAmt(parsedAmt);
		log(
			`${amt} AVAX is equivalent to ${hre.ethers.utils.formatEther(
				slashAmt
			)} GGP at current prices`
		);
	});
