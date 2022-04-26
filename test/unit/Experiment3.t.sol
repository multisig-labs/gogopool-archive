pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";

// Try to understand how forge sets addresses
/*

DEPLOYER, 0xb4c79dab8f259c7aee6e5b2aa729821864227e84
SENDER, 0x00a329c0648769a73afac7f9381e08fb43dbea72

ExperimentTest2 setup tx.origin, <RANDOM ADDR EACH TEST RUN>
ExperimentTest2 setup msg.sender, <RANDOM ADDR EACH TEST RUN>
ExperimentTest2 setup this, DEPLOYER
ExperimentTest2 func tx.origin, SENDER
ExperimentTest2 func msg.sender, SENDER
ExperimentTest2 func this, DEPLOYER

ExperimentTest1 setup tx.origin, <RANDOM ADDR EACH TEST RUN>
ExperimentTest1 setup msg.sender, <RANDOM ADDR EACH TEST RUN>
ExperimentTest1 setup this, DEPLOYER
ExperimentTest1 func tx.origin, SENDER
ExperimentTest1 func msg.sender, SENDER
ExperimentTest1 func this, DEPLOYER

ExperimentTest3 setup tx.origin, <RANDOM ADDR EACH TEST RUN>
ExperimentTest3 setup msg.sender, <RANDOM ADDR EACH TEST RUN>
ExperimentTest3 setup this, DEPLOYER
setup -> Foo func1 tx.origin, <RANDOM ADDR EACH TEST RUN>
setup -> Foo func1 msg.sender, DEPLOYER
setup -> Foo func1 this, 0xce71065d4017f316ec606fe4422e11eb2c47c246
ExperimentTest3 func tx.origin, SENDER
ExperimentTest3 func msg.sender, SENDER
ExperimentTest3 func this, DEPLOYER
non-setup -> Foo func2 tx.origin, SENDER
non-setup -> Foo func2 msg.sender, DEPLOYER
non-setup -> Foo func2 this, 0xce71065d4017f316ec606fe4422e11eb2c47c246
*/

contract ExperimentTest3 is GGPTest {
	Foo private foo;

	function setUp() public {
		console.log("ExperimentTest3 setup tx.origin", tx.origin);
		console.log("ExperimentTest3 setup msg.sender", msg.sender);
		console.log("ExperimentTest3 setup this", address(this));
		foo = new Foo();
		foo.func1();
	}

	function testExperiment3() public view {
		console.log("ExperimentTest3 func tx.origin", tx.origin);
		console.log("ExperimentTest3 func msg.sender", msg.sender);
		console.log("ExperimentTest3 func this", address(this));
		foo.func2();
	}
}

contract Foo is GGPTest {
	function func1() public view {
		console.log("setup -> Foo func1 tx.origin", tx.origin);
		console.log("setup -> Foo func1 msg.sender", msg.sender);
		console.log("setup -> Foo func1 this", address(this));
	}

	function func2() public view {
		console.log("non-setup -> Foo func2 tx.origin", tx.origin);
		console.log("non-setup -> Foo func2 msg.sender", msg.sender);
		console.log("non-setup -> Foo func2 this", address(this));
	}
}
