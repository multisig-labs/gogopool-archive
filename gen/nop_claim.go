// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package nop_claim

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

// NopClaimMetaData contains all meta data concerning the NopClaim contract.
var NopClaimMetaData = &bind.MetaData{
	ABI: "[{\"inputs\":[{\"internalType\":\"contractStorage\",\"name\":\"storageAddress\",\"type\":\"address\"},{\"internalType\":\"contractERC20\",\"name\":\"ggp_\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"inputs\":[],\"name\":\"ContractNotFound\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"ContractPaused\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"InvalidAmount\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"InvalidOrOutdatedContract\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"MustBeGuardian\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"MustBeGuardianOrValidContract\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"MustBeMultisig\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"NoRewardsToClaim\",\"type\":\"error\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"GGPRewardsClaimed\",\"type\":\"event\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"totalEligibleGGPStaked\",\"type\":\"uint256\"}],\"name\":\"calculateAndDistributeRewards\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"claimAmount\",\"type\":\"uint256\"}],\"name\":\"claimAndRestake\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"string\",\"name\":\"contractName\",\"type\":\"string\"}],\"name\":\"getContractAddress\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getRewardsCycleTotal\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"ggp\",\"outputs\":[{\"internalType\":\"contractERC20\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"}],\"name\":\"isEligible\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"setRewardsCycleTotal\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"internalType\":\"uint8\",\"name\":\"\",\"type\":\"uint8\"}],\"stateMutability\":\"view\",\"type\":\"function\"}]",
}

// NopClaimABI is the input ABI used to generate the binding from.
// Deprecated: Use NopClaimMetaData.ABI instead.
var NopClaimABI = NopClaimMetaData.ABI

// NopClaim is an auto generated Go binding around an Ethereum contract.
type NopClaim struct {
	NopClaimCaller     // Read-only binding to the contract
	NopClaimTransactor // Write-only binding to the contract
	NopClaimFilterer   // Log filterer for contract events
}

// NopClaimCaller is an auto generated read-only Go binding around an Ethereum contract.
type NopClaimCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// NopClaimTransactor is an auto generated write-only Go binding around an Ethereum contract.
type NopClaimTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// NopClaimFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type NopClaimFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// NopClaimSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type NopClaimSession struct {
	Contract     *NopClaim         // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// NopClaimCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type NopClaimCallerSession struct {
	Contract *NopClaimCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts   // Call options to use throughout this session
}

// NopClaimTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type NopClaimTransactorSession struct {
	Contract     *NopClaimTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts   // Transaction auth options to use throughout this session
}

// NopClaimRaw is an auto generated low-level Go binding around an Ethereum contract.
type NopClaimRaw struct {
	Contract *NopClaim // Generic contract binding to access the raw methods on
}

// NopClaimCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type NopClaimCallerRaw struct {
	Contract *NopClaimCaller // Generic read-only contract binding to access the raw methods on
}

// NopClaimTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type NopClaimTransactorRaw struct {
	Contract *NopClaimTransactor // Generic write-only contract binding to access the raw methods on
}

