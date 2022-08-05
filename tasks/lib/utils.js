/* eslint-disable no-undef */
const { sprintf } = require("sprintf-js");
const ms = require("ms");

// Take NodeID-P7oB2McjBGgW2NXXWVYjV8JEDFoW9xDE5 and return 0xF29Bce5F34a74301eB0dE716d5194E4a4aEA5d7A
const { BinTools } = require("avalanche");
const bintools = BinTools.getInstance();
const nodeIDToHex = (pk) => {
	if (!pk.startsWith("NodeID-")) {
		throw new Error("Error: nodeID must start with 'NodeID-'");
	}
	const pksplit = pk.split("-");
	buff = bintools.cb58Decode(pksplit[pksplit.length - 1]);
	return ethers.utils.getAddress(ethers.utils.hexlify(buff));
};

// Take 0xF29Bce5F34a74301eB0dE716d5194E4a4aEA5d7A and return NodeID-P7oB2McjBGgW2NXXWVYjV8JEDFoW9xDE5
const nodeHexToID = (h) => {
	b = ethers.utils.arrayify(ethers.utils.getAddress(h));
	return `NodeID-${bintools.cb58Encode(b)}`;
};

const PAGE_SIZE = 2;

const log = (...args) => console.log(...args);
const logf = (...args) => console.log(sprintf(...args));
const logtx = async (tx) => {
	const r = await tx.wait();
	console.log(`Tx: ${r.transactionHash}  Gas: ${r.gasUsed}`);
};

// Only load the deployed contract addrs if they exist
let addrs = {};
try {
	const name = `../../cache/deployed_addrs_${
		process.env.HARDHAT_NETWORK || "localhost"
	}`;
	// eslint-disable-next-line node/no-missing-require
	addrs = require(name);
} catch {
	console.log(
		`Unable to require file cache/deployed_addrs_${
			process.env.HARDHAT_NETWORK || "localhost"
		}.js`
	);
}

// Actual nodeID or random addresses to use for nodeIDs
const nodeID = (seed) => {
	if (seed.startsWith("NodeID-")) {
		return nodeIDToHex(seed);
	} else if (seed.startsWith("0x")) {
		return ethers.utils.getAddress(seed);
	} else {
		return emptyWallet(seed).address;
	}
};

const emptyWallet = (seed) => {
	const pk = randomBytes(seed, 32);
	const w = new ethers.Wallet(pk);
	return w;
};

const getNamedAccounts = async () => {
	const names = [
		"deployer",
		"alice",
		"bob",
		"cam",
		"nodeOp1",
		"nodeOp2",
		"rialto1",
		"rialto2",
		"rewarder",
		"rialto",
	];
	const obj = {};
	const signers = await hre.ethers.getSigners();
	for (i in names) {
		obj[names[i]] = signers[i];
	}
	// A real Rialto address
	// const rialto = new ethers.VoidSigner(process.env.RIALTO, hre.ethers.provider);
	// obj.rialto = rialto;
	return obj;
};

const get = async (name, signer) => {
	// Default to using the deployer account
	if (signer === undefined) {
		signer = (await getNamedAccounts()).deployer;
	}
	const fac = await ethers.getContractFactory(name, signer);
	return fac.attach(addrs[name]);
};

// ANR fails lots of txs with gaslimit estimation errors, so override here
const overrides = {
	gasLimit: 8000000,
};

const hash = (types, vals) => {
	const h = ethers.utils.solidityKeccak256(types, vals);
	// console.log(types, vals, h);
	return h;
};

