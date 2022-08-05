/* eslint-disable no-undef */
// hardhat ensures hre is always in scope, no need to require
const { task } = require("hardhat/config");
const {
	addrs,
	get,
	hash,
	log,
	logf,
	getNamedAccounts,
	now,
	nodeID,
	nodeHexToID,
} = require("./lib/utils");

task(
	"debug:setup",
	"Run after a local deploy to init necessary configs"
).setAction(async () => {
	log("ProtocolDAO initialize()");
	const dao = await get("ProtocolDAO");
	const oneinch = await get("OneInchMock");
	await dao.initialize();
	await hre.run("oracle:set_ggp", { price: "1" });
	await hre.run("oracle:set_oneinch", {
		addr: oneinch.address,
	});
	await hre.run("multisig:register", { name: "rialto1" });
});

task("debug:skip", "Skip forward a duration")
	.addParam("duration", "")
	.setAction(async ({ duration }) => {
		await hre.run("setTimeIncrease", { delta: duration });
		await hre.run("mine");
	});

task("debug:topup_actor_balance")
	.addParam("actor", "")
	.addParam("amt", "")
	.setAction(async ({ actor, amt }) => {
		const actors = await getNamedAccounts();
		const signer = actors.deployer;
		const a = actors[actor];
		const balAVAX = await hre.ethers.provider.getBalance(a.address);
		const desiredBalAVAX = ethers.utils.parseEther(amt, "ether");
		if (balAVAX.lt(desiredBalAVAX)) {
			log(`Topping up ${actor}`);
			await signer.sendTransaction({
				to: a.address,
				value: desiredBalAVAX.sub(balAVAX),
			});
		}
	});

task("debug:topup_actor_balances")
	.addParam("amt", "")
	.setAction(async ({ amt }) => {
		const actors = await getNamedAccounts();
		for (actor in actors) {
			await hre.run("debug:topup_actor_balance", { amt, actor });
		}
	});

task("debug:list_actor_balances").setAction(async () => {
	const actors = await getNamedAccounts();
	const ggAVAX = await get("TokenggAVAX");
	const ggp = await get("TokenGGP");

	log("");
	logf(
		"%-15s %-20s %-20s %-20s %-20s",
		"User",
		"AVAX",
		"ggAVAX",
		"equivAVAX",
		"GGP"
	);
	for (actor in actors) {
		const balAVAX = await hre.ethers.provider.getBalance(actors[actor].address);
		const balGGAVAX = await ggAVAX.balanceOf(actors[actor].address);
		const balEQAVAX = await ggAVAX.previewRedeem(balGGAVAX);
		const balGGP = await ggp.balanceOf(actors[actor].address);
		logf(
			"%-15s %-20.5f %-20.5f %-20.5f %-20.5f",
			actor,
			hre.ethers.utils.formatUnits(balAVAX),
			hre.ethers.utils.formatUnits(balGGAVAX),
			hre.ethers.utils.formatUnits(balEQAVAX),
			hre.ethers.utils.formatUnits(balGGP)
		);
	}
});

task("debug:list_vars", "List important system variables").setAction(
	async () => {
		const curTs = await now();
		log(`Current block.timestamp: ${curTs}`);

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
			"%-15s %-15.5f %-15.5f %-15.5f %-15.5f %-15.5f",
			rewardsCycleEnd,
			hre.ethers.utils.formatUnits(lastRewardAmount),
			hre.ethers.utils.formatUnits(networkTotalAssets),
			hre.ethers.utils.formatUnits(stakingTotalAssets),
			hre.ethers.utils.formatUnits(amountAvailableForStaking),
			hre.ethers.utils.formatUnits(totalAssets)
		);

		log("");
		const oracle = await get("Oracle");
		const oracleResults = await oracle.getGGPPrice();
		const ggpPrice = await oracleResults.price;
		const ggpTs = await oracleResults.timestamp;
		log(
			`Oracle GGP Price: ${hre.ethers.utils.formatUnits(ggpPrice)} at ${ggpTs}`
		);
	}
);

task(
	"debug:list_contracts",
	"List all contracts that are registered in storage and refresh ./cache/deployed_addrs_[network].json"
).setAction(async () => {
	const storage = await get("Storage");
	for (const name in addrs) {
		try {
			const address = await storage.getAddress(
				hash(["string", "string"], ["contract.address", name])
			);
			const n = await storage.getString(
				hash(["string", "address"], ["contract.name", address])
			);
			const exists = await storage.getBool(
				hash(["string", "address"], ["contract.exists", address])
			);
			const emoji = exists && n === name ? "✅" : "(Not Registered)";
			if (address !== hre.ethers.constants.AddressZero) {
				logf("%-20s %-30s %s", name, address, emoji);
				addrs[name] = address; // update local cache with whats in storage
			} else {
				logf("%-20s %-30s", name, addrs[name]);
			}
		} catch (e) {
			log("error", e);
		}
	}
});

task("debug:node_ids")
	.addParam("name", "either NodeID-123, 0x123, or a name like 'node1'")
	.setAction(async ({ name }) => {
		addr = nodeID(name);
		out = {
			nodeAddr: addr,
			nodeID: nodeHexToID(addr),
		};
		console.log(JSON.stringify(out));
	});

// Take pks we are using for ANR and make a standard JSON all tools can use
task("debug:output_named_users").setAction(async () => {
	users = {
		deployer: {
			pk: "0x56289e99c94b6912bfc12adc093c9b51124f0dc54ac7a766b2bc5ccf558d8027",
			addr: "",
		},
		alice: {
			pk: "0x7b4198529994b0dc604278c99d153cfd069d594753d471171a1d102a10438e07",
			addr: "",
		},
		bob: {
			pk: "0x15614556be13730e9e8d6eacc1603143e7b96987429df8726384c2ec4502ef6e",
			addr: "",
		},
		cam: {
			pk: "0x31b571bf6894a248831ff937bb49f7754509fe93bbd2517c9c73c4144c0e97dc",
			addr: "",
		},
		nodeOp1: {
			pk: "0x6934bef917e01692b789da754a0eae31a8536eb465e7bff752ea291dad88c675",
			addr: "",
		},
		nodeOp2: {
			pk: "0xe700bdbdbc279b808b1ec45f8c2370e4616d3a02c336e68d85d4668e08f53cff",
			addr: "",
		},
		rialto1: {
			pk: "0xbbc2865b76ba28016bc2255c7504d000e046ae01934b04c694592a6276988630",
			addr: "",
		},
		rialto2: {
			pk: "0xcdbfd34f687ced8c6968854f8a99ae47712c4f4183b78dcc4a903d1bfe8cbf60",
			addr: "",
		},
		rewarder: {
			pk: "0x86f78c5416151fe3546dece84fda4b4b1e36089f2dbc48496faf3a950f16157c",
			addr: "",
		},
	};
	Object.keys(users).forEach((n) => {
		s = new ethers.Wallet(users[n].pk, hre.ethers.provider);
		users[n].addr = s.address;
	});
	console.log(JSON.stringify(users, null, 2));
});
