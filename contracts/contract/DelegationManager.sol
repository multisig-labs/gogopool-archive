pragma solidity ^0.8.13;
import "./Base.sol";
import "./BaseQueue.sol";
import "../interface/IVault.sol";
import "../interface/IStorage.sol";
import {ERC20} from "@rari-capital/solmate/src/mixins/ERC4626.sol";


/*
	Data Storage Schema
	(nodeIDs are 20 bytes so can use Solidity 'address' as storage type for them)
	NodeIDs can be added, but never removed. If a nodeID submits another validation request,
	it will overwrite the old one (only allowed for specific statuses).
	nodeOperator.count = Starts at 0 and counts up by 1 after a node is added.
	nodeOperator.index<nodeID> = <index> of nodeID
	nodeOperator.item<index>.nodeID = nodeID used as primary key (NOT the ascii "Node-blah" but the actual 20 bytes)
  nodeOperator.item<index>.timeZone = timezone where the node is located
	nodeOperator.item<index>.exists = boolean
	nodeOperator.item<index>.duration = requested validation duration in seconds
	nodeOperator.item<index>.owner = owner address
	nodeOperator.item<index>.delegationFee = node operator specified fee
	nodeOperator.item<index>.avaxAmt = avax deposited by node op (1000 avax for now)
	nodeOperator.item<index>.ggpBondAmt = amt ggp deposited by node op for bond
*/

contract DelegationManager is Base {

  ERC20 public immutable ggp;
	/// @notice Validation end time must be after start time
	error InvalidTimeZone();

	/// @notice Validation avax amt must be greater than 1000 and less than 3M.
	error InvalidAvaxAmt();

	/// @notice Validation delegation fee must be atleast 2% and no more than 20%.
	error InvalidDelegationFee();

	/// @notice Validation duration must be atleast two weeks and no more than a year.
	error InvalidDuration();

	/// @notice Validation ggp bond amount must be atleast 10% of the staked amount.
	error InvalidGGPBondAmt();

	/// @notice Validation node id already exists
	error InvalidNodeId();

  event NodeRegistered(address indexed nodeID);

	constructor(
		IStorage storageAddress,
		ERC20 ggp_
	) Base(storageAddress) {
		version = 1;
		ggp = ggp_;
	}

	//i'm thinking we have the user enter in their node id, timezone?, and duration and we check it against avalanche api and if our code determines it is new node then we prompt the user to put in the
	// information needed to make a validator like delegation fee, avax staking amt, ggp bond amt, etc, otherwise we will get it from api.
	function registerNode(
		address nodeID,
		bytes32 timeZone,
		uint256 startTime,
		uint256 endTime,
		uint256 avaxAmt,
		uint256 delegationFee,
		uint256 ggpBondAmt
	) public payable returns (bool successfulRegistration) {

		uint256 duration;
		duration = endTime - startTime;
		//TODO: check that node registration is enabled in the protocol

		// Check timezone location
		if (timeZone.length >= 4) {
			revert InvalidTimeZone();
		}
		//not sure if I should keep these in seperate functions or keep them in the function lile above
		requireDuration(duration);
		requireAvaxAmt(avaxAmt);
		requireDelegationFee(delegationFee);
		requireGGPBondAmt(ggpBondAmt);

    IVault vault = IVault(getContractAddress("Vault"));

		if (ggpBondAmt > 0) {
			// Move the GGP funds (assume allowance has been set properly beforehand by the front end)
			// TODO switch to error objects
			require(ggp.transferFrom(msg.sender, address(this), ggpBondAmt), "Could not transfer GGP to Delegation contract");
			require(ggp.approve(address(vault), ggpBondAmt), "Could not approve vault GGP deposit");
			// depositToken reverts if not successful
			vault.depositToken("DelegationManager", ggp, ggpBondAmt);
		}

		uint256 index;
		// getIndexOf returns -1 if node does not exist, so have to use signed type int256 here
		int256 i = getIndexOf(nodeID);
		if (i != -1) {
			// Existing nodeID
			revert InvalidNodeId();
		} else {
			// new nodeID
			index = getUint(keccak256("nodeOperator.count"));
		}

		// Initialise node data
		setBool(keccak256(abi.encodePacked("nodeOperator.item", index, ".exists")), true);
		setAddress(keccak256(abi.encodePacked("nodeOperator.item", index, ".nodeID")), nodeID);
		setBytes32(keccak256(abi.encodePacked("nodeOperator.item", index, ".timeZone")), timeZone);
		setUint(keccak256(abi.encodePacked("nodeOperator.item", index, ".duration")), duration);
		setUint(keccak256(abi.encodePacked("nodeOperator.item", index, ".avaxAmt")), avaxAmt);
		setUint(keccak256(abi.encodePacked("nodeOperator.item", index, ".delegationFee")), delegationFee);
		setUint(keccak256(abi.encodePacked("nodeOperator.item", index, ".ggpBondAmt")), ggpBondAmt);

    BaseQueue delegationQueue = BaseQueue(getContractAddress("BaseQueue"));
		delegationQueue.enqueue("delegationQueue", nodeID);    

		//should we return or emit back to FE?
		successfulRegistration = getBool(keccak256(abi.encodePacked("nodeOperator.item", index, ".exists")));
    emit NodeRegistered(nodeID);
		return successfulRegistration;
	}

	// The index of an item
	// Returns -1 if the value is not found
	function getIndexOf(address nodeID) public view returns (int256) {
		return int256(getUint(keccak256(abi.encodePacked("nodeOperator.index", nodeID)))) - 1;
	}

	function requireAvaxAmt(uint256 avaxAmt) public pure {
		if (avaxAmt < 1000 || avaxAmt > 3000000) {
			revert InvalidTimeZone();
		}
	}

	function requireDelegationFee(uint256 delegationFee) public pure {
		if (delegationFee < 2 || delegationFee > 20) {
			revert InvalidDelegationFee();
		}
	}

	function requireDuration(uint256 duration) public pure {
    if (duration < 1209600 || duration > 31536000){
      revert InvalidDuration();
    } 
	}

	function requireGGPBondAmt(uint256 ggpBondAmt) public pure {
		// TODO check ggp bond amt
	}
}
