import { ethers, upgrades } from "hardhat";

const upgrade = async () => {
	const proxyAddress = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";

	const Token = await ethers.getContractFactory("TokenggAVAX");
	const proxy = await upgrades.upgradeProxy(proxyAddress, Token);

	console.log(`Token contract upgraded`);
	console.log(`Proxy address: ${proxy.address}`);
	console.log(
		`Implementation address: ${await upgrades.erc1967.getImplementationAddress(
			proxy.address
		)}`
	);
};

upgrade()
	.then(() => {
		console.log("Done!");
	})
	.catch((error) => {
		console.error(error);
		throw error;
	});
