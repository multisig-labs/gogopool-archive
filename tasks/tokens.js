/* eslint-disable no-undef */
// hardhat ensures hre is always in scope, no need to require
const { get, getNamedAccounts } = require("./lib/utils");

task("ggavax:sync_rewards", "")
	.addParam("actor", "Account used to send tx")
	.setAction(async ({ actor }) => {
		const signer = (await getNamedAccounts())[actor];
		const ggAVAX = await get("TokenggAVAX", signer);
		await ggAVAX.syncRewards();
	});

task("ggavax:liqstaker_deposit_avax")
	.addParam("actor", "")
	.addParam("amt", "")
	.setAction(async ({ actor, amt }) => {
		const addr = (await getNamedAccounts())[actor];
		const ggAVAX = await get("TokenggAVAX", addr);
		await ggAVAX.depositAVAX({
			value: ethers.utils.parseEther(amt, "ether"),
		});
	});

task("ggavax:liqstaker_redeem_ggavax")
	.addParam("actor", "")
	.addParam("amt", "")
	.setAction(async ({ actor, amt }) => {
		const addr = (await getNamedAccounts())[actor];
		const ggAVAX = await get("TokenggAVAX", addr);
		await ggAVAX.redeemAVAX(ethers.utils.parseEther(amt, "ether"));
	});

task("ggp:deal")
	.addParam("recip", "")
	.addParam("amt", "")
	.setAction(async ({ recip, amt }) => {
		amt = ethers.utils.parseEther(amt, "ether");
		recip = (await getNamedAccounts())[recip];

		const ggp = await get("TokenGGP");
		await ggp.transfer(recip.address, amt);

		const minipoolManager = await get("MinipoolManager");
		const ggpAsRecip = await get("TokenGGP", recip);
		await ggpAsRecip.approve(minipoolManager.address, amt);
	});
