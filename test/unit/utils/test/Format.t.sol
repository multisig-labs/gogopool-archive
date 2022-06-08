pragma solidity ^0.8.13;
import {Test} from "forge-std/Test.sol";
import {format} from "../format.sol";

contract formatTest is Test {
	function testParseEther() public {
		(uint256 wholePart, uint256 decimalPart) = format.parseEther(0.56565 ether);
		assertEq(wholePart, 0);
		assertEq(decimalPart, 56565);
	}
}
