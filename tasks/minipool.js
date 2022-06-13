/* eslint-disable no-undef */
// hardhat ensures hre is always in scope, no need to require
const {
	get,
	hash,
	log,
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

task("minipool:queue", "List all minipools in the queue").setAction(
	async () => {
		const MINIPOOL_QUEUE_KEY = hash(["string"], ["minipoolQueue"]);

		const storage = await get("Storage");
		const start = await storage.getUint(
			hash(["bytes32", "string"], [MINIPOOL_QUEUE_KEY, ".start"])
		);
		const end = await storage.getUint(
			hash(["bytes32", "string"], [MINIPOOL_QUEUE_KEY, ".end"])
		);
		const minipoolQueue = await get("BaseQueue");
		const len = await minipoolQueue.getLength(MINIPOOL_QUEUE_KEY);
		log(`Queue start: ${start}  end: ${end}  len: ${len}`);
		for (let i = start; i < end; i++) {
			try {
				const nodeID = await minipoolQueue.getItem(MINIPOOL_QUEUE_KEY, i);
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
	.addParam("duration", "Duration", "14d", types.string)
	.addParam("fee", "", 0, types.int)
	.addParam("ggp", "", "0")
	.addParam("avax", "Amt of AVAX to send (units are AVAX)", "2000")
	.setAction(async ({ actor, node, duration, fee, ggp, avax }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		await minipoolManager.createMinipool(
			nodeID(node),
			parseDelta(duration),
			fee,
			hre.ethers.utils.parseEther(ggp),
			{
				value: hre.ethers.utils.parseEther(avax),
			}
		);
		log(`Minipool created for node ${node}: ${nodeID(node)}`);
	});

task("minipool:add_avax", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name")
	.addParam("amt", "AVAX amount")
	.setAction(async ({ actor, node, amt }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		await minipoolManager.updateMinipoolStatus(nodeID(node), status);
	});

task("minipool:update_status", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name")
	.addParam("status", "", 0, types.int)
	.setAction(async ({ actor, node, status }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		await minipoolManager.updateMinipoolStatus(nodeID(node), status);
		log(`Minipool status updated to ${status} for ${node}`);
	});

task("minipool:cancel", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name")
	.setAction(async ({ actor, node }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		await minipoolManager.cancelMinipool(nodeID(node));
		log(`Minipool canceled`);
	});

task("minipool:can_claim", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name")
	.setAction(async ({ actor, node }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		const res = await minipoolManager.canClaimAndInitiateStaking(nodeID(node), {
			gasPrice: 18000000,
			gasLimit: 3000000,
		});
		log(`Can claim ${node}: ${res}`);
	});

task("minipool:claim", "Claim minipools until funds run out")
	.addParam("actor", "Account used to send tx")
	.setAction(async ({ actor }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		const minipools = await getMinipoolsFor(0, signer.address); // 0=Prelaunch

		// Somehow Rialto will sort these by priority
		for (mp of minipools) {
			const canClaim = await minipoolManager.canClaimAndInitiateStaking(
				mp.nodeID
			);
			if (canClaim) {
				log(`Claiming ${mp.nodeID}`);
				await minipoolManager.claimAndInitiateStaking(mp.nodeID);
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
		await minipoolManager.claimAndInitiateStaking(nodeID(node), {
			gasPrice: 18000000,
			gasLimit: 3000000,
		});
		log(`Minipool claimed for ${node}`);
	});

task("minipool:recordStakingStart", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name")
	.addParam("start", "staking start time", 0, types.int)
	.setAction(async ({ actor, node, start }) => {
		if (start === 0) {
			start = await now();
		}
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		await minipoolManager.recordStakingStart(nodeID(node), start);
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
		const tx = {
			to: signer.address,
			value: reward,
		};
		await rewarder.sendTransaction(tx);
		total = avax.add(reward);

		await minipoolManager.recordStakingEnd(nodeID(node), end, reward, {
			value: total,
		});
	});

task("minipool:withdrawMinipoolFunds", "")
	.addParam("actor", "Account used to send tx")
	.addParam("node", "NodeID name")
	.setAction(async ({ actor, node }) => {
		const signer = (await getNamedAccounts())[actor];
		const minipoolManager = await get("MinipoolManager", signer);
		await minipoolManager.withdrawMinipoolFunds(nodeID(node));
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
