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

const get = async (name) => {
	const fac = await ethers.getContractFactory(name);
	return fac.attach(addrs[name]);
};

const hash = (types, vals) => {
	const h = ethers.utils.solidityKeccak256(types, vals);
	// console.log(types, vals, h);
	return h;
};

const log = (...args) => console.log(...args);
const logf = (...args) => console.log(sprintf(...args));

const formatAddr = (addr) =>
	addr.substring(0, 6) + ".." + addr.substring(addr.length - 4);

module.exports = {
	addrs,
	get,
	hash,
	log,
	logf,
	formatAddr,
};