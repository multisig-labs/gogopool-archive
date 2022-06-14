// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package minipool_manager

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

// MinipoolManagerMinipool is an auto generated low-level Go binding around an user-defined struct.
type MinipoolManagerMinipool struct {
	NodeID              common.Address
	Status              *big.Int
	Duration            *big.Int
	StartTime           *big.Int
	EndTime             *big.Int
	DelegationFee       *big.Int
	GgpBondAmt          *big.Int
	GgpSlashAmt         *big.Int
	AvaxNodeOpAmt       *big.Int
	AvaxUserAmt         *big.Int
	AvaxTotalRewardAmt  *big.Int
	AvaxNodeOpRewardAmt *big.Int
	AvaxUserRewardAmt   *big.Int
	Owner               common.Address
	MultisigAddr        common.Address
}

// MinipoolManagerMetaData contains all meta data concerning the MinipoolManager contract.
var MinipoolManagerMetaData = &bind.MetaData{
	ABI: "[{\"inputs\":[{\"internalType\":\"contractStorage\",\"name\":\"storageAddress\",\"type\":\"address\"},{\"internalType\":\"contractERC20\",\"name\":\"ggp_\",\"type\":\"address\"},{\"internalType\":\"contractTokenggAVAX\",\"name\":\"ggAVAX_\",\"type\":\"address\"}],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"inputs\":[],\"name\":\"ErrorIssuingValidationTx\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"ErrorSendingAvax\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"InsufficientAvaxForStaking\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"InsufficientAvaxVaultBalance\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"InvalidAmount\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"InvalidEndTime\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"InvalidMultisigAddress\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"InvalidMultisigSignature\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"InvalidStateTransition\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"MinipoolAlreadyRegistered\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"MinipoolMustBeInitialised\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"MinipoolNotFound\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"OnlyOwnerCanCancel\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"OnlyOwnerCanWithdraw\",\"type\":\"error\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"nodeID\",\"type\":\"address\"},{\"indexed\":true,\"internalType\":\"enumMinipoolStatus\",\"name\":\"status\",\"type\":\"uint8\"}],\"name\":\"MinipoolStatusChanged\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"address\",\"name\":\"nodeID\",\"type\":\"address\"}],\"name\":\"ZeroRewardsReceived\",\"type\":\"event\"},{\"inputs\":[],\"name\":\"MINIPOOL_QUEUE_KEY\",\"outputs\":[{\"internalType\":\"bytes32\",\"name\":\"\",\"type\":\"bytes32\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"MIN_STAKING_AMT\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"avaxRewardAmt\",\"type\":\"uint256\"}],\"name\":\"calculateSlashAmt\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"nodeID\",\"type\":\"address\"}],\"name\":\"canClaimAndInitiateStaking\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"nodeID\",\"type\":\"address\"}],\"name\":\"cancelMinipool\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"nodeID\",\"type\":\"address\"}],\"name\":\"claimAndInitiateStaking\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"nodeID\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"duration\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"delegationFee\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"ggpBondAmt\",\"type\":\"uint256\"}],\"name\":\"createMinipool\",\"outputs\":[],\"stateMutability\":\"payable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"duration\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"avaxAmt\",\"type\":\"uint256\"}],\"name\":\"expectedRewardAmt\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"nodeID\",\"type\":\"address\"}],\"name\":\"getIndexOf\",\"outputs\":[{\"internalType\":\"int256\",\"name\":\"\",\"type\":\"int256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"int256\",\"name\":\"index\",\"type\":\"int256\"}],\"name\":\"getMinipool\",\"outputs\":[{\"components\":[{\"internalType\":\"address\",\"name\":\"nodeID\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"status\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"duration\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"startTime\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"endTime\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"delegationFee\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"ggpBondAmt\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"ggpSlashAmt\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"avaxNodeOpAmt\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"avaxUserAmt\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"avaxTotalRewardAmt\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"avaxNodeOpRewardAmt\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"avaxUserRewardAmt\",\"type\":\"uint256\"},{\"internalType\":\"address\",\"name\":\"owner\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"multisigAddr\",\"type\":\"address\"}],\"internalType\":\"structMinipoolManager.Minipool\",\"name\":\"mp\",\"type\":\"tuple\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getMinipoolCount\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"offset\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"limit\",\"type\":\"uint256\"}],\"name\":\"getMinipoolCountPerStatus\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"prelaunchCount\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"launchedCount\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"stakingCount\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"withdrawableCount\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"finishedCount\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"canceledCount\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"enumMinipoolStatus\",\"name\":\"status\",\"type\":\"uint8\"},{\"internalType\":\"uint256\",\"name\":\"offset\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"limit\",\"type\":\"uint256\"}],\"name\":\"getMinipools\",\"outputs\":[{\"components\":[{\"internalType\":\"address\",\"name\":\"nodeID\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"status\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"duration\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"startTime\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"endTime\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"delegationFee\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"ggpBondAmt\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"ggpSlashAmt\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"avaxNodeOpAmt\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"avaxUserAmt\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"avaxTotalRewardAmt\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"avaxNodeOpRewardAmt\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"avaxUserRewardAmt\",\"type\":\"uint256\"},{\"internalType\":\"address\",\"name\":\"owner\",\"type\":\"address\"},{\"internalType\":\"address\",\"name\":\"multisigAddr\",\"type\":\"address\"}],\"internalType\":\"structMinipoolManager.Minipool[]\",\"name\":\"minipools\",\"type\":\"tuple[]\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"string\",\"name\":\"_contractName\",\"type\":\"string\"}],\"name\":\"getPublicContractAddress\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"settingNameSpace\",\"type\":\"bytes32\"},{\"internalType\":\"string\",\"name\":\"_settingPath\",\"type\":\"string\"}],\"name\":\"getSettingAddress\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"settingNameSpace\",\"type\":\"bytes32\"},{\"internalType\":\"string\",\"name\":\"_settingPath\",\"type\":\"string\"}],\"name\":\"getSettingBool\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"settingNameSpace\",\"type\":\"bytes32\"},{\"internalType\":\"string\",\"name\":\"_settingPath\",\"type\":\"string\"}],\"name\":\"getSettingUint\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"ggAVAX\",\"outputs\":[{\"internalType\":\"contractTokenggAVAX\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"ggp\",\"outputs\":[{\"internalType\":\"contractERC20\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"receiveWithdrawalAVAX\",\"outputs\":[],\"stateMutability\":\"payable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"nodeID\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"endTime\",\"type\":\"uint256\"},{\"internalType\":\"uint256\",\"name\":\"avaxTotalRewardAmt\",\"type\":\"uint256\"}],\"name\":\"recordStakingEnd\",\"outputs\":[],\"stateMutability\":\"payable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"nodeID\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"endTime\",\"type\":\"uint256\"},{\"internalType\":\"string\",\"name\":\"message\",\"type\":\"string\"}],\"name\":\"recordStakingError\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"nodeID\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"startTime\",\"type\":\"uint256\"}],\"name\":\"recordStakingStart\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"nodeID\",\"type\":\"address\"},{\"internalType\":\"enumMinipoolStatus\",\"name\":\"status\",\"type\":\"uint8\"}],\"name\":\"updateMinipoolStatus\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"version\",\"outputs\":[{\"internalType\":\"uint8\",\"name\":\"\",\"type\":\"uint8\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"nodeID\",\"type\":\"address\"}],\"name\":\"withdrawMinipoolFunds\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]",
}

