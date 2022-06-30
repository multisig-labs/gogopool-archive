import "@openzeppelin/hardhat-upgrades";
import { writeFile } from "node:fs/promises";
import { ethers, upgrades, network } from "hardhat";

const { getNamedAccounts } = require("../tasks/lib/utils");

// DO NOT USE FOR PRODUCTION
// This will deploy the contracts to the local network

type IFU = { [key: string]: any };

const addresses: IFU = {};
const instances: IFU = {};

// ContractName: [constructorArgs...]
const contracts: IFU = {
	Multicall: [],
	Storage: [],
	WAVAX: [],
	OneInchMock: [],
	Vault: ["Storage"],
	Oracle: ["Storage"],
	ProtocolDAO: ["Storage"],
	MultisigManager: ["Storage"],
	BaseQueue: ["Storage"],
	TokenGGP: ["Storage"],
	TokenggAVAX: ["Storage", "WAVAX"],
	MinipoolManager: ["Storage", "TokenGGP", "TokenggAVAX"],
};

const deployAsProxy = ["TokenggAVAX"];

const hash = (types: any, vals: any) => {
	const h = ethers.utils.solidityKeccak256(types, vals);
	// console.log(types, vals, h);
	return h;
};

const deploy = async () => {
	// Uncomment if running directly with node
	// await hre.run("compile");

	const { deployer } = await getNamedAccounts();
	console.log(`Network: ${network.name}`);
	console.log(`Deploying contracts as (${deployer.address})`);

	for (const contract in contracts) {
		const args = [];
		for (const name of contracts[contract]) {
			args.push(addresses[name]);
		}
		console.log(`Deploying ${contract} with args ${args}...`);
		const C = await ethers.getContractFactory(contract, deployer);
		let c;
		if (deployAsProxy.includes(contract)) {
			c = await upgrades.deployProxy(C, [...args]);
		} else {
			c = await C.deploy(...args);
		}
		const inst = await c.deployed();
		instances[contract] = inst;
		addresses[contract] = c.address;
		console.log(`${contract} deployed to: ${c.address}`);
	}

	// Register any contract with Storage as first constructor param
	for (const contract in contracts) {
		const store = instances.Storage;
		if (contracts[contract][0] === "Storage") {
			console.log(`Registering ${contract}`);
			await store.setAddress(
				hash(["string", "string"], ["contract.address", contract]),
				addresses[contract]
			);
			await store.setBool(
				hash(["string", "address"], ["contract.exists", addresses[contract]]),
				true
			);
			await store.setString(
				hash(["string", "address"], ["contract.name", addresses[contract]]),
				contract
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
	data = `module.exports = ${JSON.stringify(addresses)}`;
	await writeFile(`cache/deployed_addrs_${network.name}.js`, data);
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
