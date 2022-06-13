/* eslint-disable no-undef */
// hardhat ensures hre is always in scope, no need to require
const { get, log, parseDelta } = require("./lib/utils");

task("oracle:set_ggp", "")
	.addParam("price", "price of GGP in AVAX")
	.addParam("timestamp", "timestamp", 0, types.int)
	.addParam("interval", "i.e. 4h from last timestamp", "")
	.setAction(async ({ price, init, timestamp, interval }) => {
		log(`GGP Price set to ${price} AVAX`);
		const priceParsed = ethers.utils.parseEther(price, "ether");

		const oracle = await get("Oracle");
		if (timestamp === 0 && interval === "") {
			// init price
			await oracle.setGGP(priceParsed, 0);
			return;
		}

		if (timestamp === 0) {
			const results = await oracle.getGGP();
			const lastTimestamp = results.timestamp;
			timestamp = lastTimestamp + parseDelta(interval);
		}
		await oracle.setGGP(priceParsed, timestamp);
	});

task("oracle:get_ggp", "").setAction(async () => {
	const oracle = await get("Oracle");
	const results = await oracle.getGGP();
	log(
		`GGP Price: ${ethers.utils.formatEther(results.price)} Timestamp: ${
			results.timestamp
		}`
	);
});
