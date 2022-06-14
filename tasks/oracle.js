/* eslint-disable no-undef */
// hardhat ensures hre is always in scope, no need to require
const { get, log, parseDelta } = require("./lib/utils");

task("oracle:set_oneinch", "")
	.addParam("addr", "Address of One Inch price aggregator contract")
	.setAction(async ({ addr }) => {
		log(`OneInch addr: ${addr}`);
		const oracle = await get("Oracle");
		oracle.setOneInch(addr);
	});

task("oracle:get_ggp_price_oneinch", "").setAction(async () => {
	const oracle = await get("Oracle");
	const price = await oracle.getGGPPriceFromOneInch();
	log(`OneInch GGP Price: ${ethers.utils.formatEther(price)}`);
});

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
			await oracle.setGGPPrice(priceParsed, 0);
			return;
		}

		if (timestamp === 0) {
			const results = await oracle.getGGPPrice();
			const lastTimestamp = results.timestamp;
			timestamp = lastTimestamp + parseDelta(interval);
		}
		await oracle.setGGPPrice(priceParsed, timestamp);
	});

task("oracle:get_ggp", "").setAction(async () => {
	const oracle = await get("Oracle");
	const results = await oracle.getGGPPrice();
	log(
		`GGP Price: ${ethers.utils.formatEther(results.price)} Timestamp: ${
			results.timestamp
		}`
	);
});
