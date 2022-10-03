// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package rewards_pool

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

// RewardsPoolMetaData contains all meta data concerning the RewardsPool contract.
var RewardsPoolMetaData = &bind.MetaData{
	ABI: "[{\"inputs\":[{\"internalType\":\"contractStorage\",\"name\":\"storageAddress\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"inputs\":[],\"name\":\"IncorrectRewardDistribution\",\"type\":\"error\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"address\",\"name\":\"sender\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"value\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"inflationCalcTime\",\"type\":\"uint256\"}],\"name\":\"GGPInflationLog\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"value\",\"type\":\"uint256\"}],\"name\":\"NOPClaimRewardsTransfered\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"totalRewardAmt\",\"type\":\"uint256\"}],\"name\":\"NewRewardsCycleStarted\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"value\",\"type\":\"uint256\"}],\"name\":\"ProtocolDAORewardsTransfered\",\"type\":\"event\"},{\"inputs\":[],\"name\":\"canCycleStart\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"string\",\"name\":\"_claimingContract\",\"type\":\"string\"}],\"name\":\"getClaimingContractDistribution\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"string\",\"name\":\"_claimingContract\",\"type\":\"string\"}],\"name\":\"getClaimingContractPerc\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getInflationIntervalsPassed\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getLastInflationCalcTime\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"string\",\"name\":\"_contractName\",\"type\":\"string\"}],\"name\":\"getPublicContractAddress\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getRewardCycleLength\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getRewardCycleStartTime\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getRewardCycleTotalAmount\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getRewardCyclesPassed\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"settingNameSpace\",\"type\":\"bytes32\"},{\"internalType\":\"string\",\"name\":\"_settingPath\",\"type\":\"string\"}],\"name\":\"getSettingAddress\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"settingNameSpace\",\"type\":\"bytes32\"},{\"internalType\":\"string\",\"name\":\"_settingPath\",\"type\":\"string\"}],\"name\":\"getSettingBool\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"settingNameSpace\",\"type\":\"bytes32\"},{\"internalType\":\"string\",\"name\":\"_settingPath\",\"type\":\"string\"}],\"name\":\"getSettingUint\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getTotalGGPCirculatingSupply\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"inflationCalculate\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"startCycle\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"internalType\":\"uint8\",\"name\":\"\",\"type\":\"uint8\"}],\"stateMutability\":\"view\",\"type\":\"function\"}]",
}

// RewardsPoolABI is the input ABI used to generate the binding from.
// Deprecated: Use RewardsPoolMetaData.ABI instead.
var RewardsPoolABI = RewardsPoolMetaData.ABI

// RewardsPool is an auto generated Go binding around an Ethereum contract.
type RewardsPool struct {
	RewardsPoolCaller     // Read-only binding to the contract
	RewardsPoolTransactor // Write-only binding to the contract
	RewardsPoolFilterer   // Log filterer for contract events
}

// RewardsPoolCaller is an auto generated read-only Go binding around an Ethereum contract.
type RewardsPoolCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// RewardsPoolTransactor is an auto generated write-only Go binding around an Ethereum contract.
type RewardsPoolTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// RewardsPoolFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type RewardsPoolFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// RewardsPoolSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type RewardsPoolSession struct {
	Contract     *RewardsPool      // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// RewardsPoolCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type RewardsPoolCallerSession struct {
	Contract *RewardsPoolCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts      // Call options to use throughout this session
}

// RewardsPoolTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type RewardsPoolTransactorSession struct {
	Contract     *RewardsPoolTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts      // Transaction auth options to use throughout this session
}

// RewardsPoolRaw is an auto generated low-level Go binding around an Ethereum contract.
type RewardsPoolRaw struct {
	Contract *RewardsPool // Generic contract binding to access the raw methods on
}

// RewardsPoolCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type RewardsPoolCallerRaw struct {
	Contract *RewardsPoolCaller // Generic read-only contract binding to access the raw methods on
}

// RewardsPoolTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type RewardsPoolTransactorRaw struct {
	Contract *RewardsPoolTransactor // Generic write-only contract binding to access the raw methods on
}

