// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package staking

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

// StakingStaker is an auto generated low-level Go binding around an user-defined struct.
type StakingStaker struct {
	StakerAddr            common.Address
	GgpStaked             *big.Int
	AvaxStaked            *big.Int
	AvaxAssigned          *big.Int
	AvaxAssignedHighWater *big.Int
	MinipoolCount         *big.Int
	RewardsStartTime      *big.Int
	GgpRewards            *big.Int
}

// StakingMetaData contains all meta data concerning the Staking contract.
var StakingMetaData = &bind.MetaData{
	ABI: "[{\"inputs\":[{\"internalType\":\"contractStorage\",\"name\":\"storageAddress\",\"type\":\"address\"},{\"internalType\":\"contractERC20\",\"name\":\"ggp_\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"inputs\":[],\"name\":\"CannotWithdrawUnder150CollateralizationRatio\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"ContractNotFound\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"ContractPaused\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"InsufficientBalance\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"InvalidOrOutdatedContract\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"MustBeGuardian\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"MustBeGuardianOrValidContract\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"MustBeMultisig\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"StakerNotFound\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"TransferFailed\",\"type\":\"error\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"from\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"GGPStaked\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"to\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"GGPWithdrawn\",\"type\":\"event\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"decreaseAVAXAssigned\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"decreaseAVAXStake\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"decreaseGGPRewards\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"}],\"name\":\"decreaseMinipoolCount\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"}],\"name\":\"getAVAXAssigned\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"}],\"name\":\"getAVAXAssignedHighWater\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"}],\"name\":\"getAVAXStake\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"}],\"name\":\"getCollateralizationRatio\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"string\",\"name\":\"contractName\",\"type\":\"string\"}],\"name\":\"getContractAddress\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"}],\"name\":\"getEffectiveGGPStaked\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"}],\"name\":\"getEffectiveRewardsRatio\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"}],\"name\":\"getGGPRewards\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"}],\"name\":\"getGGPStake\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"}],\"name\":\"getIndexOf\",\"outputs\":[{\"internalType\":\"int256\",\"name\":\"\",\"type\":\"int256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"}],\"name\":\"getMinimumGGPStake\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"}],\"name\":\"getMinipoolCount\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"}],\"name\":\"getRewardsStartTime\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"int256\",\"name\":\"stakerIndex\",\"type\":\"int256\"}],\"name\":\"getStaker\",\"outputs\":[{\"components\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"ggpStaked\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"avaxStaked\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"avaxAssigned\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"avaxAssignedHighWater\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"minipoolCount\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"rewardsStartTime\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"ggpRewards\",\"type\":\"uint256\"}],\"internalType\":\"structStaking.Staker\",\"name\":\"staker\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getStakerCount\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"offset\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"limit\",\"type\":\"uint256\"}],\"name\":\"getStakers\",\"outputs\":[{\"components\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"ggpStaked\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"avaxStaked\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"avaxAssigned\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"avaxAssignedHighWater\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"minipoolCount\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"rewardsStartTime\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"ggpRewards\",\"type\":\"uint256\"}],\"internalType\":\"structStaking.Staker[]\",\"name\":\"stakers\",\"type\":\"tuple[]\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getTotalGGPStake\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"ggp\",\"outputs\":[{\"internalType\":\"contractERC20\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"increaseAVAXAssigned\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"increaseAVAXStake\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"increaseGGPRewards\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"}],\"name\":\"increaseMinipoolCount\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"}],\"name\":\"requireValidStaker\",\"outputs\":[{\"internalType\":\"int256\",\"name\":\"\",\"type\":\"int256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"}],\"name\":\"resetAVAXAssignedHighWater\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddress\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"restakeGGP\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"time\",\"type\":\"uint256\"}],\"name\":\"setRewardsStartTime\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"stakerAddr\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"ggpAmt\",\"type\":\"uint256\"}],\"name\":\"slashGGP\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"stakeGGP\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"internalType\":\"uint8\",\"name\":\"\",\"type\":\"uint8\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"withdrawGGP\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]",
}

// StakingABI is the input ABI used to generate the binding from.
// Deprecated: Use StakingMetaData.ABI instead.
var StakingABI = StakingMetaData.ABI

// Staking is an auto generated Go binding around an Ethereum contract.
type Staking struct {
	StakingCaller     // Read-only binding to the contract
	StakingTransactor // Write-only binding to the contract
	StakingFilterer   // Log filterer for contract events
}

// StakingCaller is an auto generated read-only Go binding around an Ethereum contract.
type StakingCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// StakingTransactor is an auto generated write-only Go binding around an Ethereum contract.
type StakingTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// StakingFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type StakingFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// StakingSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type StakingSession struct {
	Contract     *Staking          // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// StakingCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type StakingCallerSession struct {
	Contract *StakingCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts  // Call options to use throughout this session
}

// StakingTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type StakingTransactorSession struct {
	Contract     *StakingTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts  // Transaction auth options to use throughout this session
}

// StakingRaw is an auto generated low-level Go binding around an Ethereum contract.
type StakingRaw struct {
	Contract *Staking // Generic contract binding to access the raw methods on
}

// StakingCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type StakingCallerRaw struct {
	Contract *StakingCaller // Generic read-only contract binding to access the raw methods on
}

// StakingTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type StakingTransactorRaw struct {
	Contract *StakingTransactor // Generic write-only contract binding to access the raw methods on
}

