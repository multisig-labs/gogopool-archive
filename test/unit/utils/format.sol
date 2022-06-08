pragma solidity ^0.8.13;

library format {
	function parseEther(uint256 e) internal view returns (uint256 wholePart, uint256 decimalPart) {
		uint256 sigDigits = 100_000;

		uint256 result = (e * sigDigits) / 1 ether;
		return (result / sigDigits, result % sigDigits);
	}
}