// NewRewardsPool creates a new instance of RewardsPool, bound to a specific deployed contract.
func NewRewardsPool(address common.Address, backend bind.ContractBackend) (*RewardsPool, error) {
	contract, err := bindRewardsPool(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &RewardsPool{RewardsPoolCaller: RewardsPoolCaller{contract: contract}, RewardsPoolTransactor: RewardsPoolTransactor{contract: contract}, RewardsPoolFilterer: RewardsPoolFilterer{contract: contract}}, nil
}

// NewRewardsPoolCaller creates a new read-only instance of RewardsPool, bound to a specific deployed contract.
func NewRewardsPoolCaller(address common.Address, caller bind.ContractCaller) (*RewardsPoolCaller, error) {
	contract, err := bindRewardsPool(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &RewardsPoolCaller{contract: contract}, nil
}

// NewRewardsPoolTransactor creates a new write-only instance of RewardsPool, bound to a specific deployed contract.
func NewRewardsPoolTransactor(address common.Address, transactor bind.ContractTransactor) (*RewardsPoolTransactor, error) {
	contract, err := bindRewardsPool(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &RewardsPoolTransactor{contract: contract}, nil
}

// NewRewardsPoolFilterer creates a new log filterer instance of RewardsPool, bound to a specific deployed contract.
func NewRewardsPoolFilterer(address common.Address, filterer bind.ContractFilterer) (*RewardsPoolFilterer, error) {
	contract, err := bindRewardsPool(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &RewardsPoolFilterer{contract: contract}, nil
}

// bindRewardsPool binds a generic wrapper to an already deployed contract.
func bindRewardsPool(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := abi.JSON(strings.NewReader(RewardsPoolABI))
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_RewardsPool *RewardsPoolRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _RewardsPool.Contract.RewardsPoolCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_RewardsPool *RewardsPoolRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _RewardsPool.Contract.RewardsPoolTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_RewardsPool *RewardsPoolRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _RewardsPool.Contract.RewardsPoolTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_RewardsPool *RewardsPoolCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _RewardsPool.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_RewardsPool *RewardsPoolTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _RewardsPool.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_RewardsPool *RewardsPoolTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _RewardsPool.Contract.contract.Transact(opts, method, params...)
}

// CanCycleStart is a free data retrieval call binding the contract method 0x1773dcee.
//
// Solidity: function canCycleStart() view returns(bool)
func (_RewardsPool *RewardsPoolCaller) CanCycleStart(opts *bind.CallOpts) (bool, error) {
	var out []interface{}
	err := _RewardsPool.contract.Call(opts, &out, "canCycleStart")

	if err != nil {
		return *new(bool), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)

	return out0, err

}

// CanCycleStart is a free data retrieval call binding the contract method 0x1773dcee.
//
// Solidity: function canCycleStart() view returns(bool)
func (_RewardsPool *RewardsPoolSession) CanCycleStart() (bool, error) {
	return _RewardsPool.Contract.CanCycleStart(&_RewardsPool.CallOpts)
}

// CanCycleStart is a free data retrieval call binding the contract method 0x1773dcee.
//
// Solidity: function canCycleStart() view returns(bool)
func (_RewardsPool *RewardsPoolCallerSession) CanCycleStart() (bool, error) {
	return _RewardsPool.Contract.CanCycleStart(&_RewardsPool.CallOpts)
}

// GetClaimingContractDistribution is a free data retrieval call binding the contract method 0xc32d0f72.
//
// Solidity: function getClaimingContractDistribution(string _claimingContract) view returns(uint256)
func (_RewardsPool *RewardsPoolCaller) GetClaimingContractDistribution(opts *bind.CallOpts, _claimingContract string) (*big.Int, error) {
	var out []interface{}
	err := _RewardsPool.contract.Call(opts, &out, "getClaimingContractDistribution", _claimingContract)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetClaimingContractDistribution is a free data retrieval call binding the contract method 0xc32d0f72.
//
// Solidity: function getClaimingContractDistribution(string _claimingContract) view returns(uint256)
func (_RewardsPool *RewardsPoolSession) GetClaimingContractDistribution(_claimingContract string) (*big.Int, error) {
	return _RewardsPool.Contract.GetClaimingContractDistribution(&_RewardsPool.CallOpts, _claimingContract)
}

// GetClaimingContractDistribution is a free data retrieval call binding the contract method 0xc32d0f72.
//
// Solidity: function getClaimingContractDistribution(string _claimingContract) view returns(uint256)
func (_RewardsPool *RewardsPoolCallerSession) GetClaimingContractDistribution(_claimingContract string) (*big.Int, error) {
	return _RewardsPool.Contract.GetClaimingContractDistribution(&_RewardsPool.CallOpts, _claimingContract)
}

// GetClaimingContractPerc is a free data retrieval call binding the contract method 0xf6a3f6ef.
//
// Solidity: function getClaimingContractPerc(string _claimingContract) view returns(uint256)
func (_RewardsPool *RewardsPoolCaller) GetClaimingContractPerc(opts *bind.CallOpts, _claimingContract string) (*big.Int, error) {
	var out []interface{}
	err := _RewardsPool.contract.Call(opts, &out, "getClaimingContractPerc", _claimingContract)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetClaimingContractPerc is a free data retrieval call binding the contract method 0xf6a3f6ef.
//
// Solidity: function getClaimingContractPerc(string _claimingContract) view returns(uint256)
func (_RewardsPool *RewardsPoolSession) GetClaimingContractPerc(_claimingContract string) (*big.Int, error) {
	return _RewardsPool.Contract.GetClaimingContractPerc(&_RewardsPool.CallOpts, _claimingContract)
}

// GetClaimingContractPerc is a free data retrieval call binding the contract method 0xf6a3f6ef.
//
// Solidity: function getClaimingContractPerc(string _claimingContract) view returns(uint256)
func (_RewardsPool *RewardsPoolCallerSession) GetClaimingContractPerc(_claimingContract string) (*big.Int, error) {
	return _RewardsPool.Contract.GetClaimingContractPerc(&_RewardsPool.CallOpts, _claimingContract)
}

// GetContractAddress is a free data retrieval call binding the contract method 0x04433bbc.
//
// Solidity: function getContractAddress(string _contractName) view returns(address)
func (_RewardsPool *RewardsPoolCaller) GetContractAddress(opts *bind.CallOpts, _contractName string) (common.Address, error) {
	var out []interface{}
	err := _RewardsPool.contract.Call(opts, &out, "getContractAddress", _contractName)

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// GetContractAddress is a free data retrieval call binding the contract method 0x04433bbc.
//
// Solidity: function getContractAddress(string _contractName) view returns(address)
func (_RewardsPool *RewardsPoolSession) GetContractAddress(_contractName string) (common.Address, error) {
	return _RewardsPool.Contract.GetContractAddress(&_RewardsPool.CallOpts, _contractName)
}

// GetContractAddress is a free data retrieval call binding the contract method 0x04433bbc.
//
// Solidity: function getContractAddress(string _contractName) view returns(address)
func (_RewardsPool *RewardsPoolCallerSession) GetContractAddress(_contractName string) (common.Address, error) {
	return _RewardsPool.Contract.GetContractAddress(&_RewardsPool.CallOpts, _contractName)
}

// GetInflationIntervalsPassed is a free data retrieval call binding the contract method 0xb933c49e.
//
// Solidity: function getInflationIntervalsPassed() view returns(uint256)
func (_RewardsPool *RewardsPoolCaller) GetInflationIntervalsPassed(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _RewardsPool.contract.Call(opts, &out, "getInflationIntervalsPassed")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetInflationIntervalsPassed is a free data retrieval call binding the contract method 0xb933c49e.
//
// Solidity: function getInflationIntervalsPassed() view returns(uint256)
func (_RewardsPool *RewardsPoolSession) GetInflationIntervalsPassed() (*big.Int, error) {
	return _RewardsPool.Contract.GetInflationIntervalsPassed(&_RewardsPool.CallOpts)
}

// GetInflationIntervalsPassed is a free data retrieval call binding the contract method 0xb933c49e.
//
// Solidity: function getInflationIntervalsPassed() view returns(uint256)
func (_RewardsPool *RewardsPoolCallerSession) GetInflationIntervalsPassed() (*big.Int, error) {
	return _RewardsPool.Contract.GetInflationIntervalsPassed(&_RewardsPool.CallOpts)
}

// GetLastInflationCalcTime is a free data retrieval call binding the contract method 0x74fa9e85.
//
// Solidity: function getLastInflationCalcTime() view returns(uint256)
func (_RewardsPool *RewardsPoolCaller) GetLastInflationCalcTime(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _RewardsPool.contract.Call(opts, &out, "getLastInflationCalcTime")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetLastInflationCalcTime is a free data retrieval call binding the contract method 0x74fa9e85.
//
// Solidity: function getLastInflationCalcTime() view returns(uint256)
func (_RewardsPool *RewardsPoolSession) GetLastInflationCalcTime() (*big.Int, error) {
	return _RewardsPool.Contract.GetLastInflationCalcTime(&_RewardsPool.CallOpts)
}

// GetLastInflationCalcTime is a free data retrieval call binding the contract method 0x74fa9e85.
//
// Solidity: function getLastInflationCalcTime() view returns(uint256)
func (_RewardsPool *RewardsPoolCallerSession) GetLastInflationCalcTime() (*big.Int, error) {
	return _RewardsPool.Contract.GetLastInflationCalcTime(&_RewardsPool.CallOpts)
}

// GetRewardCycleLength is a free data retrieval call binding the contract method 0xf10fc5b9.
//
// Solidity: function getRewardCycleLength() view returns(uint256)
func (_RewardsPool *RewardsPoolCaller) GetRewardCycleLength(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _RewardsPool.contract.Call(opts, &out, "getRewardCycleLength")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetRewardCycleLength is a free data retrieval call binding the contract method 0xf10fc5b9.
//
// Solidity: function getRewardCycleLength() view returns(uint256)
func (_RewardsPool *RewardsPoolSession) GetRewardCycleLength() (*big.Int, error) {
	return _RewardsPool.Contract.GetRewardCycleLength(&_RewardsPool.CallOpts)
}

// GetRewardCycleLength is a free data retrieval call binding the contract method 0xf10fc5b9.
//
// Solidity: function getRewardCycleLength() view returns(uint256)
func (_RewardsPool *RewardsPoolCallerSession) GetRewardCycleLength() (*big.Int, error) {
	return _RewardsPool.Contract.GetRewardCycleLength(&_RewardsPool.CallOpts)
}

// GetRewardCycleStartTime is a free data retrieval call binding the contract method 0xe8895608.
//
// Solidity: function getRewardCycleStartTime() view returns(uint256)
func (_RewardsPool *RewardsPoolCaller) GetRewardCycleStartTime(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _RewardsPool.contract.Call(opts, &out, "getRewardCycleStartTime")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetRewardCycleStartTime is a free data retrieval call binding the contract method 0xe8895608.
//
// Solidity: function getRewardCycleStartTime() view returns(uint256)
func (_RewardsPool *RewardsPoolSession) GetRewardCycleStartTime() (*big.Int, error) {
	return _RewardsPool.Contract.GetRewardCycleStartTime(&_RewardsPool.CallOpts)
}

// GetRewardCycleStartTime is a free data retrieval call binding the contract method 0xe8895608.
//
// Solidity: function getRewardCycleStartTime() view returns(uint256)
func (_RewardsPool *RewardsPoolCallerSession) GetRewardCycleStartTime() (*big.Int, error) {
	return _RewardsPool.Contract.GetRewardCycleStartTime(&_RewardsPool.CallOpts)
}

// GetRewardCycleTotalAmount is a free data retrieval call binding the contract method 0x6147251c.
//
// Solidity: function getRewardCycleTotalAmount() view returns(uint256)
func (_RewardsPool *RewardsPoolCaller) GetRewardCycleTotalAmount(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _RewardsPool.contract.Call(opts, &out, "getRewardCycleTotalAmount")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetRewardCycleTotalAmount is a free data retrieval call binding the contract method 0x6147251c.
//
// Solidity: function getRewardCycleTotalAmount() view returns(uint256)
func (_RewardsPool *RewardsPoolSession) GetRewardCycleTotalAmount() (*big.Int, error) {
	return _RewardsPool.Contract.GetRewardCycleTotalAmount(&_RewardsPool.CallOpts)
}

// GetRewardCycleTotalAmount is a free data retrieval call binding the contract method 0x6147251c.
//
// Solidity: function getRewardCycleTotalAmount() view returns(uint256)
func (_RewardsPool *RewardsPoolCallerSession) GetRewardCycleTotalAmount() (*big.Int, error) {
	return _RewardsPool.Contract.GetRewardCycleTotalAmount(&_RewardsPool.CallOpts)
}

// GetRewardCyclesPassed is a free data retrieval call binding the contract method 0x624e0014.
//
// Solidity: function getRewardCyclesPassed() view returns(uint256)
func (_RewardsPool *RewardsPoolCaller) GetRewardCyclesPassed(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _RewardsPool.contract.Call(opts, &out, "getRewardCyclesPassed")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetRewardCyclesPassed is a free data retrieval call binding the contract method 0x624e0014.
//
// Solidity: function getRewardCyclesPassed() view returns(uint256)
func (_RewardsPool *RewardsPoolSession) GetRewardCyclesPassed() (*big.Int, error) {
	return _RewardsPool.Contract.GetRewardCyclesPassed(&_RewardsPool.CallOpts)
}

// GetRewardCyclesPassed is a free data retrieval call binding the contract method 0x624e0014.
//
// Solidity: function getRewardCyclesPassed() view returns(uint256)
func (_RewardsPool *RewardsPoolCallerSession) GetRewardCyclesPassed() (*big.Int, error) {
	return _RewardsPool.Contract.GetRewardCyclesPassed(&_RewardsPool.CallOpts)
}

// GetSettingAddress is a free data retrieval call binding the contract method 0x06eaa68b.
//
// Solidity: function getSettingAddress(bytes32 settingNameSpace, string _settingPath) view returns(address)
func (_RewardsPool *RewardsPoolCaller) GetSettingAddress(opts *bind.CallOpts, settingNameSpace [32]byte, _settingPath string) (common.Address, error) {
	var out []interface{}
	err := _RewardsPool.contract.Call(opts, &out, "getSettingAddress", settingNameSpace, _settingPath)

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// GetSettingAddress is a free data retrieval call binding the contract method 0x06eaa68b.
//
// Solidity: function getSettingAddress(bytes32 settingNameSpace, string _settingPath) view returns(address)
func (_RewardsPool *RewardsPoolSession) GetSettingAddress(settingNameSpace [32]byte, _settingPath string) (common.Address, error) {
	return _RewardsPool.Contract.GetSettingAddress(&_RewardsPool.CallOpts, settingNameSpace, _settingPath)
}

// GetSettingAddress is a free data retrieval call binding the contract method 0x06eaa68b.
//
// Solidity: function getSettingAddress(bytes32 settingNameSpace, string _settingPath) view returns(address)
func (_RewardsPool *RewardsPoolCallerSession) GetSettingAddress(settingNameSpace [32]byte, _settingPath string) (common.Address, error) {
	return _RewardsPool.Contract.GetSettingAddress(&_RewardsPool.CallOpts, settingNameSpace, _settingPath)
}

// GetSettingBool is a free data retrieval call binding the contract method 0x232de716.
//
// Solidity: function getSettingBool(bytes32 settingNameSpace, string _settingPath) view returns(bool)
func (_RewardsPool *RewardsPoolCaller) GetSettingBool(opts *bind.CallOpts, settingNameSpace [32]byte, _settingPath string) (bool, error) {
	var out []interface{}
	err := _RewardsPool.contract.Call(opts, &out, "getSettingBool", settingNameSpace, _settingPath)

	if err != nil {
		return *new(bool), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)

	return out0, err

}

// GetSettingBool is a free data retrieval call binding the contract method 0x232de716.
//
// Solidity: function getSettingBool(bytes32 settingNameSpace, string _settingPath) view returns(bool)
func (_RewardsPool *RewardsPoolSession) GetSettingBool(settingNameSpace [32]byte, _settingPath string) (bool, error) {
	return _RewardsPool.Contract.GetSettingBool(&_RewardsPool.CallOpts, settingNameSpace, _settingPath)
}

// GetSettingBool is a free data retrieval call binding the contract method 0x232de716.
//
// Solidity: function getSettingBool(bytes32 settingNameSpace, string _settingPath) view returns(bool)
func (_RewardsPool *RewardsPoolCallerSession) GetSettingBool(settingNameSpace [32]byte, _settingPath string) (bool, error) {
	return _RewardsPool.Contract.GetSettingBool(&_RewardsPool.CallOpts, settingNameSpace, _settingPath)
}

// GetSettingUint is a free data retrieval call binding the contract method 0xf4d70e78.
//
// Solidity: function getSettingUint(bytes32 settingNameSpace, string _settingPath) view returns(uint256)
func (_RewardsPool *RewardsPoolCaller) GetSettingUint(opts *bind.CallOpts, settingNameSpace [32]byte, _settingPath string) (*big.Int, error) {
	var out []interface{}
	err := _RewardsPool.contract.Call(opts, &out, "getSettingUint", settingNameSpace, _settingPath)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetSettingUint is a free data retrieval call binding the contract method 0xf4d70e78.
//
// Solidity: function getSettingUint(bytes32 settingNameSpace, string _settingPath) view returns(uint256)
func (_RewardsPool *RewardsPoolSession) GetSettingUint(settingNameSpace [32]byte, _settingPath string) (*big.Int, error) {
	return _RewardsPool.Contract.GetSettingUint(&_RewardsPool.CallOpts, settingNameSpace, _settingPath)
}

// GetSettingUint is a free data retrieval call binding the contract method 0xf4d70e78.
//
// Solidity: function getSettingUint(bytes32 settingNameSpace, string _settingPath) view returns(uint256)
func (_RewardsPool *RewardsPoolCallerSession) GetSettingUint(settingNameSpace [32]byte, _settingPath string) (*big.Int, error) {
	return _RewardsPool.Contract.GetSettingUint(&_RewardsPool.CallOpts, settingNameSpace, _settingPath)
}

// GetTotalGGPCirculatingSupply is a free data retrieval call binding the contract method 0x2ffc52ee.
//
// Solidity: function getTotalGGPCirculatingSupply() view returns(uint256)
func (_RewardsPool *RewardsPoolCaller) GetTotalGGPCirculatingSupply(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _RewardsPool.contract.Call(opts, &out, "getTotalGGPCirculatingSupply")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetTotalGGPCirculatingSupply is a free data retrieval call binding the contract method 0x2ffc52ee.
//
// Solidity: function getTotalGGPCirculatingSupply() view returns(uint256)
func (_RewardsPool *RewardsPoolSession) GetTotalGGPCirculatingSupply() (*big.Int, error) {
	return _RewardsPool.Contract.GetTotalGGPCirculatingSupply(&_RewardsPool.CallOpts)
}

// GetTotalGGPCirculatingSupply is a free data retrieval call binding the contract method 0x2ffc52ee.
//
// Solidity: function getTotalGGPCirculatingSupply() view returns(uint256)
func (_RewardsPool *RewardsPoolCallerSession) GetTotalGGPCirculatingSupply() (*big.Int, error) {
	return _RewardsPool.Contract.GetTotalGGPCirculatingSupply(&_RewardsPool.CallOpts)
}

// InflationCalculate is a free data retrieval call binding the contract method 0xc1a26006.
//
// Solidity: function inflationCalculate() view returns(uint256)
func (_RewardsPool *RewardsPoolCaller) InflationCalculate(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _RewardsPool.contract.Call(opts, &out, "inflationCalculate")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// InflationCalculate is a free data retrieval call binding the contract method 0xc1a26006.
//
// Solidity: function inflationCalculate() view returns(uint256)
func (_RewardsPool *RewardsPoolSession) InflationCalculate() (*big.Int, error) {
	return _RewardsPool.Contract.InflationCalculate(&_RewardsPool.CallOpts)
}

// InflationCalculate is a free data retrieval call binding the contract method 0xc1a26006.
//
// Solidity: function inflationCalculate() view returns(uint256)
func (_RewardsPool *RewardsPoolCallerSession) InflationCalculate() (*big.Int, error) {
	return _RewardsPool.Contract.InflationCalculate(&_RewardsPool.CallOpts)
}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint8)
func (_RewardsPool *RewardsPoolCaller) Version(opts *bind.CallOpts) (uint8, error) {
	var out []interface{}
	err := _RewardsPool.contract.Call(opts, &out, "version")

	if err != nil {
		return *new(uint8), err
	}

	out0 := *abi.ConvertType(out[0], new(uint8)).(*uint8)

	return out0, err

}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint8)
func (_RewardsPool *RewardsPoolSession) Version() (uint8, error) {
	return _RewardsPool.Contract.Version(&_RewardsPool.CallOpts)
}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint8)
func (_RewardsPool *RewardsPoolCallerSession) Version() (uint8, error) {
	return _RewardsPool.Contract.Version(&_RewardsPool.CallOpts)
}

// StartCycle is a paid mutator transaction binding the contract method 0x562cad23.
//
// Solidity: function startCycle() returns()
func (_RewardsPool *RewardsPoolTransactor) StartCycle(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _RewardsPool.contract.Transact(opts, "startCycle")
}

// StartCycle is a paid mutator transaction binding the contract method 0x562cad23.
//
// Solidity: function startCycle() returns()
func (_RewardsPool *RewardsPoolSession) StartCycle() (*types.Transaction, error) {
	return _RewardsPool.Contract.StartCycle(&_RewardsPool.TransactOpts)
}

// StartCycle is a paid mutator transaction binding the contract method 0x562cad23.
//
// Solidity: function startCycle() returns()
func (_RewardsPool *RewardsPoolTransactorSession) StartCycle() (*types.Transaction, error) {
	return _RewardsPool.Contract.StartCycle(&_RewardsPool.TransactOpts)
}

// RewardsPoolGGPInflationLogIterator is returned from FilterGGPInflationLog and is used to iterate over the raw logs and unpacked data for GGPInflationLog events raised by the RewardsPool contract.
type RewardsPoolGGPInflationLogIterator struct {
	Event *RewardsPoolGGPInflationLog // Event containing the contract specifics and raw log

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
func (it *RewardsPoolGGPInflationLogIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(RewardsPoolGGPInflationLog)
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
		it.Event = new(RewardsPoolGGPInflationLog)
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
func (it *RewardsPoolGGPInflationLogIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *RewardsPoolGGPInflationLogIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// RewardsPoolGGPInflationLog represents a GGPInflationLog event raised by the RewardsPool contract.
type RewardsPoolGGPInflationLog struct {
	Sender            common.Address
	Value             *big.Int
	InflationCalcTime *big.Int
	Raw               types.Log // Blockchain specific contextual infos
}

// FilterGGPInflationLog is a free log retrieval operation binding the contract event 0x5fdac2d68dba8699193bd645ebe5fa18d2ae4f94c71b9cc5cc66d49b69731eec.
//
// Solidity: event GGPInflationLog(address sender, uint256 value, uint256 inflationCalcTime)
func (_RewardsPool *RewardsPoolFilterer) FilterGGPInflationLog(opts *bind.FilterOpts) (*RewardsPoolGGPInflationLogIterator, error) {

	logs, sub, err := _RewardsPool.contract.FilterLogs(opts, "GGPInflationLog")
	if err != nil {
		return nil, err
	}
	return &RewardsPoolGGPInflationLogIterator{contract: _RewardsPool.contract, event: "GGPInflationLog", logs: logs, sub: sub}, nil
}

// WatchGGPInflationLog is a free log subscription operation binding the contract event 0x5fdac2d68dba8699193bd645ebe5fa18d2ae4f94c71b9cc5cc66d49b69731eec.
//
// Solidity: event GGPInflationLog(address sender, uint256 value, uint256 inflationCalcTime)
func (_RewardsPool *RewardsPoolFilterer) WatchGGPInflationLog(opts *bind.WatchOpts, sink chan<- *RewardsPoolGGPInflationLog) (event.Subscription, error) {

	logs, sub, err := _RewardsPool.contract.WatchLogs(opts, "GGPInflationLog")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(RewardsPoolGGPInflationLog)
				if err := _RewardsPool.contract.UnpackLog(event, "GGPInflationLog", log); err != nil {
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

// ParseGGPInflationLog is a log parse operation binding the contract event 0x5fdac2d68dba8699193bd645ebe5fa18d2ae4f94c71b9cc5cc66d49b69731eec.
//
// Solidity: event GGPInflationLog(address sender, uint256 value, uint256 inflationCalcTime)
func (_RewardsPool *RewardsPoolFilterer) ParseGGPInflationLog(log types.Log) (*RewardsPoolGGPInflationLog, error) {
	event := new(RewardsPoolGGPInflationLog)
	if err := _RewardsPool.contract.UnpackLog(event, "GGPInflationLog", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// RewardsPoolNOPClaimRewardsTransferedIterator is returned from FilterNOPClaimRewardsTransfered and is used to iterate over the raw logs and unpacked data for NOPClaimRewardsTransfered events raised by the RewardsPool contract.
type RewardsPoolNOPClaimRewardsTransferedIterator struct {
	Event *RewardsPoolNOPClaimRewardsTransfered // Event containing the contract specifics and raw log

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
func (it *RewardsPoolNOPClaimRewardsTransferedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(RewardsPoolNOPClaimRewardsTransfered)
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
		it.Event = new(RewardsPoolNOPClaimRewardsTransfered)
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
func (it *RewardsPoolNOPClaimRewardsTransferedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *RewardsPoolNOPClaimRewardsTransferedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// RewardsPoolNOPClaimRewardsTransfered represents a NOPClaimRewardsTransfered event raised by the RewardsPool contract.
type RewardsPoolNOPClaimRewardsTransfered struct {
	Value *big.Int
	Raw   types.Log // Blockchain specific contextual infos
}

// FilterNOPClaimRewardsTransfered is a free log retrieval operation binding the contract event 0x82c02c8f9f42f7ad10a17c2b6dd1d52619ca310cae1c2e9638174fd53217284b.
//
// Solidity: event NOPClaimRewardsTransfered(uint256 value)
func (_RewardsPool *RewardsPoolFilterer) FilterNOPClaimRewardsTransfered(opts *bind.FilterOpts) (*RewardsPoolNOPClaimRewardsTransferedIterator, error) {

	logs, sub, err := _RewardsPool.contract.FilterLogs(opts, "NOPClaimRewardsTransfered")
	if err != nil {
		return nil, err
	}
	return &RewardsPoolNOPClaimRewardsTransferedIterator{contract: _RewardsPool.contract, event: "NOPClaimRewardsTransfered", logs: logs, sub: sub}, nil
}

// WatchNOPClaimRewardsTransfered is a free log subscription operation binding the contract event 0x82c02c8f9f42f7ad10a17c2b6dd1d52619ca310cae1c2e9638174fd53217284b.
//
// Solidity: event NOPClaimRewardsTransfered(uint256 value)
func (_RewardsPool *RewardsPoolFilterer) WatchNOPClaimRewardsTransfered(opts *bind.WatchOpts, sink chan<- *RewardsPoolNOPClaimRewardsTransfered) (event.Subscription, error) {

	logs, sub, err := _RewardsPool.contract.WatchLogs(opts, "NOPClaimRewardsTransfered")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(RewardsPoolNOPClaimRewardsTransfered)
				if err := _RewardsPool.contract.UnpackLog(event, "NOPClaimRewardsTransfered", log); err != nil {
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

// ParseNOPClaimRewardsTransfered is a log parse operation binding the contract event 0x82c02c8f9f42f7ad10a17c2b6dd1d52619ca310cae1c2e9638174fd53217284b.
//
// Solidity: event NOPClaimRewardsTransfered(uint256 value)
func (_RewardsPool *RewardsPoolFilterer) ParseNOPClaimRewardsTransfered(log types.Log) (*RewardsPoolNOPClaimRewardsTransfered, error) {
	event := new(RewardsPoolNOPClaimRewardsTransfered)
	if err := _RewardsPool.contract.UnpackLog(event, "NOPClaimRewardsTransfered", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// RewardsPoolNewRewardsCycleStartedIterator is returned from FilterNewRewardsCycleStarted and is used to iterate over the raw logs and unpacked data for NewRewardsCycleStarted events raised by the RewardsPool contract.
type RewardsPoolNewRewardsCycleStartedIterator struct {
	Event *RewardsPoolNewRewardsCycleStarted // Event containing the contract specifics and raw log

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
func (it *RewardsPoolNewRewardsCycleStartedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(RewardsPoolNewRewardsCycleStarted)
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
		it.Event = new(RewardsPoolNewRewardsCycleStarted)
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
func (it *RewardsPoolNewRewardsCycleStartedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *RewardsPoolNewRewardsCycleStartedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// RewardsPoolNewRewardsCycleStarted represents a NewRewardsCycleStarted event raised by the RewardsPool contract.
type RewardsPoolNewRewardsCycleStarted struct {
	TotalRewardAmt *big.Int
	Raw            types.Log // Blockchain specific contextual infos
}

// FilterNewRewardsCycleStarted is a free log retrieval operation binding the contract event 0x6b1d3dc5fce42913ead941789ebaa30a3b9d2f7d03eb1b72664ef963af99a4c8.
//
// Solidity: event NewRewardsCycleStarted(uint256 totalRewardAmt)
func (_RewardsPool *RewardsPoolFilterer) FilterNewRewardsCycleStarted(opts *bind.FilterOpts) (*RewardsPoolNewRewardsCycleStartedIterator, error) {

	logs, sub, err := _RewardsPool.contract.FilterLogs(opts, "NewRewardsCycleStarted")
	if err != nil {
		return nil, err
	}
	return &RewardsPoolNewRewardsCycleStartedIterator{contract: _RewardsPool.contract, event: "NewRewardsCycleStarted", logs: logs, sub: sub}, nil
}

// WatchNewRewardsCycleStarted is a free log subscription operation binding the contract event 0x6b1d3dc5fce42913ead941789ebaa30a3b9d2f7d03eb1b72664ef963af99a4c8.
//
// Solidity: event NewRewardsCycleStarted(uint256 totalRewardAmt)
func (_RewardsPool *RewardsPoolFilterer) WatchNewRewardsCycleStarted(opts *bind.WatchOpts, sink chan<- *RewardsPoolNewRewardsCycleStarted) (event.Subscription, error) {

	logs, sub, err := _RewardsPool.contract.WatchLogs(opts, "NewRewardsCycleStarted")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(RewardsPoolNewRewardsCycleStarted)
				if err := _RewardsPool.contract.UnpackLog(event, "NewRewardsCycleStarted", log); err != nil {
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

// ParseNewRewardsCycleStarted is a log parse operation binding the contract event 0x6b1d3dc5fce42913ead941789ebaa30a3b9d2f7d03eb1b72664ef963af99a4c8.
//
// Solidity: event NewRewardsCycleStarted(uint256 totalRewardAmt)
func (_RewardsPool *RewardsPoolFilterer) ParseNewRewardsCycleStarted(log types.Log) (*RewardsPoolNewRewardsCycleStarted, error) {
	event := new(RewardsPoolNewRewardsCycleStarted)
	if err := _RewardsPool.contract.UnpackLog(event, "NewRewardsCycleStarted", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// RewardsPoolProtocolDAORewardsTransferedIterator is returned from FilterProtocolDAORewardsTransfered and is used to iterate over the raw logs and unpacked data for ProtocolDAORewardsTransfered events raised by the RewardsPool contract.
type RewardsPoolProtocolDAORewardsTransferedIterator struct {
	Event *RewardsPoolProtocolDAORewardsTransfered // Event containing the contract specifics and raw log

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
func (it *RewardsPoolProtocolDAORewardsTransferedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(RewardsPoolProtocolDAORewardsTransfered)
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
		it.Event = new(RewardsPoolProtocolDAORewardsTransfered)
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
func (it *RewardsPoolProtocolDAORewardsTransferedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *RewardsPoolProtocolDAORewardsTransferedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// RewardsPoolProtocolDAORewardsTransfered represents a ProtocolDAORewardsTransfered event raised by the RewardsPool contract.
type RewardsPoolProtocolDAORewardsTransfered struct {
	Value *big.Int
	Raw   types.Log // Blockchain specific contextual infos
}

// FilterProtocolDAORewardsTransfered is a free log retrieval operation binding the contract event 0x08839a63ce86957af0da1fd5b80ebfffeeb19d123ab6709e765ccae050041b10.
//
// Solidity: event ProtocolDAORewardsTransfered(uint256 value)
func (_RewardsPool *RewardsPoolFilterer) FilterProtocolDAORewardsTransfered(opts *bind.FilterOpts) (*RewardsPoolProtocolDAORewardsTransferedIterator, error) {

	logs, sub, err := _RewardsPool.contract.FilterLogs(opts, "ProtocolDAORewardsTransfered")
	if err != nil {
		return nil, err
	}
	return &RewardsPoolProtocolDAORewardsTransferedIterator{contract: _RewardsPool.contract, event: "ProtocolDAORewardsTransfered", logs: logs, sub: sub}, nil
}

// WatchProtocolDAORewardsTransfered is a free log subscription operation binding the contract event 0x08839a63ce86957af0da1fd5b80ebfffeeb19d123ab6709e765ccae050041b10.
//
// Solidity: event ProtocolDAORewardsTransfered(uint256 value)
func (_RewardsPool *RewardsPoolFilterer) WatchProtocolDAORewardsTransfered(opts *bind.WatchOpts, sink chan<- *RewardsPoolProtocolDAORewardsTransfered) (event.Subscription, error) {

	logs, sub, err := _RewardsPool.contract.WatchLogs(opts, "ProtocolDAORewardsTransfered")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(RewardsPoolProtocolDAORewardsTransfered)
				if err := _RewardsPool.contract.UnpackLog(event, "ProtocolDAORewardsTransfered", log); err != nil {
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

// ParseProtocolDAORewardsTransfered is a log parse operation binding the contract event 0x08839a63ce86957af0da1fd5b80ebfffeeb19d123ab6709e765ccae050041b10.
//
// Solidity: event ProtocolDAORewardsTransfered(uint256 value)
func (_RewardsPool *RewardsPoolFilterer) ParseProtocolDAORewardsTransfered(log types.Log) (*RewardsPoolProtocolDAORewardsTransfered, error) {
	event := new(RewardsPoolProtocolDAORewardsTransfered)
	if err := _RewardsPool.contract.UnpackLog(event, "ProtocolDAORewardsTransfered", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
