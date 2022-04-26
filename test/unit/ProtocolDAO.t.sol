pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0-only

import "./utils/GGPTest.sol";
import "../../contracts/contract/dao/ProtocolDAO.sol";
import "../../contracts/contract/Storage.sol";

contract ProtocolDAOTest is GGPTest {
	ProtocolDAO private dao;

	function setUp() public {
		Storage s = new Storage();
		dao = new ProtocolDAO(s);
		registerContract(s, "protocolDAO", address(dao));
		dao.initialize();
		initStorage(s);
	}

	function testGetInflation() public {
		assertEq(dao.getInflationIntervalRate(), uint256(1000133680617113500));
		assertTrue(dao.getInflationIntervalStartTime() != 0);
	}
}
