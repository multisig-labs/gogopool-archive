// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package claim_node_op

import (
	"errors"
	"math/big"
	"strings"

	"github.com/ava-labs/coreth/accounts/abi"
	"github.com/ava-labs/coreth/accounts/abi/bind"
	"github.com/ava-labs/coreth/core/types"
	"github.com/ava-labs/coreth/interfaces"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/event"
)

// Reference imports to suppress errors if they are not otherwise used.
var (
	_ = errors.New
	_ = big.NewInt
	_ = strings.NewReader
	_ = interfaces.NotFound
	_ = bind.Bind
	_ = common.Big1
	_ = types.BloomLookup
	_ = event.NewSubscription
)

// ClaimNodeOpMetaData contains all meta data concerning the ClaimNodeOp contract.
var ClaimNodeOpMetaData = &bind.MetaData{
	ABI: "[{\"inputs\":[{\"internalType\":\"contractStorage\",\"name\":\"storageAddress\",\"type\":\"address\"},{\"internalType\":\"contractERC20\",\"name\":\"ggp_\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"inputs\":[],\"name\":\"ContractNotFound\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"ContractPaused\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"InvalidAmount\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"InvalidOrOutdatedContract\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"MustBeGuardian\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"MustBeGuardianOrValidContract\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"MustBeMultisig\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"NoRewardsToClaim\",\"type\":\"error\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"name\":\"RewardsAlreadyDistributedToStaker\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"RewardsCycleNotStarted\",\"type\":\"error\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"GGPRewardsClaimed\",\"type\":\"event\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"totalEligibleGGPStaked\",\"type\":\"uint256\"}],\"name\":\"calculateAndDistributeRewards\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"claimAmt\",\"type\":\"uint256\"}],\"name\":\"claimAndRestake\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getRewardsCycleTotal\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"ggp\",\"outputs\":[{\"internalType\":\"contractERC20\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"}],\"name\":\"isEligible\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"setRewardsCycleTotal\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"internalType\":\"uint8\",\"name\":\"\",\"type\":\"uint8\"}],\"stateMutability\":\"view\",\"type\":\"function\"}]",
}

// ClaimNodeOpABI is the input ABI used to generate the binding from.
// Deprecated: Use ClaimNodeOpMetaData.ABI instead.
var ClaimNodeOpABI = ClaimNodeOpMetaData.ABI

// ClaimNodeOp is an auto generated Go binding around an Ethereum contract.
type ClaimNodeOp struct {
	ClaimNodeOpCaller     // Read-only binding to the contract
	ClaimNodeOpTransactor // Write-only binding to the contract
	ClaimNodeOpFilterer   // Log filterer for contract events
}

// ClaimNodeOpCaller is an auto generated read-only Go binding around an Ethereum contract.
type ClaimNodeOpCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// ClaimNodeOpTransactor is an auto generated write-only Go binding around an Ethereum contract.
type ClaimNodeOpTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// ClaimNodeOpFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type ClaimNodeOpFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// ClaimNodeOpSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type ClaimNodeOpSession struct {
	Contract     *ClaimNodeOp      // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// ClaimNodeOpCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type ClaimNodeOpCallerSession struct {
	Contract *ClaimNodeOpCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts      // Call options to use throughout this session
}

// ClaimNodeOpTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type ClaimNodeOpTransactorSession struct {
	Contract     *ClaimNodeOpTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts      // Transaction auth options to use throughout this session
}

// ClaimNodeOpRaw is an auto generated low-level Go binding around an Ethereum contract.
type ClaimNodeOpRaw struct {
	Contract *ClaimNodeOp // Generic contract binding to access the raw methods on
}

// ClaimNodeOpCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type ClaimNodeOpCallerRaw struct {
	Contract *ClaimNodeOpCaller // Generic read-only contract binding to access the raw methods on
}

// ClaimNodeOpTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type ClaimNodeOpTransactorRaw struct {
	Contract *ClaimNodeOpTransactor // Generic write-only contract binding to access the raw methods on
}

