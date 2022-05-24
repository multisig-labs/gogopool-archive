/* eslint-disable no-undef */
const { sprintf } = require("sprintf-js");

// Only load the deployed contract addrs if they exist
let addrs = {};
try {
	// eslint-disable-next-line node/no-missing-require
	addrs = require("../../cache/deployed_addrs");
} catch {
	console.log("Unable to require file cache/deployed_addrs.js");
}

// Random addresses to use for nodeIDs
const nodeIDs = {
	node1: "0xA34754a5F069ca9c79593A739fd1A78eE62B0388",
	node2: "0xA5dA1f19DC5C530182D51507a0FaB38a5436Ddc9",
};

const getNamedAccounts = async () => {
	const names = [
		"alice",
		"bob",
		"cam",
		"nodeOp1",
		"nodeOp2",
		"rialto",
		"deployer",
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

// if dict is the result of getNamedAccounts() it will print friendly names
const formatAddr = (addr, dict = {}) => {
	let abbr;
	for (n in dict) {
		if (addr === dict[n].address) {
			abbr = n;
		}
	}
	if (abbr === undefined) {
		abbr = addr.substring(0, 6) + ".." + addr.substring(addr.length - 4);
	}
	return abbr;
};

module.exports = {
	addrs,
	get,
	hash,
	log,
	logf,
	formatAddr,
	getNamedAccounts,
	nodeIDs,
};
