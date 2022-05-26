pragma solidity ^0.8.13;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";
import "../../contracts/contract/dao/ProtocolDAO.sol";

contract ProtocolDAOTest is GGPTest {
	function setUp() public override {
		super.setUp();
	}

	function testGetInflation() public {
		assertEq(dao.getInflationIntervalRate(), uint256(1000133680617113500));
		assertTrue(dao.getInflationIntervalStartTime() != 0);
	}
}