// NewClaimNodeOp creates a new instance of ClaimNodeOp, bound to a specific deployed contract.
func NewClaimNodeOp(address common.Address, backend bind.ContractBackend) (*ClaimNodeOp, error) {
	contract, err := bindClaimNodeOp(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &ClaimNodeOp{ClaimNodeOpCaller: ClaimNodeOpCaller{contract: contract}, ClaimNodeOpTransactor: ClaimNodeOpTransactor{contract: contract}, ClaimNodeOpFilterer: ClaimNodeOpFilterer{contract: contract}}, nil
}

// NewClaimNodeOpCaller creates a new read-only instance of ClaimNodeOp, bound to a specific deployed contract.
func NewClaimNodeOpCaller(address common.Address, caller bind.ContractCaller) (*ClaimNodeOpCaller, error) {
	contract, err := bindClaimNodeOp(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &ClaimNodeOpCaller{contract: contract}, nil
}

// NewClaimNodeOpTransactor creates a new write-only instance of ClaimNodeOp, bound to a specific deployed contract.
func NewClaimNodeOpTransactor(address common.Address, transactor bind.ContractTransactor) (*ClaimNodeOpTransactor, error) {
	contract, err := bindClaimNodeOp(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &ClaimNodeOpTransactor{contract: contract}, nil
}

// NewClaimNodeOpFilterer creates a new log filterer instance of ClaimNodeOp, bound to a specific deployed contract.
func NewClaimNodeOpFilterer(address common.Address, filterer bind.ContractFilterer) (*ClaimNodeOpFilterer, error) {
	contract, err := bindClaimNodeOp(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &ClaimNodeOpFilterer{contract: contract}, nil
}

// bindClaimNodeOp binds a generic wrapper to an already deployed contract.
func bindClaimNodeOp(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := abi.JSON(strings.NewReader(ClaimNodeOpABI))
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_ClaimNodeOp *ClaimNodeOpRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _ClaimNodeOp.Contract.ClaimNodeOpCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_ClaimNodeOp *ClaimNodeOpRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _ClaimNodeOp.Contract.ClaimNodeOpTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_ClaimNodeOp *ClaimNodeOpRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _ClaimNodeOp.Contract.ClaimNodeOpTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_ClaimNodeOp *ClaimNodeOpCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _ClaimNodeOp.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_ClaimNodeOp *ClaimNodeOpTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _ClaimNodeOp.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_ClaimNodeOp *ClaimNodeOpTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _ClaimNodeOp.Contract.contract.Transact(opts, method, params...)
}

// GetRewardsCycleTotal is a free data retrieval call binding the contract method 0xc7379d47.
//
// Solidity: function getRewardsCycleTotal() view returns(uint256)
func (_ClaimNodeOp *ClaimNodeOpCaller) GetRewardsCycleTotal(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _ClaimNodeOp.contract.Call(opts, &out, "getRewardsCycleTotal")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetRewardsCycleTotal is a free data retrieval call binding the contract method 0xc7379d47.
//
// Solidity: function getRewardsCycleTotal() view returns(uint256)
func (_ClaimNodeOp *ClaimNodeOpSession) GetRewardsCycleTotal() (*big.Int, error) {
	return _ClaimNodeOp.Contract.GetRewardsCycleTotal(&_ClaimNodeOp.CallOpts)
}

// GetRewardsCycleTotal is a free data retrieval call binding the contract method 0xc7379d47.
//
// Solidity: function getRewardsCycleTotal() view returns(uint256)
func (_ClaimNodeOp *ClaimNodeOpCallerSession) GetRewardsCycleTotal() (*big.Int, error) {
	return _ClaimNodeOp.Contract.GetRewardsCycleTotal(&_ClaimNodeOp.CallOpts)
}

// Ggp is a free data retrieval call binding the contract method 0xf321df49.
//
// Solidity: function ggp() view returns(address)
func (_ClaimNodeOp *ClaimNodeOpCaller) Ggp(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _ClaimNodeOp.contract.Call(opts, &out, "ggp")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// Ggp is a free data retrieval call binding the contract method 0xf321df49.
//
// Solidity: function ggp() view returns(address)
func (_ClaimNodeOp *ClaimNodeOpSession) Ggp() (common.Address, error) {
	return _ClaimNodeOp.Contract.Ggp(&_ClaimNodeOp.CallOpts)
}

// Ggp is a free data retrieval call binding the contract method 0xf321df49.
//
// Solidity: function ggp() view returns(address)
func (_ClaimNodeOp *ClaimNodeOpCallerSession) Ggp() (common.Address, error) {
	return _ClaimNodeOp.Contract.Ggp(&_ClaimNodeOp.CallOpts)
}

// IsEligible is a free data retrieval call binding the contract method 0x66e305fd.
//
// Solidity: function isEligible(address stakerAddr) view returns(bool)
func (_ClaimNodeOp *ClaimNodeOpCaller) IsEligible(opts *bind.CallOpts, stakerAddr common.Address) (bool, error) {
	var out []interface{}
	err := _ClaimNodeOp.contract.Call(opts, &out, "isEligible", stakerAddr)

	if err != nil {
		return *new(bool), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)

	return out0, err

}

// IsEligible is a free data retrieval call binding the contract method 0x66e305fd.
//
// Solidity: function isEligible(address stakerAddr) view returns(bool)
func (_ClaimNodeOp *ClaimNodeOpSession) IsEligible(stakerAddr common.Address) (bool, error) {
	return _ClaimNodeOp.Contract.IsEligible(&_ClaimNodeOp.CallOpts, stakerAddr)
}

// IsEligible is a free data retrieval call binding the contract method 0x66e305fd.
//
// Solidity: function isEligible(address stakerAddr) view returns(bool)
func (_ClaimNodeOp *ClaimNodeOpCallerSession) IsEligible(stakerAddr common.Address) (bool, error) {
	return _ClaimNodeOp.Contract.IsEligible(&_ClaimNodeOp.CallOpts, stakerAddr)
}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint8)
func (_ClaimNodeOp *ClaimNodeOpCaller) Version(opts *bind.CallOpts) (uint8, error) {
	var out []interface{}
	err := _ClaimNodeOp.contract.Call(opts, &out, "version")

	if err != nil {
		return *new(uint8), err
	}

	out0 := *abi.ConvertType(out[0], new(uint8)).(*uint8)

	return out0, err

}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint8)
func (_ClaimNodeOp *ClaimNodeOpSession) Version() (uint8, error) {
	return _ClaimNodeOp.Contract.Version(&_ClaimNodeOp.CallOpts)
}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint8)
func (_ClaimNodeOp *ClaimNodeOpCallerSession) Version() (uint8, error) {
	return _ClaimNodeOp.Contract.Version(&_ClaimNodeOp.CallOpts)
}

// CalculateAndDistributeRewards is a paid mutator transaction binding the contract method 0xd8a64c07.
//
// Solidity: function calculateAndDistributeRewards(address stakerAddr, uint256 totalEligibleGGPStaked) returns()
func (_ClaimNodeOp *ClaimNodeOpTransactor) CalculateAndDistributeRewards(opts *bind.TransactOpts, stakerAddr common.Address, totalEligibleGGPStaked *big.Int) (*types.Transaction, error) {
	return _ClaimNodeOp.contract.Transact(opts, "calculateAndDistributeRewards", stakerAddr, totalEligibleGGPStaked)
}

// CalculateAndDistributeRewards is a paid mutator transaction binding the contract method 0xd8a64c07.
//
// Solidity: function calculateAndDistributeRewards(address stakerAddr, uint256 totalEligibleGGPStaked) returns()
func (_ClaimNodeOp *ClaimNodeOpSession) CalculateAndDistributeRewards(stakerAddr common.Address, totalEligibleGGPStaked *big.Int) (*types.Transaction, error) {
	return _ClaimNodeOp.Contract.CalculateAndDistributeRewards(&_ClaimNodeOp.TransactOpts, stakerAddr, totalEligibleGGPStaked)
}

// CalculateAndDistributeRewards is a paid mutator transaction binding the contract method 0xd8a64c07.
//
// Solidity: function calculateAndDistributeRewards(address stakerAddr, uint256 totalEligibleGGPStaked) returns()
func (_ClaimNodeOp *ClaimNodeOpTransactorSession) CalculateAndDistributeRewards(stakerAddr common.Address, totalEligibleGGPStaked *big.Int) (*types.Transaction, error) {
	return _ClaimNodeOp.Contract.CalculateAndDistributeRewards(&_ClaimNodeOp.TransactOpts, stakerAddr, totalEligibleGGPStaked)
}

// ClaimAndRestake is a paid mutator transaction binding the contract method 0x99fe6aa3.
//
// Solidity: function claimAndRestake(uint256 claimAmt) returns()
func (_ClaimNodeOp *ClaimNodeOpTransactor) ClaimAndRestake(opts *bind.TransactOpts, claimAmt *big.Int) (*types.Transaction, error) {
	return _ClaimNodeOp.contract.Transact(opts, "claimAndRestake", claimAmt)
}

// ClaimAndRestake is a paid mutator transaction binding the contract method 0x99fe6aa3.
//
// Solidity: function claimAndRestake(uint256 claimAmt) returns()
func (_ClaimNodeOp *ClaimNodeOpSession) ClaimAndRestake(claimAmt *big.Int) (*types.Transaction, error) {
	return _ClaimNodeOp.Contract.ClaimAndRestake(&_ClaimNodeOp.TransactOpts, claimAmt)
}

// ClaimAndRestake is a paid mutator transaction binding the contract method 0x99fe6aa3.
//
// Solidity: function claimAndRestake(uint256 claimAmt) returns()
func (_ClaimNodeOp *ClaimNodeOpTransactorSession) ClaimAndRestake(claimAmt *big.Int) (*types.Transaction, error) {
	return _ClaimNodeOp.Contract.ClaimAndRestake(&_ClaimNodeOp.TransactOpts, claimAmt)
}

// SetRewardsCycleTotal is a paid mutator transaction binding the contract method 0xec23112f.
//
// Solidity: function setRewardsCycleTotal(uint256 amount) returns()
func (_ClaimNodeOp *ClaimNodeOpTransactor) SetRewardsCycleTotal(opts *bind.TransactOpts, amount *big.Int) (*types.Transaction, error) {
	return _ClaimNodeOp.contract.Transact(opts, "setRewardsCycleTotal", amount)
}

// SetRewardsCycleTotal is a paid mutator transaction binding the contract method 0xec23112f.
//
// Solidity: function setRewardsCycleTotal(uint256 amount) returns()
func (_ClaimNodeOp *ClaimNodeOpSession) SetRewardsCycleTotal(amount *big.Int) (*types.Transaction, error) {
	return _ClaimNodeOp.Contract.SetRewardsCycleTotal(&_ClaimNodeOp.TransactOpts, amount)
}

// SetRewardsCycleTotal is a paid mutator transaction binding the contract method 0xec23112f.
//
// Solidity: function setRewardsCycleTotal(uint256 amount) returns()
func (_ClaimNodeOp *ClaimNodeOpTransactorSession) SetRewardsCycleTotal(amount *big.Int) (*types.Transaction, error) {
	return _ClaimNodeOp.Contract.SetRewardsCycleTotal(&_ClaimNodeOp.TransactOpts, amount)
}

// ClaimNodeOpGGPRewardsClaimedIterator is returned from FilterGGPRewardsClaimed and is used to iterate over the raw logs and unpacked data for GGPRewardsClaimed events raised by the ClaimNodeOp contract.
type ClaimNodeOpGGPRewardsClaimedIterator struct {
	Event *ClaimNodeOpGGPRewardsClaimed // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log          // Log channel receiving the found contract events
	sub  interfaces.Subscription // Subscription for errors, completion and termination
	done bool                    // Whether the subscription completed delivering logs
	fail error                   // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *ClaimNodeOpGGPRewardsClaimedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(ClaimNodeOpGGPRewardsClaimed)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(ClaimNodeOpGGPRewardsClaimed)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *ClaimNodeOpGGPRewardsClaimedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *ClaimNodeOpGGPRewardsClaimedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// ClaimNodeOpGGPRewardsClaimed represents a GGPRewardsClaimed event raised by the ClaimNodeOp contract.
type ClaimNodeOpGGPRewardsClaimed struct {
	To     common.Address
	Amount *big.Int
	Raw    types.Log // Blockchain specific contextual infos
}

// FilterGGPRewardsClaimed is a free log retrieval operation binding the contract event 0xe6efee8958feb2079af9a7a1df26a6fae99525397bebfc3f64a4b7c3b41984d1.
//
// Solidity: event GGPRewardsClaimed(address indexed to, uint256 amount)
func (_ClaimNodeOp *ClaimNodeOpFilterer) FilterGGPRewardsClaimed(opts *bind.FilterOpts, to []common.Address) (*ClaimNodeOpGGPRewardsClaimedIterator, error) {

	var toRule []interface{}
	for _, toItem := range to {
		toRule = append(toRule, toItem)
	}

	logs, sub, err := _ClaimNodeOp.contract.FilterLogs(opts, "GGPRewardsClaimed", toRule)
	if err != nil {
		return nil, err
	}
	return &ClaimNodeOpGGPRewardsClaimedIterator{contract: _ClaimNodeOp.contract, event: "GGPRewardsClaimed", logs: logs, sub: sub}, nil
}

// WatchGGPRewardsClaimed is a free log subscription operation binding the contract event 0xe6efee8958feb2079af9a7a1df26a6fae99525397bebfc3f64a4b7c3b41984d1.
//
// Solidity: event GGPRewardsClaimed(address indexed to, uint256 amount)
func (_ClaimNodeOp *ClaimNodeOpFilterer) WatchGGPRewardsClaimed(opts *bind.WatchOpts, sink chan<- *ClaimNodeOpGGPRewardsClaimed, to []common.Address) (event.Subscription, error) {

	var toRule []interface{}
	for _, toItem := range to {
		toRule = append(toRule, toItem)
	}

	logs, sub, err := _ClaimNodeOp.contract.WatchLogs(opts, "GGPRewardsClaimed", toRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(ClaimNodeOpGGPRewardsClaimed)
				if err := _ClaimNodeOp.contract.UnpackLog(event, "GGPRewardsClaimed", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseGGPRewardsClaimed is a log parse operation binding the contract event 0xe6efee8958feb2079af9a7a1df26a6fae99525397bebfc3f64a4b7c3b41984d1.
//
// Solidity: event GGPRewardsClaimed(address indexed to, uint256 amount)
func (_ClaimNodeOp *ClaimNodeOpFilterer) ParseGGPRewardsClaimed(log types.Log) (*ClaimNodeOpGGPRewardsClaimed, error) {
	event := new(ClaimNodeOpGGPRewardsClaimed)
	if err := _ClaimNodeOp.contract.UnpackLog(event, "GGPRewardsClaimed", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