// NewNopClaim creates a new instance of NopClaim, bound to a specific deployed contract.
func NewNopClaim(address common.Address, backend bind.ContractBackend) (*NopClaim, error) {
	contract, err := bindNopClaim(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &NopClaim{NopClaimCaller: NopClaimCaller{contract: contract}, NopClaimTransactor: NopClaimTransactor{contract: contract}, NopClaimFilterer: NopClaimFilterer{contract: contract}}, nil
}

// NewNopClaimCaller creates a new read-only instance of NopClaim, bound to a specific deployed contract.
func NewNopClaimCaller(address common.Address, caller bind.ContractCaller) (*NopClaimCaller, error) {
	contract, err := bindNopClaim(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &NopClaimCaller{contract: contract}, nil
}

// NewNopClaimTransactor creates a new write-only instance of NopClaim, bound to a specific deployed contract.
func NewNopClaimTransactor(address common.Address, transactor bind.ContractTransactor) (*NopClaimTransactor, error) {
	contract, err := bindNopClaim(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &NopClaimTransactor{contract: contract}, nil
}

// NewNopClaimFilterer creates a new log filterer instance of NopClaim, bound to a specific deployed contract.
func NewNopClaimFilterer(address common.Address, filterer bind.ContractFilterer) (*NopClaimFilterer, error) {
	contract, err := bindNopClaim(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &NopClaimFilterer{contract: contract}, nil
}

// bindNopClaim binds a generic wrapper to an already deployed contract.
func bindNopClaim(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := abi.JSON(strings.NewReader(NopClaimABI))
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_NopClaim *NopClaimRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _NopClaim.Contract.NopClaimCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_NopClaim *NopClaimRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _NopClaim.Contract.NopClaimTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_NopClaim *NopClaimRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _NopClaim.Contract.NopClaimTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_NopClaim *NopClaimCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _NopClaim.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_NopClaim *NopClaimTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _NopClaim.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_NopClaim *NopClaimTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _NopClaim.Contract.contract.Transact(opts, method, params...)
}

// GetContractAddress is a free data retrieval call binding the contract method 0x04433bbc.
//
// Solidity: function getContractAddress(string contractName) view returns(address)
func (_NopClaim *NopClaimCaller) GetContractAddress(opts *bind.CallOpts, contractName string) (common.Address, error) {
	var out []interface{}
	err := _NopClaim.contract.Call(opts, &out, "getContractAddress", contractName)

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// GetContractAddress is a free data retrieval call binding the contract method 0x04433bbc.
//
// Solidity: function getContractAddress(string contractName) view returns(address)
func (_NopClaim *NopClaimSession) GetContractAddress(contractName string) (common.Address, error) {
	return _NopClaim.Contract.GetContractAddress(&_NopClaim.CallOpts, contractName)
}

// GetContractAddress is a free data retrieval call binding the contract method 0x04433bbc.
//
// Solidity: function getContractAddress(string contractName) view returns(address)
func (_NopClaim *NopClaimCallerSession) GetContractAddress(contractName string) (common.Address, error) {
	return _NopClaim.Contract.GetContractAddress(&_NopClaim.CallOpts, contractName)
}

// GetRewardsCycleTotal is a free data retrieval call binding the contract method 0xc7379d47.
//
// Solidity: function getRewardsCycleTotal() view returns(uint256)
func (_NopClaim *NopClaimCaller) GetRewardsCycleTotal(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _NopClaim.contract.Call(opts, &out, "getRewardsCycleTotal")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetRewardsCycleTotal is a free data retrieval call binding the contract method 0xc7379d47.
//
// Solidity: function getRewardsCycleTotal() view returns(uint256)
func (_NopClaim *NopClaimSession) GetRewardsCycleTotal() (*big.Int, error) {
	return _NopClaim.Contract.GetRewardsCycleTotal(&_NopClaim.CallOpts)
}

// GetRewardsCycleTotal is a free data retrieval call binding the contract method 0xc7379d47.
//
// Solidity: function getRewardsCycleTotal() view returns(uint256)
func (_NopClaim *NopClaimCallerSession) GetRewardsCycleTotal() (*big.Int, error) {
	return _NopClaim.Contract.GetRewardsCycleTotal(&_NopClaim.CallOpts)
}

// Ggp is a free data retrieval call binding the contract method 0xf321df49.
//
// Solidity: function ggp() view returns(address)
func (_NopClaim *NopClaimCaller) Ggp(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _NopClaim.contract.Call(opts, &out, "ggp")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// Ggp is a free data retrieval call binding the contract method 0xf321df49.
//
// Solidity: function ggp() view returns(address)
func (_NopClaim *NopClaimSession) Ggp() (common.Address, error) {
	return _NopClaim.Contract.Ggp(&_NopClaim.CallOpts)
}

// Ggp is a free data retrieval call binding the contract method 0xf321df49.
//
// Solidity: function ggp() view returns(address)
func (_NopClaim *NopClaimCallerSession) Ggp() (common.Address, error) {
	return _NopClaim.Contract.Ggp(&_NopClaim.CallOpts)
}

// IsEligible is a free data retrieval call binding the contract method 0x66e305fd.
//
// Solidity: function isEligible(address stakerAddr) view returns(bool)
func (_NopClaim *NopClaimCaller) IsEligible(opts *bind.CallOpts, stakerAddr common.Address) (bool, error) {
	var out []interface{}
	err := _NopClaim.contract.Call(opts, &out, "isEligible", stakerAddr)

	if err != nil {
		return *new(bool), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)

	return out0, err

}

// IsEligible is a free data retrieval call binding the contract method 0x66e305fd.
//
// Solidity: function isEligible(address stakerAddr) view returns(bool)
func (_NopClaim *NopClaimSession) IsEligible(stakerAddr common.Address) (bool, error) {
	return _NopClaim.Contract.IsEligible(&_NopClaim.CallOpts, stakerAddr)
}

// IsEligible is a free data retrieval call binding the contract method 0x66e305fd.
//
// Solidity: function isEligible(address stakerAddr) view returns(bool)
func (_NopClaim *NopClaimCallerSession) IsEligible(stakerAddr common.Address) (bool, error) {
	return _NopClaim.Contract.IsEligible(&_NopClaim.CallOpts, stakerAddr)
}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint8)
func (_NopClaim *NopClaimCaller) Version(opts *bind.CallOpts) (uint8, error) {
	var out []interface{}
	err := _NopClaim.contract.Call(opts, &out, "version")

	if err != nil {
		return *new(uint8), err
	}

	out0 := *abi.ConvertType(out[0], new(uint8)).(*uint8)

	return out0, err

}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint8)
func (_NopClaim *NopClaimSession) Version() (uint8, error) {
	return _NopClaim.Contract.Version(&_NopClaim.CallOpts)
}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint8)
func (_NopClaim *NopClaimCallerSession) Version() (uint8, error) {
	return _NopClaim.Contract.Version(&_NopClaim.CallOpts)
}

// CalculateAndDistributeRewards is a paid mutator transaction binding the contract method 0xd8a64c07.
//
// Solidity: function calculateAndDistributeRewards(address stakerAddr, uint256 totalEligibleGGPStaked) returns()
func (_NopClaim *NopClaimTransactor) CalculateAndDistributeRewards(opts *bind.TransactOpts, stakerAddr common.Address, totalEligibleGGPStaked *big.Int) (*types.Transaction, error) {
	return _NopClaim.contract.Transact(opts, "calculateAndDistributeRewards", stakerAddr, totalEligibleGGPStaked)
}

// CalculateAndDistributeRewards is a paid mutator transaction binding the contract method 0xd8a64c07.
//
// Solidity: function calculateAndDistributeRewards(address stakerAddr, uint256 totalEligibleGGPStaked) returns()
func (_NopClaim *NopClaimSession) CalculateAndDistributeRewards(stakerAddr common.Address, totalEligibleGGPStaked *big.Int) (*types.Transaction, error) {
	return _NopClaim.Contract.CalculateAndDistributeRewards(&_NopClaim.TransactOpts, stakerAddr, totalEligibleGGPStaked)
}

// CalculateAndDistributeRewards is a paid mutator transaction binding the contract method 0xd8a64c07.
//
// Solidity: function calculateAndDistributeRewards(address stakerAddr, uint256 totalEligibleGGPStaked) returns()
func (_NopClaim *NopClaimTransactorSession) CalculateAndDistributeRewards(stakerAddr common.Address, totalEligibleGGPStaked *big.Int) (*types.Transaction, error) {
	return _NopClaim.Contract.CalculateAndDistributeRewards(&_NopClaim.TransactOpts, stakerAddr, totalEligibleGGPStaked)
}

// ClaimAndRestake is a paid mutator transaction binding the contract method 0x99fe6aa3.
//
// Solidity: function claimAndRestake(uint256 claimAmount) returns()
func (_NopClaim *NopClaimTransactor) ClaimAndRestake(opts *bind.TransactOpts, claimAmount *big.Int) (*types.Transaction, error) {
	return _NopClaim.contract.Transact(opts, "claimAndRestake", claimAmount)
}

// ClaimAndRestake is a paid mutator transaction binding the contract method 0x99fe6aa3.
//
// Solidity: function claimAndRestake(uint256 claimAmount) returns()
func (_NopClaim *NopClaimSession) ClaimAndRestake(claimAmount *big.Int) (*types.Transaction, error) {
	return _NopClaim.Contract.ClaimAndRestake(&_NopClaim.TransactOpts, claimAmount)
}

// ClaimAndRestake is a paid mutator transaction binding the contract method 0x99fe6aa3.
//
// Solidity: function claimAndRestake(uint256 claimAmount) returns()
func (_NopClaim *NopClaimTransactorSession) ClaimAndRestake(claimAmount *big.Int) (*types.Transaction, error) {
	return _NopClaim.Contract.ClaimAndRestake(&_NopClaim.TransactOpts, claimAmount)
}

// SetRewardsCycleTotal is a paid mutator transaction binding the contract method 0xec23112f.
//
// Solidity: function setRewardsCycleTotal(uint256 amount) returns()
func (_NopClaim *NopClaimTransactor) SetRewardsCycleTotal(opts *bind.TransactOpts, amount *big.Int) (*types.Transaction, error) {
	return _NopClaim.contract.Transact(opts, "setRewardsCycleTotal", amount)
}

// SetRewardsCycleTotal is a paid mutator transaction binding the contract method 0xec23112f.
//
// Solidity: function setRewardsCycleTotal(uint256 amount) returns()
func (_NopClaim *NopClaimSession) SetRewardsCycleTotal(amount *big.Int) (*types.Transaction, error) {
	return _NopClaim.Contract.SetRewardsCycleTotal(&_NopClaim.TransactOpts, amount)
}

// SetRewardsCycleTotal is a paid mutator transaction binding the contract method 0xec23112f.
//
// Solidity: function setRewardsCycleTotal(uint256 amount) returns()
func (_NopClaim *NopClaimTransactorSession) SetRewardsCycleTotal(amount *big.Int) (*types.Transaction, error) {
	return _NopClaim.Contract.SetRewardsCycleTotal(&_NopClaim.TransactOpts, amount)
}

// NopClaimGGPRewardsClaimedIterator is returned from FilterGGPRewardsClaimed and is used to iterate over the raw logs and unpacked data for GGPRewardsClaimed events raised by the NopClaim contract.
type NopClaimGGPRewardsClaimedIterator struct {
	Event *NopClaimGGPRewardsClaimed // Event containing the contract specifics and raw log

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
func (it *NopClaimGGPRewardsClaimedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(NopClaimGGPRewardsClaimed)
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
		it.Event = new(NopClaimGGPRewardsClaimed)
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
func (it *NopClaimGGPRewardsClaimedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *NopClaimGGPRewardsClaimedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// NopClaimGGPRewardsClaimed represents a GGPRewardsClaimed event raised by the NopClaim contract.
type NopClaimGGPRewardsClaimed struct {
	To     common.Address
	Amount *big.Int
	Raw    types.Log // Blockchain specific contextual infos
}

// FilterGGPRewardsClaimed is a free log retrieval operation binding the contract event 0xe6efee8958feb2079af9a7a1df26a6fae99525397bebfc3f64a4b7c3b41984d1.
//
// Solidity: event GGPRewardsClaimed(address indexed to, uint256 amount)
func (_NopClaim *NopClaimFilterer) FilterGGPRewardsClaimed(opts *bind.FilterOpts, to []common.Address) (*NopClaimGGPRewardsClaimedIterator, error) {

	var toRule []interface{}
	for _, toItem := range to {
		toRule = append(toRule, toItem)
	}

	logs, sub, err := _NopClaim.contract.FilterLogs(opts, "GGPRewardsClaimed", toRule)
	if err != nil {
		return nil, err
	}
	return &NopClaimGGPRewardsClaimedIterator{contract: _NopClaim.contract, event: "GGPRewardsClaimed", logs: logs, sub: sub}, nil
}

// WatchGGPRewardsClaimed is a free log subscription operation binding the contract event 0xe6efee8958feb2079af9a7a1df26a6fae99525397bebfc3f64a4b7c3b41984d1.
//
// Solidity: event GGPRewardsClaimed(address indexed to, uint256 amount)
func (_NopClaim *NopClaimFilterer) WatchGGPRewardsClaimed(opts *bind.WatchOpts, sink chan<- *NopClaimGGPRewardsClaimed, to []common.Address) (event.Subscription, error) {

	var toRule []interface{}
	for _, toItem := range to {
		toRule = append(toRule, toItem)
	}

	logs, sub, err := _NopClaim.contract.WatchLogs(opts, "GGPRewardsClaimed", toRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(NopClaimGGPRewardsClaimed)
				if err := _NopClaim.contract.UnpackLog(event, "GGPRewardsClaimed", log); err != nil {
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
func (_NopClaim *NopClaimFilterer) ParseGGPRewardsClaimed(log types.Log) (*NopClaimGGPRewardsClaimed, error) {
	event := new(NopClaimGGPRewardsClaimed)
	if err := _NopClaim.contract.UnpackLog(event, "GGPRewardsClaimed", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
