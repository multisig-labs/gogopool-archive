pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/BaseTest.sol";

// +-----------+-----------+--------+---------+
// |    Gas    | Gas Price | Avax $ | Tx $    |
// +-----------+-----------+--------+---------+
// |        50 |       120 |     80 | 0.00048 |
// |       100 |       120 |     80 | 0.00096 |
// |       500 |       120 |     80 |  0.0048 |
// |     1,000 |       120 |     80 |  0.0096 |
// |     5,000 |       120 |     80 |   0.048 |
// |    10,000 |       120 |     80 |   0.096 |
// |    50,000 |       120 |     80 |    0.48 |
// |   100,000 |       120 |     80 |    0.96 |
// |   500,000 |       120 |     80 |     4.8 |
// | 1,000,000 |       120 |     80 |     9.6 |
// | 3,000,000 |       120 |     80 |    28.8 |
// +-----------+-----------+--------+---------+

contract GasTest is BaseTest {
	function testGas() public {
		bytes memory key = bytes("key");
		bytes32 key2 = bytes32("key2");
		bytes memory result;
		bytes32 h;

		// This takes 22455 gas
		startMeasuringGas("test1");
		result = abi.encodePacked(key, ".keyA");
		stopMeasuringGas();

		// This takes 244 gas
		startMeasuringGas("test2");
		result = abi.encodePacked(key2, ".keyA");
		stopMeasuringGas();

		// This takes 208 gas
		startMeasuringGas("test3");
		result = abi.encodePacked("key1.keyA");
		stopMeasuringGas();

		// This takes 229 gas
		startMeasuringGas("test4");
		result = abi.encodePacked("key1", ".keyA");
		stopMeasuringGas();

		// This takes 259 gas
		startMeasuringGas("test5");
		h = keccak256(abi.encodePacked("key1"));
		stopMeasuringGas();

		// This takes 139 gas
		startMeasuringGas("test6");
		h = keccak256("key1");
		stopMeasuringGas();
	}
}