// MinipoolManagerABI is the input ABI used to generate the binding from.
// Deprecated: Use MinipoolManagerMetaData.ABI instead.
var MinipoolManagerABI = MinipoolManagerMetaData.ABI

// MinipoolManager is an auto generated Go binding around an Ethereum contract.
type MinipoolManager struct {
	MinipoolManagerCaller     // Read-only binding to the contract
	MinipoolManagerTransactor // Write-only binding to the contract
	MinipoolManagerFilterer   // Log filterer for contract events
}

// MinipoolManagerCaller is an auto generated read-only Go binding around an Ethereum contract.
type MinipoolManagerCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// MinipoolManagerTransactor is an auto generated write-only Go binding around an Ethereum contract.
type MinipoolManagerTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// MinipoolManagerFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type MinipoolManagerFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// MinipoolManagerSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type MinipoolManagerSession struct {
	Contract     *MinipoolManager  // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// MinipoolManagerCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type MinipoolManagerCallerSession struct {
	Contract *MinipoolManagerCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts          // Call options to use throughout this session
}

// MinipoolManagerTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type MinipoolManagerTransactorSession struct {
	Contract     *MinipoolManagerTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts          // Transaction auth options to use throughout this session
}

// MinipoolManagerRaw is an auto generated low-level Go binding around an Ethereum contract.
type MinipoolManagerRaw struct {
	Contract *MinipoolManager // Generic contract binding to access the raw methods on
}

// MinipoolManagerCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type MinipoolManagerCallerRaw struct {
	Contract *MinipoolManagerCaller // Generic read-only contract binding to access the raw methods on
}

// MinipoolManagerTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type MinipoolManagerTransactorRaw struct {
	Contract *MinipoolManagerTransactor // Generic write-only contract binding to access the raw methods on
}

