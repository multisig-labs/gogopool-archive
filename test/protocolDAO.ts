import { assert, expect } from "chai";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import web3 from "web3";

const deployTestProtocolDAO = async () => {
	const Storage = await ethers.getContractFactory("Storage");
	const storage = await Storage.deploy();
	await storage.deployed();

	const ProtocolDAO = await ethers.getContractFactory("ProtocolDAO");
	const protocolDAO = await ProtocolDAO.deploy(storage.address);
	await protocolDAO.deployed();

	const boolStorageKey = web3.utils.soliditySha3(
		web3.utils.encodePacked("contract.exists", protocolDAO.address) as string
	);

	const addressStorageKey = web3.utils.soliditySha3(
		web3.utils.encodePacked("contract.address", "protocolDAO") as string
	);

	// set the protocol address to exist
	// and set its address in storage.
	await storage.setBool(boolStorageKey as string, true);
	await storage.setAddress(addressStorageKey as string, protocolDAO.address);

	// run the initializer function on the dao
	await protocolDAO.initialize();

	return { protocolDAO, storage };
};

describe("ProtocolDAO", function () {
	it("Should deploy.", async () => {
		await deployTestProtocolDAO();
	});
	it("Should be able to get inflation parameters", async () => {
		const { protocolDAO } = await deployTestProtocolDAO();

		const inflationIntervalRate = await protocolDAO.getInflationIntervalRate();

		const expectedInflationIntervalRate = BigNumber.from("1000133680617113500");

		expect(inflationIntervalRate).to.equal(expectedInflationIntervalRate);

		const inflationIntervalStartTime =
			await protocolDAO.getInflationIntervalStartTime();

		assert(
			inflationIntervalStartTime.gt(BigNumber.from("0")),
			"Inflation interval start time is not greater than 0"
		);
	});
});
