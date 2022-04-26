import { assert, expect } from "chai";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import web3 from "web3";

// need to finish writing deploy routine
const deployTestGGPToken = async () => {
	const Storage = await ethers.getContractFactory("Storage");
	const storage = await Storage.deploy();
	await storage.deployed();

	const GGP = await ethers.getContractFactory("TokenGGP");
	const ggp = await GGP.deploy(storage.address);
	await ggp.deployed();
};

// need to write unit tests