function logMinipools(minipools) {
	log("===== MINIPOOLS =====");
	logf(
		"%-42s %-6s %-12s %-12s %-10s %-10s %-10s %-10s %-10s %-10s %-67s %-10s %-10s %-10s %-10s",
		"nodeID",
		"status",
		"owner",
		"multisig",
		"avaxNopAmt",
		"avaxUsrAmt",
		"delFee",
		"dur",
		"start",
		"end",
		"txID",
		"totRwds",
		"nopRwds",
		"usrRwds",
		"ggpSlashAmt"
	);
	for (mp of minipools) {
		logf(
			"%-42s %-6s %-12s %-12s %-10s %-10s %-10s %-10s %-10s %-10s %-67s %-10.6f %-10.6f %-10.6f %-10.6f",
			mp.nodeID,
			mp.status,
			formatAddr(mp.owner),
			formatAddr(mp.multisigAddr),
			hre.ethers.utils.formatUnits(mp.avaxNodeOpAmt),
			hre.ethers.utils.formatUnits(mp.avaxUserAmt),
			mp.delegationFee,
			mp.duration,
			mp.startTime,
			mp.endTime,
			mp.txID,
			hre.ethers.utils.formatUnits(mp.avaxTotalRewardAmt),
			hre.ethers.utils.formatUnits(mp.avaxNodeOpRewardAmt),
			hre.ethers.utils.formatUnits(mp.avaxUserRewardAmt),
			hre.ethers.utils.formatUnits(mp.ggpSlashAmt)
		);
	}
}

// if dict is the result of getNamedAccounts() it will print friendly names
const formatAddr = (addr, dict = {}) => {
	let abbr;
	for (n in dict) {
		if (addr === dict[n].address) {
			abbr = n;
		}
	}
	if (abbr === undefined && addr) {
		abbr = addr.substring(0, 6) + ".." + addr.substring(addr.length - 4);
	}
	return abbr;
};

async function getMinipoolsFor(status, addr) {
	const minipoolManager = await get("MinipoolManager");
	const totalCount = await minipoolManager.getMinipoolCount();
	const totalPages = parseInt(totalCount / PAGE_SIZE) + 1;

	const minipools = [];

	// Use pagination to grab all minipools
	for (let page = 0; page < totalPages; page++) {
		try {
			const mps = await minipoolManager.getMinipools(
				status,
				page * PAGE_SIZE,
				PAGE_SIZE
			);
			for (mp of mps) {
				if (addr === undefined || mp.multisigAddr === addr) {
					minipools.push(mp);
				}
			}
		} catch (e) {
			log("error", e);
		}
	}

	return minipools;
}

// NOT really random, only used for generating test data
function randomBytes(seed, lower, upper) {
	if (!upper) {
		upper = lower;
	}

	if (upper === 0 && upper === lower) {
		return new Uint8Array(0);
	}

	let result = ethers.utils.arrayify(
		ethers.utils.keccak256(ethers.utils.toUtf8Bytes(seed))
	);
	while (result.length < upper) {
		result = ethers.utils.concat([result, ethers.utils.keccak256(result)]);
	}

	const top = ethers.utils.arrayify(ethers.utils.keccak256(result));
	const percent = ((top[0] << 16) | (top[1] << 8) | top[2]) / 0x01000000;

	return result.slice(0, lower + Math.floor((upper - lower) * percent));
}

function randomHexString(seed, lower, upper) {
	return ethers.utils.hexlify(randomBytes(seed, lower, upper));
}

function randomNumber(seed, lower, upper) {
	const top = randomBytes(seed, 3);
	const percent = ((top[0] << 16) | (top[1] << 8) | top[2]) / 0x01000000;
	return lower + Math.floor((upper - lower) * percent);
}

function parseDelta(delta) {
	const deltaInSeconds = Number.isNaN(Number(delta))
		? ms(delta) / 1000
		: Number(delta);

	if (!Number.isInteger(deltaInSeconds))
		throw new Error("cannot be called with a non integer value");
	if (deltaInSeconds < 0)
		throw new Error("cannot be called with a negative value");
	return deltaInSeconds;
}

async function now() {
	const b = await hre.network.provider.send("eth_getBlockByNumber", [
		"latest",
		false,
	]);
	return hre.ethers.BigNumber.from(b.timestamp);
}

module.exports = {
	addrs,
	get,
	overrides,
	hash,
	log,
	logf,
	logtx,
	logMinipools,
	formatAddr,
	getNamedAccounts,
	getMinipoolsFor,
	nodeID,
	randomBytes,
	randomHexString,
	randomNumber,
	parseDelta,
	now,
	nodeIDToHex,
	nodeHexToID,
};
