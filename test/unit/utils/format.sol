pragma solidity ^0.8.13;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

// SPDX-License-Identifier: GPL-3.0-only

library format {

	function parseEther(uint e) internal pure returns (string memory) {
		uint256 sigDigits = 100_000;
		uint256 result = (e * sigDigits) / 1 ether;
		
		return string.concat(Strings.toString(result / sigDigits), ".", Strings.toString(result % sigDigits));
	}

	function parseEtherTwoParts(uint256 e) internal pure returns (uint256 wholePart, uint256 decimalPart) {
		uint256 sigDigits = 100_000;

		uint256 result = (e * sigDigits) / 1 ether;
		return (result / sigDigits, result % sigDigits);
	}
	
}
