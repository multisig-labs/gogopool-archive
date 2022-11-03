// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.17;

import "./utils/BaseTest.sol";
import {ProtocolDAO} from "../../contracts/contract/ProtocolDAO.sol";

contract ProtocolDAOTest is BaseTest {
	function setUp() public override {
		super.setUp();
	}

	function testGetInflation() public view {
		assert(dao.getInflationIntervalRate() > 0);
		assert(dao.getInflationIntervalSeconds() != 0);
	}
}
