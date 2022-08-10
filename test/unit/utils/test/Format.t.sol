pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import {Test} from "forge-std/Test.sol";
import {format} from "../format.sol";
import {console} from "forge-std/console.sol";

contract FormatTest is Test {
	function testParseEther() public {
		string memory result = format.parseEther(0.56565 ether);
		assertEq(result, "0.56565");
	}

	function testParseEtherTwoParts() public {
		(uint256 wholePart, uint256 decimalPart) = format.parseEtherTwoParts(0.56565 ether);
		assertEq(wholePart, 0);
		assertEq(decimalPart, 56565);
	}
}
