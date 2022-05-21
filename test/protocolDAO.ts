import { assert, expect } from "chai";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";

const deployTestProtocolDAO = async () => {
	const Storage = await ethers.getContractFactory("Storage");
	const storage = await Storage.deploy();
	await storage.deployed();

	const ProtocolDAO = await ethers.getContractFactory("ProtocolDAO");
	const protocolDAO = await ProtocolDAO.deploy(storage.address);
	await protocolDAO.deployed();

	const boolStorageKey = ethers.utils.solidityKeccak256(
		["string", "address"],
		["contract.exists", protocolDAO.address]
	);

	const addressStorageKey = ethers.utils.solidityKeccak256(
		["string", "string"],
		["contract.address", "protocolDAO"]
	);

	// set the protocol address to exist
	// and set its address in storage.
	await storage.setBool(boolStorageKey, true);
	await storage.setAddress(addressStorageKey, protocolDAO.address);

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