// NewStaking creates a new instance of Staking, bound to a specific deployed contract.
func NewStaking(address common.Address, backend bind.ContractBackend) (*Staking, error) {
	contract, err := bindStaking(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &Staking{StakingCaller: StakingCaller{contract: contract}, StakingTransactor: StakingTransactor{contract: contract}, StakingFilterer: StakingFilterer{contract: contract}}, nil
}

// NewStakingCaller creates a new read-only instance of Staking, bound to a specific deployed contract.
func NewStakingCaller(address common.Address, caller bind.ContractCaller) (*StakingCaller, error) {
	contract, err := bindStaking(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &StakingCaller{contract: contract}, nil
}

// NewStakingTransactor creates a new write-only instance of Staking, bound to a specific deployed contract.
func NewStakingTransactor(address common.Address, transactor bind.ContractTransactor) (*StakingTransactor, error) {
	contract, err := bindStaking(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &StakingTransactor{contract: contract}, nil
}

// NewStakingFilterer creates a new log filterer instance of Staking, bound to a specific deployed contract.
func NewStakingFilterer(address common.Address, filterer bind.ContractFilterer) (*StakingFilterer, error) {
	contract, err := bindStaking(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &StakingFilterer{contract: contract}, nil
}

// bindStaking binds a generic wrapper to an already deployed contract.
func bindStaking(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := abi.JSON(strings.NewReader(StakingABI))
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_Staking *StakingRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _Staking.Contract.StakingCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_Staking *StakingRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Staking.Contract.StakingTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_Staking *StakingRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _Staking.Contract.StakingTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_Staking *StakingCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _Staking.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_Staking *StakingTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Staking.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_Staking *StakingTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _Staking.Contract.contract.Transact(opts, method, params...)
}

// GetAVAXAssigned is a free data retrieval call binding the contract method 0x799c515d.
//
// Solidity: function getAVAXAssigned(address stakerAddr) view returns(uint256)
func (_Staking *StakingCaller) GetAVAXAssigned(opts *bind.CallOpts, stakerAddr common.Address) (*big.Int, error) {
	var out []interface{}
	err := _Staking.contract.Call(opts, &out, "getAVAXAssigned", stakerAddr)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetAVAXAssigned is a free data retrieval call binding the contract method 0x799c515d.
//
// Solidity: function getAVAXAssigned(address stakerAddr) view returns(uint256)
func (_Staking *StakingSession) GetAVAXAssigned(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetAVAXAssigned(&_Staking.CallOpts, stakerAddr)
}

// GetAVAXAssigned is a free data retrieval call binding the contract method 0x799c515d.
//
// Solidity: function getAVAXAssigned(address stakerAddr) view returns(uint256)
func (_Staking *StakingCallerSession) GetAVAXAssigned(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetAVAXAssigned(&_Staking.CallOpts, stakerAddr)
}

// GetAVAXAssignedHighWater is a free data retrieval call binding the contract method 0x4ce3d572.
//
// Solidity: function getAVAXAssignedHighWater(address stakerAddr) view returns(uint256)
func (_Staking *StakingCaller) GetAVAXAssignedHighWater(opts *bind.CallOpts, stakerAddr common.Address) (*big.Int, error) {
	var out []interface{}
	err := _Staking.contract.Call(opts, &out, "getAVAXAssignedHighWater", stakerAddr)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetAVAXAssignedHighWater is a free data retrieval call binding the contract method 0x4ce3d572.
//
// Solidity: function getAVAXAssignedHighWater(address stakerAddr) view returns(uint256)
func (_Staking *StakingSession) GetAVAXAssignedHighWater(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetAVAXAssignedHighWater(&_Staking.CallOpts, stakerAddr)
}

// GetAVAXAssignedHighWater is a free data retrieval call binding the contract method 0x4ce3d572.
//
// Solidity: function getAVAXAssignedHighWater(address stakerAddr) view returns(uint256)
func (_Staking *StakingCallerSession) GetAVAXAssignedHighWater(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetAVAXAssignedHighWater(&_Staking.CallOpts, stakerAddr)
}

// GetAVAXStake is a free data retrieval call binding the contract method 0x09e203a5.
//
// Solidity: function getAVAXStake(address stakerAddr) view returns(uint256)
func (_Staking *StakingCaller) GetAVAXStake(opts *bind.CallOpts, stakerAddr common.Address) (*big.Int, error) {
	var out []interface{}
	err := _Staking.contract.Call(opts, &out, "getAVAXStake", stakerAddr)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetAVAXStake is a free data retrieval call binding the contract method 0x09e203a5.
//
// Solidity: function getAVAXStake(address stakerAddr) view returns(uint256)
func (_Staking *StakingSession) GetAVAXStake(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetAVAXStake(&_Staking.CallOpts, stakerAddr)
}

// GetAVAXStake is a free data retrieval call binding the contract method 0x09e203a5.
//
// Solidity: function getAVAXStake(address stakerAddr) view returns(uint256)
func (_Staking *StakingCallerSession) GetAVAXStake(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetAVAXStake(&_Staking.CallOpts, stakerAddr)
}

// GetCollateralizationRatio is a free data retrieval call binding the contract method 0xed54ff22.
//
// Solidity: function getCollateralizationRatio(address stakerAddr) view returns(uint256)
func (_Staking *StakingCaller) GetCollateralizationRatio(opts *bind.CallOpts, stakerAddr common.Address) (*big.Int, error) {
	var out []interface{}
	err := _Staking.contract.Call(opts, &out, "getCollateralizationRatio", stakerAddr)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetCollateralizationRatio is a free data retrieval call binding the contract method 0xed54ff22.
//
// Solidity: function getCollateralizationRatio(address stakerAddr) view returns(uint256)
func (_Staking *StakingSession) GetCollateralizationRatio(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetCollateralizationRatio(&_Staking.CallOpts, stakerAddr)
}

// GetCollateralizationRatio is a free data retrieval call binding the contract method 0xed54ff22.
//
// Solidity: function getCollateralizationRatio(address stakerAddr) view returns(uint256)
func (_Staking *StakingCallerSession) GetCollateralizationRatio(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetCollateralizationRatio(&_Staking.CallOpts, stakerAddr)
}

// GetContractAddress is a free data retrieval call binding the contract method 0x04433bbc.
//
// Solidity: function getContractAddress(string contractName) view returns(address)
func (_Staking *StakingCaller) GetContractAddress(opts *bind.CallOpts, contractName string) (common.Address, error) {
	var out []interface{}
	err := _Staking.contract.Call(opts, &out, "getContractAddress", contractName)

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// GetContractAddress is a free data retrieval call binding the contract method 0x04433bbc.
//
// Solidity: function getContractAddress(string contractName) view returns(address)
func (_Staking *StakingSession) GetContractAddress(contractName string) (common.Address, error) {
	return _Staking.Contract.GetContractAddress(&_Staking.CallOpts, contractName)
}

// GetContractAddress is a free data retrieval call binding the contract method 0x04433bbc.
//
// Solidity: function getContractAddress(string contractName) view returns(address)
func (_Staking *StakingCallerSession) GetContractAddress(contractName string) (common.Address, error) {
	return _Staking.Contract.GetContractAddress(&_Staking.CallOpts, contractName)
}

// GetEffectiveGGPStaked is a free data retrieval call binding the contract method 0x7736b4d4.
//
// Solidity: function getEffectiveGGPStaked(address stakerAddr) view returns(uint256)
func (_Staking *StakingCaller) GetEffectiveGGPStaked(opts *bind.CallOpts, stakerAddr common.Address) (*big.Int, error) {
	var out []interface{}
	err := _Staking.contract.Call(opts, &out, "getEffectiveGGPStaked", stakerAddr)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetEffectiveGGPStaked is a free data retrieval call binding the contract method 0x7736b4d4.
//
// Solidity: function getEffectiveGGPStaked(address stakerAddr) view returns(uint256)
func (_Staking *StakingSession) GetEffectiveGGPStaked(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetEffectiveGGPStaked(&_Staking.CallOpts, stakerAddr)
}

// GetEffectiveGGPStaked is a free data retrieval call binding the contract method 0x7736b4d4.
//
// Solidity: function getEffectiveGGPStaked(address stakerAddr) view returns(uint256)
func (_Staking *StakingCallerSession) GetEffectiveGGPStaked(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetEffectiveGGPStaked(&_Staking.CallOpts, stakerAddr)
}

// GetEffectiveRewardsRatio is a free data retrieval call binding the contract method 0xdb865f88.
//
// Solidity: function getEffectiveRewardsRatio(address stakerAddr) view returns(uint256)
func (_Staking *StakingCaller) GetEffectiveRewardsRatio(opts *bind.CallOpts, stakerAddr common.Address) (*big.Int, error) {
	var out []interface{}
	err := _Staking.contract.Call(opts, &out, "getEffectiveRewardsRatio", stakerAddr)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetEffectiveRewardsRatio is a free data retrieval call binding the contract method 0xdb865f88.
//
// Solidity: function getEffectiveRewardsRatio(address stakerAddr) view returns(uint256)
func (_Staking *StakingSession) GetEffectiveRewardsRatio(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetEffectiveRewardsRatio(&_Staking.CallOpts, stakerAddr)
}

// GetEffectiveRewardsRatio is a free data retrieval call binding the contract method 0xdb865f88.
//
// Solidity: function getEffectiveRewardsRatio(address stakerAddr) view returns(uint256)
func (_Staking *StakingCallerSession) GetEffectiveRewardsRatio(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetEffectiveRewardsRatio(&_Staking.CallOpts, stakerAddr)
}

// GetGGPRewards is a free data retrieval call binding the contract method 0xe60716d7.
//
// Solidity: function getGGPRewards(address stakerAddr) view returns(uint256)
func (_Staking *StakingCaller) GetGGPRewards(opts *bind.CallOpts, stakerAddr common.Address) (*big.Int, error) {
	var out []interface{}
	err := _Staking.contract.Call(opts, &out, "getGGPRewards", stakerAddr)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetGGPRewards is a free data retrieval call binding the contract method 0xe60716d7.
//
// Solidity: function getGGPRewards(address stakerAddr) view returns(uint256)
func (_Staking *StakingSession) GetGGPRewards(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetGGPRewards(&_Staking.CallOpts, stakerAddr)
}

// GetGGPRewards is a free data retrieval call binding the contract method 0xe60716d7.
//
// Solidity: function getGGPRewards(address stakerAddr) view returns(uint256)
func (_Staking *StakingCallerSession) GetGGPRewards(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetGGPRewards(&_Staking.CallOpts, stakerAddr)
}

// GetGGPStake is a free data retrieval call binding the contract method 0x8823169c.
//
// Solidity: function getGGPStake(address stakerAddr) view returns(uint256)
func (_Staking *StakingCaller) GetGGPStake(opts *bind.CallOpts, stakerAddr common.Address) (*big.Int, error) {
	var out []interface{}
	err := _Staking.contract.Call(opts, &out, "getGGPStake", stakerAddr)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetGGPStake is a free data retrieval call binding the contract method 0x8823169c.
//
// Solidity: function getGGPStake(address stakerAddr) view returns(uint256)
func (_Staking *StakingSession) GetGGPStake(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetGGPStake(&_Staking.CallOpts, stakerAddr)
}

// GetGGPStake is a free data retrieval call binding the contract method 0x8823169c.
//
// Solidity: function getGGPStake(address stakerAddr) view returns(uint256)
func (_Staking *StakingCallerSession) GetGGPStake(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetGGPStake(&_Staking.CallOpts, stakerAddr)
}

// GetIndexOf is a free data retrieval call binding the contract method 0x017df522.
//
// Solidity: function getIndexOf(address stakerAddr) view returns(int256)
func (_Staking *StakingCaller) GetIndexOf(opts *bind.CallOpts, stakerAddr common.Address) (*big.Int, error) {
	var out []interface{}
	err := _Staking.contract.Call(opts, &out, "getIndexOf", stakerAddr)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetIndexOf is a free data retrieval call binding the contract method 0x017df522.
//
// Solidity: function getIndexOf(address stakerAddr) view returns(int256)
func (_Staking *StakingSession) GetIndexOf(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetIndexOf(&_Staking.CallOpts, stakerAddr)
}

// GetIndexOf is a free data retrieval call binding the contract method 0x017df522.
//
// Solidity: function getIndexOf(address stakerAddr) view returns(int256)
func (_Staking *StakingCallerSession) GetIndexOf(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetIndexOf(&_Staking.CallOpts, stakerAddr)
}

// GetMinimumGGPStake is a free data retrieval call binding the contract method 0x1cbce7af.
//
// Solidity: function getMinimumGGPStake(address stakerAddr) view returns(uint256)
func (_Staking *StakingCaller) GetMinimumGGPStake(opts *bind.CallOpts, stakerAddr common.Address) (*big.Int, error) {
	var out []interface{}
	err := _Staking.contract.Call(opts, &out, "getMinimumGGPStake", stakerAddr)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetMinimumGGPStake is a free data retrieval call binding the contract method 0x1cbce7af.
//
// Solidity: function getMinimumGGPStake(address stakerAddr) view returns(uint256)
func (_Staking *StakingSession) GetMinimumGGPStake(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetMinimumGGPStake(&_Staking.CallOpts, stakerAddr)
}

// GetMinimumGGPStake is a free data retrieval call binding the contract method 0x1cbce7af.
//
// Solidity: function getMinimumGGPStake(address stakerAddr) view returns(uint256)
func (_Staking *StakingCallerSession) GetMinimumGGPStake(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetMinimumGGPStake(&_Staking.CallOpts, stakerAddr)
}

// GetMinipoolCount is a free data retrieval call binding the contract method 0xa0b2c3e5.
//
// Solidity: function getMinipoolCount(address stakerAddr) view returns(uint256)
func (_Staking *StakingCaller) GetMinipoolCount(opts *bind.CallOpts, stakerAddr common.Address) (*big.Int, error) {
	var out []interface{}
	err := _Staking.contract.Call(opts, &out, "getMinipoolCount", stakerAddr)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetMinipoolCount is a free data retrieval call binding the contract method 0xa0b2c3e5.
//
// Solidity: function getMinipoolCount(address stakerAddr) view returns(uint256)
func (_Staking *StakingSession) GetMinipoolCount(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetMinipoolCount(&_Staking.CallOpts, stakerAddr)
}

// GetMinipoolCount is a free data retrieval call binding the contract method 0xa0b2c3e5.
//
// Solidity: function getMinipoolCount(address stakerAddr) view returns(uint256)
func (_Staking *StakingCallerSession) GetMinipoolCount(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetMinipoolCount(&_Staking.CallOpts, stakerAddr)
}

// GetRewardsStartTime is a free data retrieval call binding the contract method 0x6e333967.
//
// Solidity: function getRewardsStartTime(address stakerAddr) view returns(uint256)
func (_Staking *StakingCaller) GetRewardsStartTime(opts *bind.CallOpts, stakerAddr common.Address) (*big.Int, error) {
	var out []interface{}
	err := _Staking.contract.Call(opts, &out, "getRewardsStartTime", stakerAddr)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetRewardsStartTime is a free data retrieval call binding the contract method 0x6e333967.
//
// Solidity: function getRewardsStartTime(address stakerAddr) view returns(uint256)
func (_Staking *StakingSession) GetRewardsStartTime(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetRewardsStartTime(&_Staking.CallOpts, stakerAddr)
}

// GetRewardsStartTime is a free data retrieval call binding the contract method 0x6e333967.
//
// Solidity: function getRewardsStartTime(address stakerAddr) view returns(uint256)
func (_Staking *StakingCallerSession) GetRewardsStartTime(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.GetRewardsStartTime(&_Staking.CallOpts, stakerAddr)
}

// GetStaker is a free data retrieval call binding the contract method 0x5a585185.
//
// Solidity: function getStaker(int256 stakerIndex) view returns((address,uint256,uint256,uint256,uint256,uint256,uint256,uint256) staker)
func (_Staking *StakingCaller) GetStaker(opts *bind.CallOpts, stakerIndex *big.Int) (StakingStaker, error) {
	var out []interface{}
	err := _Staking.contract.Call(opts, &out, "getStaker", stakerIndex)

	if err != nil {
		return *new(StakingStaker), err
	}

	out0 := *abi.ConvertType(out[0], new(StakingStaker)).(*StakingStaker)

	return out0, err

}

// GetStaker is a free data retrieval call binding the contract method 0x5a585185.
//
// Solidity: function getStaker(int256 stakerIndex) view returns((address,uint256,uint256,uint256,uint256,uint256,uint256,uint256) staker)
func (_Staking *StakingSession) GetStaker(stakerIndex *big.Int) (StakingStaker, error) {
	return _Staking.Contract.GetStaker(&_Staking.CallOpts, stakerIndex)
}

// GetStaker is a free data retrieval call binding the contract method 0x5a585185.
//
// Solidity: function getStaker(int256 stakerIndex) view returns((address,uint256,uint256,uint256,uint256,uint256,uint256,uint256) staker)
func (_Staking *StakingCallerSession) GetStaker(stakerIndex *big.Int) (StakingStaker, error) {
	return _Staking.Contract.GetStaker(&_Staking.CallOpts, stakerIndex)
}

// GetStakerCount is a free data retrieval call binding the contract method 0x1319649d.
//
// Solidity: function getStakerCount() view returns(uint256)
func (_Staking *StakingCaller) GetStakerCount(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _Staking.contract.Call(opts, &out, "getStakerCount")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetStakerCount is a free data retrieval call binding the contract method 0x1319649d.
//
// Solidity: function getStakerCount() view returns(uint256)
func (_Staking *StakingSession) GetStakerCount() (*big.Int, error) {
	return _Staking.Contract.GetStakerCount(&_Staking.CallOpts)
}

// GetStakerCount is a free data retrieval call binding the contract method 0x1319649d.
//
// Solidity: function getStakerCount() view returns(uint256)
func (_Staking *StakingCallerSession) GetStakerCount() (*big.Int, error) {
	return _Staking.Contract.GetStakerCount(&_Staking.CallOpts)
}

// GetStakers is a free data retrieval call binding the contract method 0xad71bd36.
//
// Solidity: function getStakers(uint256 offset, uint256 limit) view returns((address,uint256,uint256,uint256,uint256,uint256,uint256,uint256)[] stakers)
func (_Staking *StakingCaller) GetStakers(opts *bind.CallOpts, offset *big.Int, limit *big.Int) ([]StakingStaker, error) {
	var out []interface{}
	err := _Staking.contract.Call(opts, &out, "getStakers", offset, limit)

	if err != nil {
		return *new([]StakingStaker), err
	}

	out0 := *abi.ConvertType(out[0], new([]StakingStaker)).(*[]StakingStaker)

	return out0, err

}

// GetStakers is a free data retrieval call binding the contract method 0xad71bd36.
//
// Solidity: function getStakers(uint256 offset, uint256 limit) view returns((address,uint256,uint256,uint256,uint256,uint256,uint256,uint256)[] stakers)
func (_Staking *StakingSession) GetStakers(offset *big.Int, limit *big.Int) ([]StakingStaker, error) {
	return _Staking.Contract.GetStakers(&_Staking.CallOpts, offset, limit)
}

// GetStakers is a free data retrieval call binding the contract method 0xad71bd36.
//
// Solidity: function getStakers(uint256 offset, uint256 limit) view returns((address,uint256,uint256,uint256,uint256,uint256,uint256,uint256)[] stakers)
func (_Staking *StakingCallerSession) GetStakers(offset *big.Int, limit *big.Int) ([]StakingStaker, error) {
	return _Staking.Contract.GetStakers(&_Staking.CallOpts, offset, limit)
}

// GetTotalGGPStake is a free data retrieval call binding the contract method 0xbf79cbf6.
//
// Solidity: function getTotalGGPStake() view returns(uint256)
func (_Staking *StakingCaller) GetTotalGGPStake(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _Staking.contract.Call(opts, &out, "getTotalGGPStake")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetTotalGGPStake is a free data retrieval call binding the contract method 0xbf79cbf6.
//
// Solidity: function getTotalGGPStake() view returns(uint256)
func (_Staking *StakingSession) GetTotalGGPStake() (*big.Int, error) {
	return _Staking.Contract.GetTotalGGPStake(&_Staking.CallOpts)
}

// GetTotalGGPStake is a free data retrieval call binding the contract method 0xbf79cbf6.
//
// Solidity: function getTotalGGPStake() view returns(uint256)
func (_Staking *StakingCallerSession) GetTotalGGPStake() (*big.Int, error) {
	return _Staking.Contract.GetTotalGGPStake(&_Staking.CallOpts)
}

// Ggp is a free data retrieval call binding the contract method 0xf321df49.
//
// Solidity: function ggp() view returns(address)
func (_Staking *StakingCaller) Ggp(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _Staking.contract.Call(opts, &out, "ggp")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// Ggp is a free data retrieval call binding the contract method 0xf321df49.
//
// Solidity: function ggp() view returns(address)
func (_Staking *StakingSession) Ggp() (common.Address, error) {
	return _Staking.Contract.Ggp(&_Staking.CallOpts)
}

// Ggp is a free data retrieval call binding the contract method 0xf321df49.
//
// Solidity: function ggp() view returns(address)
func (_Staking *StakingCallerSession) Ggp() (common.Address, error) {
	return _Staking.Contract.Ggp(&_Staking.CallOpts)
}

// RequireValidStaker is a free data retrieval call binding the contract method 0x9517d256.
//
// Solidity: function requireValidStaker(address stakerAddr) view returns(int256)
func (_Staking *StakingCaller) RequireValidStaker(opts *bind.CallOpts, stakerAddr common.Address) (*big.Int, error) {
	var out []interface{}
	err := _Staking.contract.Call(opts, &out, "requireValidStaker", stakerAddr)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// RequireValidStaker is a free data retrieval call binding the contract method 0x9517d256.
//
// Solidity: function requireValidStaker(address stakerAddr) view returns(int256)
func (_Staking *StakingSession) RequireValidStaker(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.RequireValidStaker(&_Staking.CallOpts, stakerAddr)
}

// RequireValidStaker is a free data retrieval call binding the contract method 0x9517d256.
//
// Solidity: function requireValidStaker(address stakerAddr) view returns(int256)
func (_Staking *StakingCallerSession) RequireValidStaker(stakerAddr common.Address) (*big.Int, error) {
	return _Staking.Contract.RequireValidStaker(&_Staking.CallOpts, stakerAddr)
}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint8)
func (_Staking *StakingCaller) Version(opts *bind.CallOpts) (uint8, error) {
	var out []interface{}
	err := _Staking.contract.Call(opts, &out, "version")

	if err != nil {
		return *new(uint8), err
	}

	out0 := *abi.ConvertType(out[0], new(uint8)).(*uint8)

	return out0, err

}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint8)
func (_Staking *StakingSession) Version() (uint8, error) {
	return _Staking.Contract.Version(&_Staking.CallOpts)
}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint8)
func (_Staking *StakingCallerSession) Version() (uint8, error) {
	return _Staking.Contract.Version(&_Staking.CallOpts)
}

// DecreaseAVAXAssigned is a paid mutator transaction binding the contract method 0xb8c4f612.
//
// Solidity: function decreaseAVAXAssigned(address stakerAddr, uint256 amount) returns()
func (_Staking *StakingTransactor) DecreaseAVAXAssigned(opts *bind.TransactOpts, stakerAddr common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.contract.Transact(opts, "decreaseAVAXAssigned", stakerAddr, amount)
}

// DecreaseAVAXAssigned is a paid mutator transaction binding the contract method 0xb8c4f612.
//
// Solidity: function decreaseAVAXAssigned(address stakerAddr, uint256 amount) returns()
func (_Staking *StakingSession) DecreaseAVAXAssigned(stakerAddr common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.DecreaseAVAXAssigned(&_Staking.TransactOpts, stakerAddr, amount)
}

// DecreaseAVAXAssigned is a paid mutator transaction binding the contract method 0xb8c4f612.
//
// Solidity: function decreaseAVAXAssigned(address stakerAddr, uint256 amount) returns()
func (_Staking *StakingTransactorSession) DecreaseAVAXAssigned(stakerAddr common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.DecreaseAVAXAssigned(&_Staking.TransactOpts, stakerAddr, amount)
}

// DecreaseAVAXStake is a paid mutator transaction binding the contract method 0xa1bb68a5.
//
// Solidity: function decreaseAVAXStake(address stakerAddr, uint256 amount) returns()
func (_Staking *StakingTransactor) DecreaseAVAXStake(opts *bind.TransactOpts, stakerAddr common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.contract.Transact(opts, "decreaseAVAXStake", stakerAddr, amount)
}

// DecreaseAVAXStake is a paid mutator transaction binding the contract method 0xa1bb68a5.
//
// Solidity: function decreaseAVAXStake(address stakerAddr, uint256 amount) returns()
func (_Staking *StakingSession) DecreaseAVAXStake(stakerAddr common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.DecreaseAVAXStake(&_Staking.TransactOpts, stakerAddr, amount)
}

// DecreaseAVAXStake is a paid mutator transaction binding the contract method 0xa1bb68a5.
//
// Solidity: function decreaseAVAXStake(address stakerAddr, uint256 amount) returns()
func (_Staking *StakingTransactorSession) DecreaseAVAXStake(stakerAddr common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.DecreaseAVAXStake(&_Staking.TransactOpts, stakerAddr, amount)
}

// DecreaseGGPRewards is a paid mutator transaction binding the contract method 0xb268ee14.
//
// Solidity: function decreaseGGPRewards(address stakerAddr, uint256 amount) returns()
func (_Staking *StakingTransactor) DecreaseGGPRewards(opts *bind.TransactOpts, stakerAddr common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.contract.Transact(opts, "decreaseGGPRewards", stakerAddr, amount)
}

// DecreaseGGPRewards is a paid mutator transaction binding the contract method 0xb268ee14.
//
// Solidity: function decreaseGGPRewards(address stakerAddr, uint256 amount) returns()
func (_Staking *StakingSession) DecreaseGGPRewards(stakerAddr common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.DecreaseGGPRewards(&_Staking.TransactOpts, stakerAddr, amount)
}

// DecreaseGGPRewards is a paid mutator transaction binding the contract method 0xb268ee14.
//
// Solidity: function decreaseGGPRewards(address stakerAddr, uint256 amount) returns()
func (_Staking *StakingTransactorSession) DecreaseGGPRewards(stakerAddr common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.DecreaseGGPRewards(&_Staking.TransactOpts, stakerAddr, amount)
}

// DecreaseMinipoolCount is a paid mutator transaction binding the contract method 0x23ca17bd.
//
// Solidity: function decreaseMinipoolCount(address stakerAddr) returns()
func (_Staking *StakingTransactor) DecreaseMinipoolCount(opts *bind.TransactOpts, stakerAddr common.Address) (*types.Transaction, error) {
	return _Staking.contract.Transact(opts, "decreaseMinipoolCount", stakerAddr)
}

// DecreaseMinipoolCount is a paid mutator transaction binding the contract method 0x23ca17bd.
//
// Solidity: function decreaseMinipoolCount(address stakerAddr) returns()
func (_Staking *StakingSession) DecreaseMinipoolCount(stakerAddr common.Address) (*types.Transaction, error) {
	return _Staking.Contract.DecreaseMinipoolCount(&_Staking.TransactOpts, stakerAddr)
}

// DecreaseMinipoolCount is a paid mutator transaction binding the contract method 0x23ca17bd.
//
// Solidity: function decreaseMinipoolCount(address stakerAddr) returns()
func (_Staking *StakingTransactorSession) DecreaseMinipoolCount(stakerAddr common.Address) (*types.Transaction, error) {
	return _Staking.Contract.DecreaseMinipoolCount(&_Staking.TransactOpts, stakerAddr)
}

// IncreaseAVAXAssigned is a paid mutator transaction binding the contract method 0x2f64fd52.
//
// Solidity: function increaseAVAXAssigned(address stakerAddr, uint256 amount) returns()
func (_Staking *StakingTransactor) IncreaseAVAXAssigned(opts *bind.TransactOpts, stakerAddr common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.contract.Transact(opts, "increaseAVAXAssigned", stakerAddr, amount)
}

// IncreaseAVAXAssigned is a paid mutator transaction binding the contract method 0x2f64fd52.
//
// Solidity: function increaseAVAXAssigned(address stakerAddr, uint256 amount) returns()
func (_Staking *StakingSession) IncreaseAVAXAssigned(stakerAddr common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.IncreaseAVAXAssigned(&_Staking.TransactOpts, stakerAddr, amount)
}

// IncreaseAVAXAssigned is a paid mutator transaction binding the contract method 0x2f64fd52.
//
// Solidity: function increaseAVAXAssigned(address stakerAddr, uint256 amount) returns()
func (_Staking *StakingTransactorSession) IncreaseAVAXAssigned(stakerAddr common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.IncreaseAVAXAssigned(&_Staking.TransactOpts, stakerAddr, amount)
}

// IncreaseAVAXStake is a paid mutator transaction binding the contract method 0x4f3d2e6f.
//
// Solidity: function increaseAVAXStake(address stakerAddr, uint256 amount) returns()
func (_Staking *StakingTransactor) IncreaseAVAXStake(opts *bind.TransactOpts, stakerAddr common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.contract.Transact(opts, "increaseAVAXStake", stakerAddr, amount)
}

// IncreaseAVAXStake is a paid mutator transaction binding the contract method 0x4f3d2e6f.
//
// Solidity: function increaseAVAXStake(address stakerAddr, uint256 amount) returns()
func (_Staking *StakingSession) IncreaseAVAXStake(stakerAddr common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.IncreaseAVAXStake(&_Staking.TransactOpts, stakerAddr, amount)
}

// IncreaseAVAXStake is a paid mutator transaction binding the contract method 0x4f3d2e6f.
//
// Solidity: function increaseAVAXStake(address stakerAddr, uint256 amount) returns()
func (_Staking *StakingTransactorSession) IncreaseAVAXStake(stakerAddr common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.IncreaseAVAXStake(&_Staking.TransactOpts, stakerAddr, amount)
}

// IncreaseGGPRewards is a paid mutator transaction binding the contract method 0xfc87bc36.
//
// Solidity: function increaseGGPRewards(address stakerAddr, uint256 amount) returns()
func (_Staking *StakingTransactor) IncreaseGGPRewards(opts *bind.TransactOpts, stakerAddr common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.contract.Transact(opts, "increaseGGPRewards", stakerAddr, amount)
}

// IncreaseGGPRewards is a paid mutator transaction binding the contract method 0xfc87bc36.
//
// Solidity: function increaseGGPRewards(address stakerAddr, uint256 amount) returns()
func (_Staking *StakingSession) IncreaseGGPRewards(stakerAddr common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.IncreaseGGPRewards(&_Staking.TransactOpts, stakerAddr, amount)
}

// IncreaseGGPRewards is a paid mutator transaction binding the contract method 0xfc87bc36.
//
// Solidity: function increaseGGPRewards(address stakerAddr, uint256 amount) returns()
func (_Staking *StakingTransactorSession) IncreaseGGPRewards(stakerAddr common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.IncreaseGGPRewards(&_Staking.TransactOpts, stakerAddr, amount)
}

// IncreaseMinipoolCount is a paid mutator transaction binding the contract method 0x465887b3.
//
// Solidity: function increaseMinipoolCount(address stakerAddr) returns()
func (_Staking *StakingTransactor) IncreaseMinipoolCount(opts *bind.TransactOpts, stakerAddr common.Address) (*types.Transaction, error) {
	return _Staking.contract.Transact(opts, "increaseMinipoolCount", stakerAddr)
}

// IncreaseMinipoolCount is a paid mutator transaction binding the contract method 0x465887b3.
//
// Solidity: function increaseMinipoolCount(address stakerAddr) returns()
func (_Staking *StakingSession) IncreaseMinipoolCount(stakerAddr common.Address) (*types.Transaction, error) {
	return _Staking.Contract.IncreaseMinipoolCount(&_Staking.TransactOpts, stakerAddr)
}

// IncreaseMinipoolCount is a paid mutator transaction binding the contract method 0x465887b3.
//
// Solidity: function increaseMinipoolCount(address stakerAddr) returns()
func (_Staking *StakingTransactorSession) IncreaseMinipoolCount(stakerAddr common.Address) (*types.Transaction, error) {
	return _Staking.Contract.IncreaseMinipoolCount(&_Staking.TransactOpts, stakerAddr)
}

// ResetAVAXAssignedHighWater is a paid mutator transaction binding the contract method 0xdcd1f23e.
//
// Solidity: function resetAVAXAssignedHighWater(address stakerAddr) returns()
func (_Staking *StakingTransactor) ResetAVAXAssignedHighWater(opts *bind.TransactOpts, stakerAddr common.Address) (*types.Transaction, error) {
	return _Staking.contract.Transact(opts, "resetAVAXAssignedHighWater", stakerAddr)
}

// ResetAVAXAssignedHighWater is a paid mutator transaction binding the contract method 0xdcd1f23e.
//
// Solidity: function resetAVAXAssignedHighWater(address stakerAddr) returns()
func (_Staking *StakingSession) ResetAVAXAssignedHighWater(stakerAddr common.Address) (*types.Transaction, error) {
	return _Staking.Contract.ResetAVAXAssignedHighWater(&_Staking.TransactOpts, stakerAddr)
}

// ResetAVAXAssignedHighWater is a paid mutator transaction binding the contract method 0xdcd1f23e.
//
// Solidity: function resetAVAXAssignedHighWater(address stakerAddr) returns()
func (_Staking *StakingTransactorSession) ResetAVAXAssignedHighWater(stakerAddr common.Address) (*types.Transaction, error) {
	return _Staking.Contract.ResetAVAXAssignedHighWater(&_Staking.TransactOpts, stakerAddr)
}

// RestakeGGP is a paid mutator transaction binding the contract method 0x4ce08478.
//
// Solidity: function restakeGGP(address stakerAddress, uint256 amount) returns()
func (_Staking *StakingTransactor) RestakeGGP(opts *bind.TransactOpts, stakerAddress common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.contract.Transact(opts, "restakeGGP", stakerAddress, amount)
}

// RestakeGGP is a paid mutator transaction binding the contract method 0x4ce08478.
//
// Solidity: function restakeGGP(address stakerAddress, uint256 amount) returns()
func (_Staking *StakingSession) RestakeGGP(stakerAddress common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.RestakeGGP(&_Staking.TransactOpts, stakerAddress, amount)
}

// RestakeGGP is a paid mutator transaction binding the contract method 0x4ce08478.
//
// Solidity: function restakeGGP(address stakerAddress, uint256 amount) returns()
func (_Staking *StakingTransactorSession) RestakeGGP(stakerAddress common.Address, amount *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.RestakeGGP(&_Staking.TransactOpts, stakerAddress, amount)
}

// SetRewardsStartTime is a paid mutator transaction binding the contract method 0x877d9e9e.
//
// Solidity: function setRewardsStartTime(address stakerAddr, uint256 time) returns()
func (_Staking *StakingTransactor) SetRewardsStartTime(opts *bind.TransactOpts, stakerAddr common.Address, time *big.Int) (*types.Transaction, error) {
	return _Staking.contract.Transact(opts, "setRewardsStartTime", stakerAddr, time)
}

// SetRewardsStartTime is a paid mutator transaction binding the contract method 0x877d9e9e.
//
// Solidity: function setRewardsStartTime(address stakerAddr, uint256 time) returns()
func (_Staking *StakingSession) SetRewardsStartTime(stakerAddr common.Address, time *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.SetRewardsStartTime(&_Staking.TransactOpts, stakerAddr, time)
}

// SetRewardsStartTime is a paid mutator transaction binding the contract method 0x877d9e9e.
//
// Solidity: function setRewardsStartTime(address stakerAddr, uint256 time) returns()
func (_Staking *StakingTransactorSession) SetRewardsStartTime(stakerAddr common.Address, time *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.SetRewardsStartTime(&_Staking.TransactOpts, stakerAddr, time)
}

// SlashGGP is a paid mutator transaction binding the contract method 0x065fe0a3.
//
// Solidity: function slashGGP(address stakerAddr, uint256 ggpAmt) returns()
func (_Staking *StakingTransactor) SlashGGP(opts *bind.TransactOpts, stakerAddr common.Address, ggpAmt *big.Int) (*types.Transaction, error) {
	return _Staking.contract.Transact(opts, "slashGGP", stakerAddr, ggpAmt)
}

// SlashGGP is a paid mutator transaction binding the contract method 0x065fe0a3.
//
// Solidity: function slashGGP(address stakerAddr, uint256 ggpAmt) returns()
func (_Staking *StakingSession) SlashGGP(stakerAddr common.Address, ggpAmt *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.SlashGGP(&_Staking.TransactOpts, stakerAddr, ggpAmt)
}

// SlashGGP is a paid mutator transaction binding the contract method 0x065fe0a3.
//
// Solidity: function slashGGP(address stakerAddr, uint256 ggpAmt) returns()
func (_Staking *StakingTransactorSession) SlashGGP(stakerAddr common.Address, ggpAmt *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.SlashGGP(&_Staking.TransactOpts, stakerAddr, ggpAmt)
}

// StakeGGP is a paid mutator transaction binding the contract method 0x68a239e9.
//
// Solidity: function stakeGGP(uint256 amount) returns()
func (_Staking *StakingTransactor) StakeGGP(opts *bind.TransactOpts, amount *big.Int) (*types.Transaction, error) {
	return _Staking.contract.Transact(opts, "stakeGGP", amount)
}

// StakeGGP is a paid mutator transaction binding the contract method 0x68a239e9.
//
// Solidity: function stakeGGP(uint256 amount) returns()
func (_Staking *StakingSession) StakeGGP(amount *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.StakeGGP(&_Staking.TransactOpts, amount)
}

// StakeGGP is a paid mutator transaction binding the contract method 0x68a239e9.
//
// Solidity: function stakeGGP(uint256 amount) returns()
func (_Staking *StakingTransactorSession) StakeGGP(amount *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.StakeGGP(&_Staking.TransactOpts, amount)
}

// WithdrawGGP is a paid mutator transaction binding the contract method 0xc03f09b0.
//
// Solidity: function withdrawGGP(uint256 amount) returns()
func (_Staking *StakingTransactor) WithdrawGGP(opts *bind.TransactOpts, amount *big.Int) (*types.Transaction, error) {
	return _Staking.contract.Transact(opts, "withdrawGGP", amount)
}

// WithdrawGGP is a paid mutator transaction binding the contract method 0xc03f09b0.
//
// Solidity: function withdrawGGP(uint256 amount) returns()
func (_Staking *StakingSession) WithdrawGGP(amount *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.WithdrawGGP(&_Staking.TransactOpts, amount)
}

// WithdrawGGP is a paid mutator transaction binding the contract method 0xc03f09b0.
//
// Solidity: function withdrawGGP(uint256 amount) returns()
func (_Staking *StakingTransactorSession) WithdrawGGP(amount *big.Int) (*types.Transaction, error) {
	return _Staking.Contract.WithdrawGGP(&_Staking.TransactOpts, amount)
}

// StakingGGPStakedIterator is returned from FilterGGPStaked and is used to iterate over the raw logs and unpacked data for GGPStaked events raised by the Staking contract.
type StakingGGPStakedIterator struct {
	Event *StakingGGPStaked // Event containing the contract specifics and raw log

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
func (it *StakingGGPStakedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakingGGPStaked)
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
		it.Event = new(StakingGGPStaked)
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
func (it *StakingGGPStakedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakingGGPStakedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakingGGPStaked represents a GGPStaked event raised by the Staking contract.
type StakingGGPStaked struct {
	From   common.Address
	Amount *big.Int
	Raw    types.Log // Blockchain specific contextual infos
}

// FilterGGPStaked is a free log retrieval operation binding the contract event 0x3cd32fbc628a7c1c5a309e823125e5a4b8d98b9b31ad71d8338cc5f05829b199.
//
// Solidity: event GGPStaked(address indexed from, uint256 amount)
func (_Staking *StakingFilterer) FilterGGPStaked(opts *bind.FilterOpts, from []common.Address) (*StakingGGPStakedIterator, error) {

	var fromRule []interface{}
	for _, fromItem := range from {
		fromRule = append(fromRule, fromItem)
	}

	logs, sub, err := _Staking.contract.FilterLogs(opts, "GGPStaked", fromRule)
	if err != nil {
		return nil, err
	}
	return &StakingGGPStakedIterator{contract: _Staking.contract, event: "GGPStaked", logs: logs, sub: sub}, nil
}

// WatchGGPStaked is a free log subscription operation binding the contract event 0x3cd32fbc628a7c1c5a309e823125e5a4b8d98b9b31ad71d8338cc5f05829b199.
//
// Solidity: event GGPStaked(address indexed from, uint256 amount)
func (_Staking *StakingFilterer) WatchGGPStaked(opts *bind.WatchOpts, sink chan<- *StakingGGPStaked, from []common.Address) (event.Subscription, error) {

	var fromRule []interface{}
	for _, fromItem := range from {
		fromRule = append(fromRule, fromItem)
	}

	logs, sub, err := _Staking.contract.WatchLogs(opts, "GGPStaked", fromRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakingGGPStaked)
				if err := _Staking.contract.UnpackLog(event, "GGPStaked", log); err != nil {
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

// ParseGGPStaked is a log parse operation binding the contract event 0x3cd32fbc628a7c1c5a309e823125e5a4b8d98b9b31ad71d8338cc5f05829b199.
//
// Solidity: event GGPStaked(address indexed from, uint256 amount)
func (_Staking *StakingFilterer) ParseGGPStaked(log types.Log) (*StakingGGPStaked, error) {
	event := new(StakingGGPStaked)
	if err := _Staking.contract.UnpackLog(event, "GGPStaked", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// StakingGGPWithdrawnIterator is returned from FilterGGPWithdrawn and is used to iterate over the raw logs and unpacked data for GGPWithdrawn events raised by the Staking contract.
type StakingGGPWithdrawnIterator struct {
	Event *StakingGGPWithdrawn // Event containing the contract specifics and raw log

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
func (it *StakingGGPWithdrawnIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StakingGGPWithdrawn)
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
		it.Event = new(StakingGGPWithdrawn)
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
func (it *StakingGGPWithdrawnIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StakingGGPWithdrawnIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StakingGGPWithdrawn represents a GGPWithdrawn event raised by the Staking contract.
type StakingGGPWithdrawn struct {
	To     common.Address
	Amount *big.Int
	Raw    types.Log // Blockchain specific contextual infos
}

// FilterGGPWithdrawn is a free log retrieval operation binding the contract event 0x24231562008debd875e9a0c93d43fda03c49a4578215067a1d7024b97dd15d24.
//
// Solidity: event GGPWithdrawn(address indexed to, uint256 amount)
func (_Staking *StakingFilterer) FilterGGPWithdrawn(opts *bind.FilterOpts, to []common.Address) (*StakingGGPWithdrawnIterator, error) {

	var toRule []interface{}
	for _, toItem := range to {
		toRule = append(toRule, toItem)
	}

	logs, sub, err := _Staking.contract.FilterLogs(opts, "GGPWithdrawn", toRule)
	if err != nil {
		return nil, err
	}
	return &StakingGGPWithdrawnIterator{contract: _Staking.contract, event: "GGPWithdrawn", logs: logs, sub: sub}, nil
}

// WatchGGPWithdrawn is a free log subscription operation binding the contract event 0x24231562008debd875e9a0c93d43fda03c49a4578215067a1d7024b97dd15d24.
//
// Solidity: event GGPWithdrawn(address indexed to, uint256 amount)
func (_Staking *StakingFilterer) WatchGGPWithdrawn(opts *bind.WatchOpts, sink chan<- *StakingGGPWithdrawn, to []common.Address) (event.Subscription, error) {

	var toRule []interface{}
	for _, toItem := range to {
		toRule = append(toRule, toItem)
	}

	logs, sub, err := _Staking.contract.WatchLogs(opts, "GGPWithdrawn", toRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StakingGGPWithdrawn)
				if err := _Staking.contract.UnpackLog(event, "GGPWithdrawn", log); err != nil {
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

// ParseGGPWithdrawn is a log parse operation binding the contract event 0x24231562008debd875e9a0c93d43fda03c49a4578215067a1d7024b97dd15d24.
//
// Solidity: event GGPWithdrawn(address indexed to, uint256 amount)
func (_Staking *StakingFilterer) ParseGGPWithdrawn(log types.Log) (*StakingGGPWithdrawn, error) {
	event := new(StakingGGPWithdrawn)
	if err := _Staking.contract.UnpackLog(event, "GGPWithdrawn", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
