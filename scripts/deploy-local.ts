const hre = require("hardhat");

// DO NOT USE FOR PRODUCTION
// This will deploy the contracts to the local network

const deploy = async () => {
	// Uncomment if running directly with node
	// await hre.run("compile");

	console.log("Deploying Multicall...");
	const Multicall = await hre.ethers.getContractFactory("Multicall");
	const multicall = await Multicall.deploy();
	await multicall.deployed();
	console.log("Multicall deployed to: ", multicall.address);

	console.log("Deploying Storage...");
	const Storage = await hre.ethers.getContractFactory("Storage");
	const storage = await Storage.deploy();
	await storage.deployed();
	console.log("Storage deployed to: ", storage.address);

	console.log("Deploying Vault...");
	const Vault = await hre.ethers.getContractFactory("Vault");
	const vault = await Vault.deploy(storage.address);
	await vault.deployed();
	console.log("Vault deployed to: ", vault.address);
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
