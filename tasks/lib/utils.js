/* eslint-disable no-undef */
const { sprintf } = require("sprintf-js");
const ms = require("ms");

const PAGE_SIZE = 2;

// Only load the deployed contract addrs if they exist
let addrs = {};
try {
	// eslint-disable-next-line node/no-missing-require
	addrs = require("../../cache/deployed_addrs");
} catch {
	console.log("Unable to require file cache/deployed_addrs.js");
}

// Random addresses to use for nodeIDs
const nodeID = (seed) => {
	return emptyWallet(seed).address;
};

const emptyWallet = (seed) => {
	const pk = randomBytes(seed, 32);
	const w = new ethers.Wallet(pk);
	return w;
};

const getNamedAccounts = async () => {
	const names = [
		"alice",
		"bob",
		"cam",
		"nodeOp1",
		"nodeOp2",
		"rialto1",
		"rialto2",
		"deployer",
		"rewarder",
	];
	const obj = {};
	const signers = await hre.ethers.getSigners();
	for (i in names) {
		obj[names[i]] = signers[i];
	}
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

const hash = (types, vals) => {
	const h = ethers.utils.solidityKeccak256(types, vals);
	// console.log(types, vals, h);
	return h;
};

const log = (...args) => console.log(...args);
const logf = (...args) => console.log(sprintf(...args));

function logMinipools(minipools) {
	log("===== MINIPOOLS =====");
	logf(
		"%-12s %-6s %-12s %-12s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s",
		"nodeID",
		"status",
		"owner",
		"multisig",
		"avaxNopAmt",
		"ggpBondAmt",
		"avaxUsrAmt",
		"delFee",
		"dur",
		"start",
		"end",
		"totRwds",
		"nopRwds",
		"usrRwds",
		"ggpSlashAmt"
	);
	for (mp of minipools) {
		logf(
			"%-12s %-6s %-12s %-12s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s",
			formatAddr(mp.nodeID),
			mp.status,
			formatAddr(mp.owner),
			formatAddr(mp.multisigAddr),
			hre.ethers.utils.formatUnits(mp.avaxNodeOpAmt),
			hre.ethers.utils.formatUnits(mp.ggpBondAmt),
			hre.ethers.utils.formatUnits(mp.avaxUserAmt),
			mp.delegationFee,
			mp.duration,
			mp.startTime,
			mp.endTime,
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
	hash,
	log,
	logf,
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
};
