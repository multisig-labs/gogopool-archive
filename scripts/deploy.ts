import "@openzeppelin/hardhat-upgrades";
import { ethers, upgrades, network } from "hardhat";
import { writeFile } from "node:fs/promises";
import * as fs from "fs";

const { getNamedAccounts } = require("../tasks/lib/utils");

// DO NOT USE FOR PRODUCTION
// This will deploy the contracts to the local network

type IFU = { [key: string]: any };

if (
	!fs.existsSync(`cache/deployed_addrs_${process.env.HARDHAT_NETWORK}.json`)
) {
	throw new Error("You need to run 'deploy-base' first!");
}
const addresses = require(`../cache/deployed_addrs_${process.env.HARDHAT_NETWORK}`);

const instances: IFU = {};

// ContractName: [constructorArgs...]
const contracts: IFU = {
	Oracle: ["Storage"],
	ProtocolDAO: ["Storage"],
	MultisigManager: ["Storage"],
	TokenGGP: ["Storage"],
	TokenggAVAX: ["Storage", "WAVAX"],
	MinipoolManager: ["Storage", "TokenGGP", "TokenggAVAX"],
	RewardsPool: ["Storage"],
	NOPClaim: ["Storage"],
	Staking: ["Storage", "TokenGGP"],
	ProtocolDAOClaim: ["Storage"],
	ProtocolDAOSettingsInflation: ["Storage"],
};

const deployAsProxy = ["TokenggAVAX"];

const hash = (types: any, vals: any) => {
	const h = ethers.utils.solidityKeccak256(types, vals);
	return h;
};

const get = async (name: string, signer: any) => {
	// Default to using the deployer account
	if (signer === undefined) {
		signer = (await getNamedAccounts()).deployer;
	}
	const fac = await ethers.getContractFactory(name, signer);
	return fac.attach(addresses[name]);
};

const deploy = async () => {
	const toDeploy = process.env.DEPLOY_CONTRACTS
		? process.env.DEPLOY_CONTRACTS.split(",")
		: Object.keys(contracts);
	const { deployer } = await getNamedAccounts();
	instances.Storage = await get("Storage", deployer);
	console.log(`Network: ${network.name}`);
	console.log(`Deploying contracts as (${deployer.address})`);
	for (const contract of toDeploy) {
		const args = [];
		for (const name of contracts[contract]) {
			args.push(addresses[name]);
		}

		console.log(`Deploying ${contract} with args ${args}...`);
		const C = await ethers.getContractFactory(contract, deployer);
		let c;
		if (deployAsProxy.includes(contract)) {
			// TODO need to use upgrades.upgradeProxy here if it has already been deployed.
			// TODO How to track deployments in prod? Make a /deployments dir and check it in?
			c = await upgrades.deployProxy(C, [...args]);
		} else {
			c = await C.deploy(...args);
		}
		const inst = await c.deployed();
		instances[contract] = inst;
		addresses[contract] = c.address;
		console.log(`${contract} deployed to: ${c.address}`);
	}

	let nonce = parseInt(
		await ethers.provider.send("eth_getTransactionCount", [
			deployer.address,
			"latest",
		])
	);

	// Register any contract with Storage as first constructor param
	for (const contract of toDeploy) {
		const store = instances.Storage;
		if (contracts[contract][0] === "Storage") {
			console.log(`Registering ${contract}`);
			await store.setAddress(
				hash(["string", "string"], ["contract.address", contract]),
				addresses[contract],
				{
					nonce: nonce++,
				}
			);
			await store.setBool(
				hash(["string", "address"], ["contract.exists", addresses[contract]]),
				true,
				{
					nonce: nonce++,
				}
			);
			await store.setString(
				hash(["string", "address"], ["contract.name", addresses[contract]]),
				contract,
				{
					nonce: nonce++,
				}
			);
		}
	}

	// Write out the deployed addresses to a format easily loaded by bash for use by cast
	let data = "declare -A addrs=(";
	for (const name in addresses) {
		data = data + `[${name}]="${addresses[name]}" `;
	}
	data = data + ")";
	await writeFile(`cache/deployed_addrs_${network.name}.bash`, data);

	// Write out the deployed addresses to a format easily loaded by javascript
	data = `module.exports = ${JSON.stringify(addresses, null, 2)}`;
	await writeFile(`cache/deployed_addrs_${network.name}.js`, data);

	// Write out the deployed addresses to json (used by Rialto during dev)
	data = JSON.stringify(addresses, null, 2);
	await writeFile(`cache/deployed_addrs_${network.name}.json`, data);
};

deploy()
	.then(() => {
		console.log("Done!");
		// eslint-disable-next-line no-process-exit
		process.exit(0);
	})
	.catch((error) => {
		console.error(error);
		throw error;
	});

// see https://stackoverflow.com/a/41975448/5178731
// for why I did this. - Chandler
export {};