// NewMinipoolManager creates a new instance of MinipoolManager, bound to a specific deployed contract.
func NewMinipoolManager(address common.Address, backend bind.ContractBackend) (*MinipoolManager, error) {
	contract, err := bindMinipoolManager(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &MinipoolManager{MinipoolManagerCaller: MinipoolManagerCaller{contract: contract}, MinipoolManagerTransactor: MinipoolManagerTransactor{contract: contract}, MinipoolManagerFilterer: MinipoolManagerFilterer{contract: contract}}, nil
}

// NewMinipoolManagerCaller creates a new read-only instance of MinipoolManager, bound to a specific deployed contract.
func NewMinipoolManagerCaller(address common.Address, caller bind.ContractCaller) (*MinipoolManagerCaller, error) {
	contract, err := bindMinipoolManager(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &MinipoolManagerCaller{contract: contract}, nil
}

// NewMinipoolManagerTransactor creates a new write-only instance of MinipoolManager, bound to a specific deployed contract.
func NewMinipoolManagerTransactor(address common.Address, transactor bind.ContractTransactor) (*MinipoolManagerTransactor, error) {
	contract, err := bindMinipoolManager(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &MinipoolManagerTransactor{contract: contract}, nil
}

// NewMinipoolManagerFilterer creates a new log filterer instance of MinipoolManager, bound to a specific deployed contract.
func NewMinipoolManagerFilterer(address common.Address, filterer bind.ContractFilterer) (*MinipoolManagerFilterer, error) {
	contract, err := bindMinipoolManager(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &MinipoolManagerFilterer{contract: contract}, nil
}

// bindMinipoolManager binds a generic wrapper to an already deployed contract.
func bindMinipoolManager(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := abi.JSON(strings.NewReader(MinipoolManagerABI))
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_MinipoolManager *MinipoolManagerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _MinipoolManager.Contract.MinipoolManagerCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_MinipoolManager *MinipoolManagerRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _MinipoolManager.Contract.MinipoolManagerTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_MinipoolManager *MinipoolManagerRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _MinipoolManager.Contract.MinipoolManagerTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_MinipoolManager *MinipoolManagerCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _MinipoolManager.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_MinipoolManager *MinipoolManagerTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _MinipoolManager.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_MinipoolManager *MinipoolManagerTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _MinipoolManager.Contract.contract.Transact(opts, method, params...)
}

// MINIPOOLQUEUEKEY is a free data retrieval call binding the contract method 0x28b105fd.
//
// Solidity: function MINIPOOL_QUEUE_KEY() view returns(bytes32)
func (_MinipoolManager *MinipoolManagerCaller) MINIPOOLQUEUEKEY(opts *bind.CallOpts) ([32]byte, error) {
	var out []interface{}
	err := _MinipoolManager.contract.Call(opts, &out, "MINIPOOL_QUEUE_KEY")

	if err != nil {
		return *new([32]byte), err
	}

	out0 := *abi.ConvertType(out[0], new([32]byte)).(*[32]byte)

	return out0, err

}

// MINIPOOLQUEUEKEY is a free data retrieval call binding the contract method 0x28b105fd.
//
// Solidity: function MINIPOOL_QUEUE_KEY() view returns(bytes32)
func (_MinipoolManager *MinipoolManagerSession) MINIPOOLQUEUEKEY() ([32]byte, error) {
	return _MinipoolManager.Contract.MINIPOOLQUEUEKEY(&_MinipoolManager.CallOpts)
}

// MINIPOOLQUEUEKEY is a free data retrieval call binding the contract method 0x28b105fd.
//
// Solidity: function MINIPOOL_QUEUE_KEY() view returns(bytes32)
func (_MinipoolManager *MinipoolManagerCallerSession) MINIPOOLQUEUEKEY() ([32]byte, error) {
	return _MinipoolManager.Contract.MINIPOOLQUEUEKEY(&_MinipoolManager.CallOpts)
}

// MINSTAKINGAMT is a free data retrieval call binding the contract method 0xe49e49bf.
//
// Solidity: function MIN_STAKING_AMT() view returns(uint256)
func (_MinipoolManager *MinipoolManagerCaller) MINSTAKINGAMT(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _MinipoolManager.contract.Call(opts, &out, "MIN_STAKING_AMT")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// MINSTAKINGAMT is a free data retrieval call binding the contract method 0xe49e49bf.
//
// Solidity: function MIN_STAKING_AMT() view returns(uint256)
func (_MinipoolManager *MinipoolManagerSession) MINSTAKINGAMT() (*big.Int, error) {
	return _MinipoolManager.Contract.MINSTAKINGAMT(&_MinipoolManager.CallOpts)
}

// MINSTAKINGAMT is a free data retrieval call binding the contract method 0xe49e49bf.
//
// Solidity: function MIN_STAKING_AMT() view returns(uint256)
func (_MinipoolManager *MinipoolManagerCallerSession) MINSTAKINGAMT() (*big.Int, error) {
	return _MinipoolManager.Contract.MINSTAKINGAMT(&_MinipoolManager.CallOpts)
}

// CalculateSlashAmt is a free data retrieval call binding the contract method 0xf4812b88.
//
// Solidity: function calculateSlashAmt(uint256 avaxRewardAmt) view returns(uint256)
func (_MinipoolManager *MinipoolManagerCaller) CalculateSlashAmt(opts *bind.CallOpts, avaxRewardAmt *big.Int) (*big.Int, error) {
	var out []interface{}
	err := _MinipoolManager.contract.Call(opts, &out, "calculateSlashAmt", avaxRewardAmt)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// CalculateSlashAmt is a free data retrieval call binding the contract method 0xf4812b88.
//
// Solidity: function calculateSlashAmt(uint256 avaxRewardAmt) view returns(uint256)
func (_MinipoolManager *MinipoolManagerSession) CalculateSlashAmt(avaxRewardAmt *big.Int) (*big.Int, error) {
	return _MinipoolManager.Contract.CalculateSlashAmt(&_MinipoolManager.CallOpts, avaxRewardAmt)
}

// CalculateSlashAmt is a free data retrieval call binding the contract method 0xf4812b88.
//
// Solidity: function calculateSlashAmt(uint256 avaxRewardAmt) view returns(uint256)
func (_MinipoolManager *MinipoolManagerCallerSession) CalculateSlashAmt(avaxRewardAmt *big.Int) (*big.Int, error) {
	return _MinipoolManager.Contract.CalculateSlashAmt(&_MinipoolManager.CallOpts, avaxRewardAmt)
}

// CanClaimAndInitiateStaking is a free data retrieval call binding the contract method 0xea3092d1.
//
// Solidity: function canClaimAndInitiateStaking(address nodeID) view returns(bool)
func (_MinipoolManager *MinipoolManagerCaller) CanClaimAndInitiateStaking(opts *bind.CallOpts, nodeID common.Address) (bool, error) {
	var out []interface{}
	err := _MinipoolManager.contract.Call(opts, &out, "canClaimAndInitiateStaking", nodeID)

	if err != nil {
		return *new(bool), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)

	return out0, err

}

// CanClaimAndInitiateStaking is a free data retrieval call binding the contract method 0xea3092d1.
//
// Solidity: function canClaimAndInitiateStaking(address nodeID) view returns(bool)
func (_MinipoolManager *MinipoolManagerSession) CanClaimAndInitiateStaking(nodeID common.Address) (bool, error) {
	return _MinipoolManager.Contract.CanClaimAndInitiateStaking(&_MinipoolManager.CallOpts, nodeID)
}

// CanClaimAndInitiateStaking is a free data retrieval call binding the contract method 0xea3092d1.
//
// Solidity: function canClaimAndInitiateStaking(address nodeID) view returns(bool)
func (_MinipoolManager *MinipoolManagerCallerSession) CanClaimAndInitiateStaking(nodeID common.Address) (bool, error) {
	return _MinipoolManager.Contract.CanClaimAndInitiateStaking(&_MinipoolManager.CallOpts, nodeID)
}

// ExpectedRewardAmt is a free data retrieval call binding the contract method 0xde5a61e3.
//
// Solidity: function expectedRewardAmt(uint256 duration, uint256 avaxAmt) view returns(uint256)
func (_MinipoolManager *MinipoolManagerCaller) ExpectedRewardAmt(opts *bind.CallOpts, duration *big.Int, avaxAmt *big.Int) (*big.Int, error) {
	var out []interface{}
	err := _MinipoolManager.contract.Call(opts, &out, "expectedRewardAmt", duration, avaxAmt)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// ExpectedRewardAmt is a free data retrieval call binding the contract method 0xde5a61e3.
//
// Solidity: function expectedRewardAmt(uint256 duration, uint256 avaxAmt) view returns(uint256)
func (_MinipoolManager *MinipoolManagerSession) ExpectedRewardAmt(duration *big.Int, avaxAmt *big.Int) (*big.Int, error) {
	return _MinipoolManager.Contract.ExpectedRewardAmt(&_MinipoolManager.CallOpts, duration, avaxAmt)
}

// ExpectedRewardAmt is a free data retrieval call binding the contract method 0xde5a61e3.
//
// Solidity: function expectedRewardAmt(uint256 duration, uint256 avaxAmt) view returns(uint256)
func (_MinipoolManager *MinipoolManagerCallerSession) ExpectedRewardAmt(duration *big.Int, avaxAmt *big.Int) (*big.Int, error) {
	return _MinipoolManager.Contract.ExpectedRewardAmt(&_MinipoolManager.CallOpts, duration, avaxAmt)
}

// GetIndexOf is a free data retrieval call binding the contract method 0x017df522.
//
// Solidity: function getIndexOf(address nodeID) view returns(int256)
func (_MinipoolManager *MinipoolManagerCaller) GetIndexOf(opts *bind.CallOpts, nodeID common.Address) (*big.Int, error) {
	var out []interface{}
	err := _MinipoolManager.contract.Call(opts, &out, "getIndexOf", nodeID)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetIndexOf is a free data retrieval call binding the contract method 0x017df522.
//
// Solidity: function getIndexOf(address nodeID) view returns(int256)
func (_MinipoolManager *MinipoolManagerSession) GetIndexOf(nodeID common.Address) (*big.Int, error) {
	return _MinipoolManager.Contract.GetIndexOf(&_MinipoolManager.CallOpts, nodeID)
}

// GetIndexOf is a free data retrieval call binding the contract method 0x017df522.
//
// Solidity: function getIndexOf(address nodeID) view returns(int256)
func (_MinipoolManager *MinipoolManagerCallerSession) GetIndexOf(nodeID common.Address) (*big.Int, error) {
	return _MinipoolManager.Contract.GetIndexOf(&_MinipoolManager.CallOpts, nodeID)
}

// GetMinipool is a free data retrieval call binding the contract method 0xd8ce16f4.
//
// Solidity: function getMinipool(int256 index) view returns((address,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,address,address) mp)
func (_MinipoolManager *MinipoolManagerCaller) GetMinipool(opts *bind.CallOpts, index *big.Int) (MinipoolManagerMinipool, error) {
	var out []interface{}
	err := _MinipoolManager.contract.Call(opts, &out, "getMinipool", index)

	if err != nil {
		return *new(MinipoolManagerMinipool), err
	}

	out0 := *abi.ConvertType(out[0], new(MinipoolManagerMinipool)).(*MinipoolManagerMinipool)

	return out0, err

}

// GetMinipool is a free data retrieval call binding the contract method 0xd8ce16f4.
//
// Solidity: function getMinipool(int256 index) view returns((address,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,address,address) mp)
func (_MinipoolManager *MinipoolManagerSession) GetMinipool(index *big.Int) (MinipoolManagerMinipool, error) {
	return _MinipoolManager.Contract.GetMinipool(&_MinipoolManager.CallOpts, index)
}

// GetMinipool is a free data retrieval call binding the contract method 0xd8ce16f4.
//
// Solidity: function getMinipool(int256 index) view returns((address,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,address,address) mp)
func (_MinipoolManager *MinipoolManagerCallerSession) GetMinipool(index *big.Int) (MinipoolManagerMinipool, error) {
	return _MinipoolManager.Contract.GetMinipool(&_MinipoolManager.CallOpts, index)
}

// GetMinipoolCount is a free data retrieval call binding the contract method 0xae4d0bed.
//
// Solidity: function getMinipoolCount() view returns(uint256)
func (_MinipoolManager *MinipoolManagerCaller) GetMinipoolCount(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _MinipoolManager.contract.Call(opts, &out, "getMinipoolCount")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetMinipoolCount is a free data retrieval call binding the contract method 0xae4d0bed.
//
// Solidity: function getMinipoolCount() view returns(uint256)
func (_MinipoolManager *MinipoolManagerSession) GetMinipoolCount() (*big.Int, error) {
	return _MinipoolManager.Contract.GetMinipoolCount(&_MinipoolManager.CallOpts)
}

// GetMinipoolCount is a free data retrieval call binding the contract method 0xae4d0bed.
//
// Solidity: function getMinipoolCount() view returns(uint256)
func (_MinipoolManager *MinipoolManagerCallerSession) GetMinipoolCount() (*big.Int, error) {
	return _MinipoolManager.Contract.GetMinipoolCount(&_MinipoolManager.CallOpts)
}

// GetMinipoolCountPerStatus is a free data retrieval call binding the contract method 0x3b5ecefa.
//
// Solidity: function getMinipoolCountPerStatus(uint256 offset, uint256 limit) view returns(uint256 prelaunchCount, uint256 launchedCount, uint256 stakingCount, uint256 withdrawableCount, uint256 finishedCount, uint256 canceledCount)
func (_MinipoolManager *MinipoolManagerCaller) GetMinipoolCountPerStatus(opts *bind.CallOpts, offset *big.Int, limit *big.Int) (struct {
	PrelaunchCount    *big.Int
	LaunchedCount     *big.Int
	StakingCount      *big.Int
	WithdrawableCount *big.Int
	FinishedCount     *big.Int
	CanceledCount     *big.Int
}, error) {
	var out []interface{}
	err := _MinipoolManager.contract.Call(opts, &out, "getMinipoolCountPerStatus", offset, limit)

	outstruct := new(struct {
		PrelaunchCount    *big.Int
		LaunchedCount     *big.Int
		StakingCount      *big.Int
		WithdrawableCount *big.Int
		FinishedCount     *big.Int
		CanceledCount     *big.Int
	})
	if err != nil {
		return *outstruct, err
	}

	outstruct.PrelaunchCount = *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)
	outstruct.LaunchedCount = *abi.ConvertType(out[1], new(*big.Int)).(**big.Int)
	outstruct.StakingCount = *abi.ConvertType(out[2], new(*big.Int)).(**big.Int)
	outstruct.WithdrawableCount = *abi.ConvertType(out[3], new(*big.Int)).(**big.Int)
	outstruct.FinishedCount = *abi.ConvertType(out[4], new(*big.Int)).(**big.Int)
	outstruct.CanceledCount = *abi.ConvertType(out[5], new(*big.Int)).(**big.Int)

	return *outstruct, err

}

// GetMinipoolCountPerStatus is a free data retrieval call binding the contract method 0x3b5ecefa.
//
// Solidity: function getMinipoolCountPerStatus(uint256 offset, uint256 limit) view returns(uint256 prelaunchCount, uint256 launchedCount, uint256 stakingCount, uint256 withdrawableCount, uint256 finishedCount, uint256 canceledCount)
func (_MinipoolManager *MinipoolManagerSession) GetMinipoolCountPerStatus(offset *big.Int, limit *big.Int) (struct {
	PrelaunchCount    *big.Int
	LaunchedCount     *big.Int
	StakingCount      *big.Int
	WithdrawableCount *big.Int
	FinishedCount     *big.Int
	CanceledCount     *big.Int
}, error) {
	return _MinipoolManager.Contract.GetMinipoolCountPerStatus(&_MinipoolManager.CallOpts, offset, limit)
}

// GetMinipoolCountPerStatus is a free data retrieval call binding the contract method 0x3b5ecefa.
//
// Solidity: function getMinipoolCountPerStatus(uint256 offset, uint256 limit) view returns(uint256 prelaunchCount, uint256 launchedCount, uint256 stakingCount, uint256 withdrawableCount, uint256 finishedCount, uint256 canceledCount)
func (_MinipoolManager *MinipoolManagerCallerSession) GetMinipoolCountPerStatus(offset *big.Int, limit *big.Int) (struct {
	PrelaunchCount    *big.Int
	LaunchedCount     *big.Int
	StakingCount      *big.Int
	WithdrawableCount *big.Int
	FinishedCount     *big.Int
	CanceledCount     *big.Int
}, error) {
	return _MinipoolManager.Contract.GetMinipoolCountPerStatus(&_MinipoolManager.CallOpts, offset, limit)
}

// GetMinipools is a free data retrieval call binding the contract method 0x934857bb.
//
// Solidity: function getMinipools(uint8 status, uint256 offset, uint256 limit) view returns((address,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,address,address)[] minipools)
func (_MinipoolManager *MinipoolManagerCaller) GetMinipools(opts *bind.CallOpts, status uint8, offset *big.Int, limit *big.Int) ([]MinipoolManagerMinipool, error) {
	var out []interface{}
	err := _MinipoolManager.contract.Call(opts, &out, "getMinipools", status, offset, limit)

	if err != nil {
		return *new([]MinipoolManagerMinipool), err
	}

	out0 := *abi.ConvertType(out[0], new([]MinipoolManagerMinipool)).(*[]MinipoolManagerMinipool)

	return out0, err

}

// GetMinipools is a free data retrieval call binding the contract method 0x934857bb.
//
// Solidity: function getMinipools(uint8 status, uint256 offset, uint256 limit) view returns((address,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,address,address)[] minipools)
func (_MinipoolManager *MinipoolManagerSession) GetMinipools(status uint8, offset *big.Int, limit *big.Int) ([]MinipoolManagerMinipool, error) {
	return _MinipoolManager.Contract.GetMinipools(&_MinipoolManager.CallOpts, status, offset, limit)
}

// GetMinipools is a free data retrieval call binding the contract method 0x934857bb.
//
// Solidity: function getMinipools(uint8 status, uint256 offset, uint256 limit) view returns((address,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,address,address)[] minipools)
func (_MinipoolManager *MinipoolManagerCallerSession) GetMinipools(status uint8, offset *big.Int, limit *big.Int) ([]MinipoolManagerMinipool, error) {
	return _MinipoolManager.Contract.GetMinipools(&_MinipoolManager.CallOpts, status, offset, limit)
}

// GetPublicContractAddress is a free data retrieval call binding the contract method 0xcff0b648.
//
// Solidity: function getPublicContractAddress(string _contractName) view returns(address)
func (_MinipoolManager *MinipoolManagerCaller) GetPublicContractAddress(opts *bind.CallOpts, _contractName string) (common.Address, error) {
	var out []interface{}
	err := _MinipoolManager.contract.Call(opts, &out, "getPublicContractAddress", _contractName)

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// GetPublicContractAddress is a free data retrieval call binding the contract method 0xcff0b648.
//
// Solidity: function getPublicContractAddress(string _contractName) view returns(address)
func (_MinipoolManager *MinipoolManagerSession) GetPublicContractAddress(_contractName string) (common.Address, error) {
	return _MinipoolManager.Contract.GetPublicContractAddress(&_MinipoolManager.CallOpts, _contractName)
}

// GetPublicContractAddress is a free data retrieval call binding the contract method 0xcff0b648.
//
// Solidity: function getPublicContractAddress(string _contractName) view returns(address)
func (_MinipoolManager *MinipoolManagerCallerSession) GetPublicContractAddress(_contractName string) (common.Address, error) {
	return _MinipoolManager.Contract.GetPublicContractAddress(&_MinipoolManager.CallOpts, _contractName)
}

// GetSettingAddress is a free data retrieval call binding the contract method 0x06eaa68b.
//
// Solidity: function getSettingAddress(bytes32 settingNameSpace, string _settingPath) view returns(address)
func (_MinipoolManager *MinipoolManagerCaller) GetSettingAddress(opts *bind.CallOpts, settingNameSpace [32]byte, _settingPath string) (common.Address, error) {
	var out []interface{}
	err := _MinipoolManager.contract.Call(opts, &out, "getSettingAddress", settingNameSpace, _settingPath)

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// GetSettingAddress is a free data retrieval call binding the contract method 0x06eaa68b.
//
// Solidity: function getSettingAddress(bytes32 settingNameSpace, string _settingPath) view returns(address)
func (_MinipoolManager *MinipoolManagerSession) GetSettingAddress(settingNameSpace [32]byte, _settingPath string) (common.Address, error) {
	return _MinipoolManager.Contract.GetSettingAddress(&_MinipoolManager.CallOpts, settingNameSpace, _settingPath)
}

// GetSettingAddress is a free data retrieval call binding the contract method 0x06eaa68b.
//
// Solidity: function getSettingAddress(bytes32 settingNameSpace, string _settingPath) view returns(address)
func (_MinipoolManager *MinipoolManagerCallerSession) GetSettingAddress(settingNameSpace [32]byte, _settingPath string) (common.Address, error) {
	return _MinipoolManager.Contract.GetSettingAddress(&_MinipoolManager.CallOpts, settingNameSpace, _settingPath)
}

// GetSettingBool is a free data retrieval call binding the contract method 0x232de716.
//
// Solidity: function getSettingBool(bytes32 settingNameSpace, string _settingPath) view returns(bool)
func (_MinipoolManager *MinipoolManagerCaller) GetSettingBool(opts *bind.CallOpts, settingNameSpace [32]byte, _settingPath string) (bool, error) {
	var out []interface{}
	err := _MinipoolManager.contract.Call(opts, &out, "getSettingBool", settingNameSpace, _settingPath)

	if err != nil {
		return *new(bool), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)

	return out0, err

}

// GetSettingBool is a free data retrieval call binding the contract method 0x232de716.
//
// Solidity: function getSettingBool(bytes32 settingNameSpace, string _settingPath) view returns(bool)
func (_MinipoolManager *MinipoolManagerSession) GetSettingBool(settingNameSpace [32]byte, _settingPath string) (bool, error) {
	return _MinipoolManager.Contract.GetSettingBool(&_MinipoolManager.CallOpts, settingNameSpace, _settingPath)
}

// GetSettingBool is a free data retrieval call binding the contract method 0x232de716.
//
// Solidity: function getSettingBool(bytes32 settingNameSpace, string _settingPath) view returns(bool)
func (_MinipoolManager *MinipoolManagerCallerSession) GetSettingBool(settingNameSpace [32]byte, _settingPath string) (bool, error) {
	return _MinipoolManager.Contract.GetSettingBool(&_MinipoolManager.CallOpts, settingNameSpace, _settingPath)
}

// GetSettingUint is a free data retrieval call binding the contract method 0xf4d70e78.
//
// Solidity: function getSettingUint(bytes32 settingNameSpace, string _settingPath) view returns(uint256)
func (_MinipoolManager *MinipoolManagerCaller) GetSettingUint(opts *bind.CallOpts, settingNameSpace [32]byte, _settingPath string) (*big.Int, error) {
	var out []interface{}
	err := _MinipoolManager.contract.Call(opts, &out, "getSettingUint", settingNameSpace, _settingPath)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetSettingUint is a free data retrieval call binding the contract method 0xf4d70e78.
//
// Solidity: function getSettingUint(bytes32 settingNameSpace, string _settingPath) view returns(uint256)
func (_MinipoolManager *MinipoolManagerSession) GetSettingUint(settingNameSpace [32]byte, _settingPath string) (*big.Int, error) {
	return _MinipoolManager.Contract.GetSettingUint(&_MinipoolManager.CallOpts, settingNameSpace, _settingPath)
}

// GetSettingUint is a free data retrieval call binding the contract method 0xf4d70e78.
//
// Solidity: function getSettingUint(bytes32 settingNameSpace, string _settingPath) view returns(uint256)
func (_MinipoolManager *MinipoolManagerCallerSession) GetSettingUint(settingNameSpace [32]byte, _settingPath string) (*big.Int, error) {
	return _MinipoolManager.Contract.GetSettingUint(&_MinipoolManager.CallOpts, settingNameSpace, _settingPath)
}

// GgAVAX is a free data retrieval call binding the contract method 0xabd149dc.
//
// Solidity: function ggAVAX() view returns(address)
func (_MinipoolManager *MinipoolManagerCaller) GgAVAX(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _MinipoolManager.contract.Call(opts, &out, "ggAVAX")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// GgAVAX is a free data retrieval call binding the contract method 0xabd149dc.
//
// Solidity: function ggAVAX() view returns(address)
func (_MinipoolManager *MinipoolManagerSession) GgAVAX() (common.Address, error) {
	return _MinipoolManager.Contract.GgAVAX(&_MinipoolManager.CallOpts)
}

// GgAVAX is a free data retrieval call binding the contract method 0xabd149dc.
//
// Solidity: function ggAVAX() view returns(address)
func (_MinipoolManager *MinipoolManagerCallerSession) GgAVAX() (common.Address, error) {
	return _MinipoolManager.Contract.GgAVAX(&_MinipoolManager.CallOpts)
}

// Ggp is a free data retrieval call binding the contract method 0xf321df49.
//
// Solidity: function ggp() view returns(address)
func (_MinipoolManager *MinipoolManagerCaller) Ggp(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _MinipoolManager.contract.Call(opts, &out, "ggp")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// Ggp is a free data retrieval call binding the contract method 0xf321df49.
//
// Solidity: function ggp() view returns(address)
func (_MinipoolManager *MinipoolManagerSession) Ggp() (common.Address, error) {
	return _MinipoolManager.Contract.Ggp(&_MinipoolManager.CallOpts)
}

// Ggp is a free data retrieval call binding the contract method 0xf321df49.
//
// Solidity: function ggp() view returns(address)
func (_MinipoolManager *MinipoolManagerCallerSession) Ggp() (common.Address, error) {
	return _MinipoolManager.Contract.Ggp(&_MinipoolManager.CallOpts)
}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint8)
func (_MinipoolManager *MinipoolManagerCaller) Version(opts *bind.CallOpts) (uint8, error) {
	var out []interface{}
	err := _MinipoolManager.contract.Call(opts, &out, "version")

	if err != nil {
		return *new(uint8), err
	}

	out0 := *abi.ConvertType(out[0], new(uint8)).(*uint8)

	return out0, err

}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint8)
func (_MinipoolManager *MinipoolManagerSession) Version() (uint8, error) {
	return _MinipoolManager.Contract.Version(&_MinipoolManager.CallOpts)
}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint8)
func (_MinipoolManager *MinipoolManagerCallerSession) Version() (uint8, error) {
	return _MinipoolManager.Contract.Version(&_MinipoolManager.CallOpts)
}

// CancelMinipool is a paid mutator transaction binding the contract method 0x9cbed340.
//
// Solidity: function cancelMinipool(address nodeID) returns()
func (_MinipoolManager *MinipoolManagerTransactor) CancelMinipool(opts *bind.TransactOpts, nodeID common.Address) (*types.Transaction, error) {
	return _MinipoolManager.contract.Transact(opts, "cancelMinipool", nodeID)
}

// CancelMinipool is a paid mutator transaction binding the contract method 0x9cbed340.
//
// Solidity: function cancelMinipool(address nodeID) returns()
func (_MinipoolManager *MinipoolManagerSession) CancelMinipool(nodeID common.Address) (*types.Transaction, error) {
	return _MinipoolManager.Contract.CancelMinipool(&_MinipoolManager.TransactOpts, nodeID)
}

// CancelMinipool is a paid mutator transaction binding the contract method 0x9cbed340.
//
// Solidity: function cancelMinipool(address nodeID) returns()
func (_MinipoolManager *MinipoolManagerTransactorSession) CancelMinipool(nodeID common.Address) (*types.Transaction, error) {
	return _MinipoolManager.Contract.CancelMinipool(&_MinipoolManager.TransactOpts, nodeID)
}

// ClaimAndInitiateStaking is a paid mutator transaction binding the contract method 0x809784c5.
//
// Solidity: function claimAndInitiateStaking(address nodeID) returns()
func (_MinipoolManager *MinipoolManagerTransactor) ClaimAndInitiateStaking(opts *bind.TransactOpts, nodeID common.Address) (*types.Transaction, error) {
	return _MinipoolManager.contract.Transact(opts, "claimAndInitiateStaking", nodeID)
}

// ClaimAndInitiateStaking is a paid mutator transaction binding the contract method 0x809784c5.
//
// Solidity: function claimAndInitiateStaking(address nodeID) returns()
func (_MinipoolManager *MinipoolManagerSession) ClaimAndInitiateStaking(nodeID common.Address) (*types.Transaction, error) {
	return _MinipoolManager.Contract.ClaimAndInitiateStaking(&_MinipoolManager.TransactOpts, nodeID)
}

// ClaimAndInitiateStaking is a paid mutator transaction binding the contract method 0x809784c5.
//
// Solidity: function claimAndInitiateStaking(address nodeID) returns()
func (_MinipoolManager *MinipoolManagerTransactorSession) ClaimAndInitiateStaking(nodeID common.Address) (*types.Transaction, error) {
	return _MinipoolManager.Contract.ClaimAndInitiateStaking(&_MinipoolManager.TransactOpts, nodeID)
}

// CreateMinipool is a paid mutator transaction binding the contract method 0x356ff5a5.
//
// Solidity: function createMinipool(address nodeID, uint256 duration, uint256 delegationFee, uint256 ggpBondAmt) payable returns()
func (_MinipoolManager *MinipoolManagerTransactor) CreateMinipool(opts *bind.TransactOpts, nodeID common.Address, duration *big.Int, delegationFee *big.Int, ggpBondAmt *big.Int) (*types.Transaction, error) {
	return _MinipoolManager.contract.Transact(opts, "createMinipool", nodeID, duration, delegationFee, ggpBondAmt)
}

// CreateMinipool is a paid mutator transaction binding the contract method 0x356ff5a5.
//
// Solidity: function createMinipool(address nodeID, uint256 duration, uint256 delegationFee, uint256 ggpBondAmt) payable returns()
func (_MinipoolManager *MinipoolManagerSession) CreateMinipool(nodeID common.Address, duration *big.Int, delegationFee *big.Int, ggpBondAmt *big.Int) (*types.Transaction, error) {
	return _MinipoolManager.Contract.CreateMinipool(&_MinipoolManager.TransactOpts, nodeID, duration, delegationFee, ggpBondAmt)
}

// CreateMinipool is a paid mutator transaction binding the contract method 0x356ff5a5.
//
// Solidity: function createMinipool(address nodeID, uint256 duration, uint256 delegationFee, uint256 ggpBondAmt) payable returns()
func (_MinipoolManager *MinipoolManagerTransactorSession) CreateMinipool(nodeID common.Address, duration *big.Int, delegationFee *big.Int, ggpBondAmt *big.Int) (*types.Transaction, error) {
	return _MinipoolManager.Contract.CreateMinipool(&_MinipoolManager.TransactOpts, nodeID, duration, delegationFee, ggpBondAmt)
}

// ReceiveWithdrawalAVAX is a paid mutator transaction binding the contract method 0xffe09241.
//
// Solidity: function receiveWithdrawalAVAX() payable returns()
func (_MinipoolManager *MinipoolManagerTransactor) ReceiveWithdrawalAVAX(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _MinipoolManager.contract.Transact(opts, "receiveWithdrawalAVAX")
}

// ReceiveWithdrawalAVAX is a paid mutator transaction binding the contract method 0xffe09241.
//
// Solidity: function receiveWithdrawalAVAX() payable returns()
func (_MinipoolManager *MinipoolManagerSession) ReceiveWithdrawalAVAX() (*types.Transaction, error) {
	return _MinipoolManager.Contract.ReceiveWithdrawalAVAX(&_MinipoolManager.TransactOpts)
}

// ReceiveWithdrawalAVAX is a paid mutator transaction binding the contract method 0xffe09241.
//
// Solidity: function receiveWithdrawalAVAX() payable returns()
func (_MinipoolManager *MinipoolManagerTransactorSession) ReceiveWithdrawalAVAX() (*types.Transaction, error) {
	return _MinipoolManager.Contract.ReceiveWithdrawalAVAX(&_MinipoolManager.TransactOpts)
}

// RecordStakingEnd is a paid mutator transaction binding the contract method 0x8e481d60.
//
// Solidity: function recordStakingEnd(address nodeID, uint256 endTime, uint256 avaxTotalRewardAmt) payable returns()
func (_MinipoolManager *MinipoolManagerTransactor) RecordStakingEnd(opts *bind.TransactOpts, nodeID common.Address, endTime *big.Int, avaxTotalRewardAmt *big.Int) (*types.Transaction, error) {
	return _MinipoolManager.contract.Transact(opts, "recordStakingEnd", nodeID, endTime, avaxTotalRewardAmt)
}

// RecordStakingEnd is a paid mutator transaction binding the contract method 0x8e481d60.
//
// Solidity: function recordStakingEnd(address nodeID, uint256 endTime, uint256 avaxTotalRewardAmt) payable returns()
func (_MinipoolManager *MinipoolManagerSession) RecordStakingEnd(nodeID common.Address, endTime *big.Int, avaxTotalRewardAmt *big.Int) (*types.Transaction, error) {
	return _MinipoolManager.Contract.RecordStakingEnd(&_MinipoolManager.TransactOpts, nodeID, endTime, avaxTotalRewardAmt)
}

// RecordStakingEnd is a paid mutator transaction binding the contract method 0x8e481d60.
//
// Solidity: function recordStakingEnd(address nodeID, uint256 endTime, uint256 avaxTotalRewardAmt) payable returns()
func (_MinipoolManager *MinipoolManagerTransactorSession) RecordStakingEnd(nodeID common.Address, endTime *big.Int, avaxTotalRewardAmt *big.Int) (*types.Transaction, error) {
	return _MinipoolManager.Contract.RecordStakingEnd(&_MinipoolManager.TransactOpts, nodeID, endTime, avaxTotalRewardAmt)
}

// RecordStakingError is a paid mutator transaction binding the contract method 0x75c98715.
//
// Solidity: function recordStakingError(address nodeID, uint256 endTime, string message) returns()
func (_MinipoolManager *MinipoolManagerTransactor) RecordStakingError(opts *bind.TransactOpts, nodeID common.Address, endTime *big.Int, message string) (*types.Transaction, error) {
	return _MinipoolManager.contract.Transact(opts, "recordStakingError", nodeID, endTime, message)
}

// RecordStakingError is a paid mutator transaction binding the contract method 0x75c98715.
//
// Solidity: function recordStakingError(address nodeID, uint256 endTime, string message) returns()
func (_MinipoolManager *MinipoolManagerSession) RecordStakingError(nodeID common.Address, endTime *big.Int, message string) (*types.Transaction, error) {
	return _MinipoolManager.Contract.RecordStakingError(&_MinipoolManager.TransactOpts, nodeID, endTime, message)
}

// RecordStakingError is a paid mutator transaction binding the contract method 0x75c98715.
//
// Solidity: function recordStakingError(address nodeID, uint256 endTime, string message) returns()
func (_MinipoolManager *MinipoolManagerTransactorSession) RecordStakingError(nodeID common.Address, endTime *big.Int, message string) (*types.Transaction, error) {
	return _MinipoolManager.Contract.RecordStakingError(&_MinipoolManager.TransactOpts, nodeID, endTime, message)
}

// RecordStakingStart is a paid mutator transaction binding the contract method 0x19ef22b2.
//
// Solidity: function recordStakingStart(address nodeID, uint256 startTime) returns()
func (_MinipoolManager *MinipoolManagerTransactor) RecordStakingStart(opts *bind.TransactOpts, nodeID common.Address, startTime *big.Int) (*types.Transaction, error) {
	return _MinipoolManager.contract.Transact(opts, "recordStakingStart", nodeID, startTime)
}

// RecordStakingStart is a paid mutator transaction binding the contract method 0x19ef22b2.
//
// Solidity: function recordStakingStart(address nodeID, uint256 startTime) returns()
func (_MinipoolManager *MinipoolManagerSession) RecordStakingStart(nodeID common.Address, startTime *big.Int) (*types.Transaction, error) {
	return _MinipoolManager.Contract.RecordStakingStart(&_MinipoolManager.TransactOpts, nodeID, startTime)
}

// RecordStakingStart is a paid mutator transaction binding the contract method 0x19ef22b2.
//
// Solidity: function recordStakingStart(address nodeID, uint256 startTime) returns()
func (_MinipoolManager *MinipoolManagerTransactorSession) RecordStakingStart(nodeID common.Address, startTime *big.Int) (*types.Transaction, error) {
	return _MinipoolManager.Contract.RecordStakingStart(&_MinipoolManager.TransactOpts, nodeID, startTime)
}

// UpdateMinipoolStatus is a paid mutator transaction binding the contract method 0xe92aa0ce.
//
// Solidity: function updateMinipoolStatus(address nodeID, uint8 status) returns()
func (_MinipoolManager *MinipoolManagerTransactor) UpdateMinipoolStatus(opts *bind.TransactOpts, nodeID common.Address, status uint8) (*types.Transaction, error) {
	return _MinipoolManager.contract.Transact(opts, "updateMinipoolStatus", nodeID, status)
}

// UpdateMinipoolStatus is a paid mutator transaction binding the contract method 0xe92aa0ce.
//
// Solidity: function updateMinipoolStatus(address nodeID, uint8 status) returns()
func (_MinipoolManager *MinipoolManagerSession) UpdateMinipoolStatus(nodeID common.Address, status uint8) (*types.Transaction, error) {
	return _MinipoolManager.Contract.UpdateMinipoolStatus(&_MinipoolManager.TransactOpts, nodeID, status)
}

// UpdateMinipoolStatus is a paid mutator transaction binding the contract method 0xe92aa0ce.
//
// Solidity: function updateMinipoolStatus(address nodeID, uint8 status) returns()
func (_MinipoolManager *MinipoolManagerTransactorSession) UpdateMinipoolStatus(nodeID common.Address, status uint8) (*types.Transaction, error) {
	return _MinipoolManager.Contract.UpdateMinipoolStatus(&_MinipoolManager.TransactOpts, nodeID, status)
}

// WithdrawMinipoolFunds is a paid mutator transaction binding the contract method 0x2f1fbf9b.
//
// Solidity: function withdrawMinipoolFunds(address nodeID) returns()
func (_MinipoolManager *MinipoolManagerTransactor) WithdrawMinipoolFunds(opts *bind.TransactOpts, nodeID common.Address) (*types.Transaction, error) {
	return _MinipoolManager.contract.Transact(opts, "withdrawMinipoolFunds", nodeID)
}

// WithdrawMinipoolFunds is a paid mutator transaction binding the contract method 0x2f1fbf9b.
//
// Solidity: function withdrawMinipoolFunds(address nodeID) returns()
func (_MinipoolManager *MinipoolManagerSession) WithdrawMinipoolFunds(nodeID common.Address) (*types.Transaction, error) {
	return _MinipoolManager.Contract.WithdrawMinipoolFunds(&_MinipoolManager.TransactOpts, nodeID)
}

// WithdrawMinipoolFunds is a paid mutator transaction binding the contract method 0x2f1fbf9b.
//
// Solidity: function withdrawMinipoolFunds(address nodeID) returns()
func (_MinipoolManager *MinipoolManagerTransactorSession) WithdrawMinipoolFunds(nodeID common.Address) (*types.Transaction, error) {
	return _MinipoolManager.Contract.WithdrawMinipoolFunds(&_MinipoolManager.TransactOpts, nodeID)
}

// MinipoolManagerMinipoolStatusChangedIterator is returned from FilterMinipoolStatusChanged and is used to iterate over the raw logs and unpacked data for MinipoolStatusChanged events raised by the MinipoolManager contract.
type MinipoolManagerMinipoolStatusChangedIterator struct {
	Event *MinipoolManagerMinipoolStatusChanged // Event containing the contract specifics and raw log

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
func (it *MinipoolManagerMinipoolStatusChangedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(MinipoolManagerMinipoolStatusChanged)
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
		it.Event = new(MinipoolManagerMinipoolStatusChanged)
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
func (it *MinipoolManagerMinipoolStatusChangedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *MinipoolManagerMinipoolStatusChangedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// MinipoolManagerMinipoolStatusChanged represents a MinipoolStatusChanged event raised by the MinipoolManager contract.
type MinipoolManagerMinipoolStatusChanged struct {
	NodeID common.Address
	Status uint8
	Raw    types.Log // Blockchain specific contextual infos
}

// FilterMinipoolStatusChanged is a free log retrieval operation binding the contract event 0xc9c043637725967252aedd2704cc65fee962e7b8a1e3cf8098587a66601e50c5.
//
// Solidity: event MinipoolStatusChanged(address indexed nodeID, uint8 indexed status)
func (_MinipoolManager *MinipoolManagerFilterer) FilterMinipoolStatusChanged(opts *bind.FilterOpts, nodeID []common.Address, status []uint8) (*MinipoolManagerMinipoolStatusChangedIterator, error) {

	var nodeIDRule []interface{}
	for _, nodeIDItem := range nodeID {
		nodeIDRule = append(nodeIDRule, nodeIDItem)
	}
	var statusRule []interface{}
	for _, statusItem := range status {
		statusRule = append(statusRule, statusItem)
	}

	logs, sub, err := _MinipoolManager.contract.FilterLogs(opts, "MinipoolStatusChanged", nodeIDRule, statusRule)
	if err != nil {
		return nil, err
	}
	return &MinipoolManagerMinipoolStatusChangedIterator{contract: _MinipoolManager.contract, event: "MinipoolStatusChanged", logs: logs, sub: sub}, nil
}

// WatchMinipoolStatusChanged is a free log subscription operation binding the contract event 0xc9c043637725967252aedd2704cc65fee962e7b8a1e3cf8098587a66601e50c5.
//
// Solidity: event MinipoolStatusChanged(address indexed nodeID, uint8 indexed status)
func (_MinipoolManager *MinipoolManagerFilterer) WatchMinipoolStatusChanged(opts *bind.WatchOpts, sink chan<- *MinipoolManagerMinipoolStatusChanged, nodeID []common.Address, status []uint8) (event.Subscription, error) {

	var nodeIDRule []interface{}
	for _, nodeIDItem := range nodeID {
		nodeIDRule = append(nodeIDRule, nodeIDItem)
	}
	var statusRule []interface{}
	for _, statusItem := range status {
		statusRule = append(statusRule, statusItem)
	}

	logs, sub, err := _MinipoolManager.contract.WatchLogs(opts, "MinipoolStatusChanged", nodeIDRule, statusRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(MinipoolManagerMinipoolStatusChanged)
				if err := _MinipoolManager.contract.UnpackLog(event, "MinipoolStatusChanged", log); err != nil {
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

// ParseMinipoolStatusChanged is a log parse operation binding the contract event 0xc9c043637725967252aedd2704cc65fee962e7b8a1e3cf8098587a66601e50c5.
//
// Solidity: event MinipoolStatusChanged(address indexed nodeID, uint8 indexed status)
func (_MinipoolManager *MinipoolManagerFilterer) ParseMinipoolStatusChanged(log types.Log) (*MinipoolManagerMinipoolStatusChanged, error) {
	event := new(MinipoolManagerMinipoolStatusChanged)
	if err := _MinipoolManager.contract.UnpackLog(event, "MinipoolStatusChanged", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// MinipoolManagerZeroRewardsReceivedIterator is returned from FilterZeroRewardsReceived and is used to iterate over the raw logs and unpacked data for ZeroRewardsReceived events raised by the MinipoolManager contract.
type MinipoolManagerZeroRewardsReceivedIterator struct {
	Event *MinipoolManagerZeroRewardsReceived // Event containing the contract specifics and raw log

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
func (it *MinipoolManagerZeroRewardsReceivedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(MinipoolManagerZeroRewardsReceived)
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
		it.Event = new(MinipoolManagerZeroRewardsReceived)
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
func (it *MinipoolManagerZeroRewardsReceivedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *MinipoolManagerZeroRewardsReceivedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// MinipoolManagerZeroRewardsReceived represents a ZeroRewardsReceived event raised by the MinipoolManager contract.
type MinipoolManagerZeroRewardsReceived struct {
	NodeID common.Address
	Raw    types.Log // Blockchain specific contextual infos
}

// FilterZeroRewardsReceived is a free log retrieval operation binding the contract event 0x4de2de2eb237a87271594c46bdc72f22bfa1c9c80013447db9be8ff66e5b837b.
//
// Solidity: event ZeroRewardsReceived(address indexed nodeID)
func (_MinipoolManager *MinipoolManagerFilterer) FilterZeroRewardsReceived(opts *bind.FilterOpts, nodeID []common.Address) (*MinipoolManagerZeroRewardsReceivedIterator, error) {

	var nodeIDRule []interface{}
	for _, nodeIDItem := range nodeID {
		nodeIDRule = append(nodeIDRule, nodeIDItem)
	}

	logs, sub, err := _MinipoolManager.contract.FilterLogs(opts, "ZeroRewardsReceived", nodeIDRule)
	if err != nil {
		return nil, err
	}
	return &MinipoolManagerZeroRewardsReceivedIterator{contract: _MinipoolManager.contract, event: "ZeroRewardsReceived", logs: logs, sub: sub}, nil
}

// WatchZeroRewardsReceived is a free log subscription operation binding the contract event 0x4de2de2eb237a87271594c46bdc72f22bfa1c9c80013447db9be8ff66e5b837b.
//
// Solidity: event ZeroRewardsReceived(address indexed nodeID)
func (_MinipoolManager *MinipoolManagerFilterer) WatchZeroRewardsReceived(opts *bind.WatchOpts, sink chan<- *MinipoolManagerZeroRewardsReceived, nodeID []common.Address) (event.Subscription, error) {

	var nodeIDRule []interface{}
	for _, nodeIDItem := range nodeID {
		nodeIDRule = append(nodeIDRule, nodeIDItem)
	}

	logs, sub, err := _MinipoolManager.contract.WatchLogs(opts, "ZeroRewardsReceived", nodeIDRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(MinipoolManagerZeroRewardsReceived)
				if err := _MinipoolManager.contract.UnpackLog(event, "ZeroRewardsReceived", log); err != nil {
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

// ParseZeroRewardsReceived is a log parse operation binding the contract event 0x4de2de2eb237a87271594c46bdc72f22bfa1c9c80013447db9be8ff66e5b837b.
//
// Solidity: event ZeroRewardsReceived(address indexed nodeID)
func (_MinipoolManager *MinipoolManagerFilterer) ParseZeroRewardsReceived(log types.Log) (*MinipoolManagerZeroRewardsReceived, error) {
	event := new(MinipoolManagerZeroRewardsReceived)
	if err := _MinipoolManager.contract.UnpackLog(event, "ZeroRewardsReceived", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
