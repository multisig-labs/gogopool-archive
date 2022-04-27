// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
import "./utils/GGPTest.sol";
import "../../contracts/contract/tokens/TokenGGP.sol";
import "../../contracts/contract/Storage.sol";

contract TokenGGPTest is GGPTest {
	address constant deployer = address(0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84);
	address constant storageUpdater = address(0xDEADBEEF);
	address constant zeroAddress = address(0x0);
	Storage s;
	TokenGGP t;

	function setUp() public {
		s = new Storage();
		t = new TokenGGP(s);

		registerContract(s, "tokenGGP", address(t));

		initStorage(s);
	}

	// **
	// ** Sanity Checks **
	// **

	// get inflation calc time
	function testGetInflationCalcTime() public {
		assert(t.getInflationCalcTime() == 0);
	}

	function testGetInflationIntervalTime() public {
		assert(t.getInflationIntervalTime() == 1 days);
	}

	function testGetInflationIntervalRate() public {
		assert(t.getInflationIntervalRate() == uint256(1000133680617113500));
	}

	function testGetInflationIntervalStartTime() public {
		// when testing, the default timestamp is zero
		// so it is one day after the deployment in seconds
		assert(t.getInflationIntervalStartTime() == 86400);
	}

	function testGetInflationIntervalsPassed() public {
		// no inflation intervals have passed
		assert(t.getInflationIntervalsPassed() == 0);
	}

	function testInflationCalculate() public {
		// we haven't minted anything yet,
		// so there should be no inflation
		assert(t.inflationCalculate() == 0);
	}
}
