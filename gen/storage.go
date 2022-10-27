// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package storage

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

// StorageMetaData contains all meta data concerning the Storage contract.
var StorageMetaData = &bind.MetaData{
	ABI: "[{\"inputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"inputs\":[],\"name\":\"InvalidGuardianConfirmation\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"InvalidOrOutdatedContract\",\"type\":\"error\"},{\"inputs\":[],\"name\":\"MustBeGuardian\",\"type\":\"error\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"address\",\"name\":\"oldGuardian\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"address\",\"name\":\"newGuardian\",\"type\":\"address\"}],\"name\":\"GuardianChanged\",\"type\":\"event\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"addUint\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"confirmGuardian\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"}],\"name\":\"deleteAddress\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"}],\"name\":\"deleteBool\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"}],\"name\":\"deleteBytes\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"}],\"name\":\"deleteBytes32\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"}],\"name\":\"deleteInt\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"}],\"name\":\"deleteString\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"}],\"name\":\"deleteUint\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"}],\"name\":\"getAddress\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"r\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"}],\"name\":\"getBool\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"r\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"}],\"name\":\"getBytes\",\"outputs\":[{\"internalType\":\"bytes\",\"name\":\"\",\"type\":\"bytes\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"}],\"name\":\"getBytes32\",\"outputs\":[{\"internalType\":\"bytes32\",\"name\":\"r\",\"type\":\"bytes32\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"getGuardian\",\"outputs\":[{\"internalType\":\"address\",\"name\":\"\",\"type\":\"address\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"}],\"name\":\"getInt\",\"outputs\":[{\"internalType\":\"int256\",\"name\":\"r\",\"type\":\"int256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"}],\"name\":\"getString\",\"outputs\":[{\"internalType\":\"string\",\"name\":\"\",\"type\":\"string\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"}],\"name\":\"getUint\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"r\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"},{\"internalType\":\"address\",\"name\":\"value\",\"type\":\"address\"}],\"name\":\"setAddress\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"},{\"internalType\":\"bool\",\"name\":\"value\",\"type\":\"bool\"}],\"name\":\"setBool\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"},{\"internalType\":\"bytes\",\"name\":\"value\",\"type\":\"bytes\"}],\"name\":\"setBytes\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"},{\"internalType\":\"bytes32\",\"name\":\"value\",\"type\":\"bytes32\"}],\"name\":\"setBytes32\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"newAddress\",\"type\":\"address\"}],\"name\":\"setGuardian\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"},{\"internalType\":\"int256\",\"name\":\"value\",\"type\":\"int256\"}],\"name\":\"setInt\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"},{\"internalType\":\"string\",\"name\":\"value\",\"type\":\"string\"}],\"name\":\"setString\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"},{\"internalType\":\"uint256\",\"name\":\"value\",\"type\":\"uint256\"}],\"name\":\"setUint\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"bytes32\",\"name\":\"key\",\"type\":\"bytes32\"},{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"subUint\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]",
}

// StorageABI is the input ABI used to generate the binding from.
// Deprecated: Use StorageMetaData.ABI instead.
var StorageABI = StorageMetaData.ABI

// Storage is an auto generated Go binding around an Ethereum contract.
type Storage struct {
	StorageCaller     // Read-only binding to the contract
	StorageTransactor // Write-only binding to the contract
	StorageFilterer   // Log filterer for contract events
}

// StorageCaller is an auto generated read-only Go binding around an Ethereum contract.
type StorageCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// StorageTransactor is an auto generated write-only Go binding around an Ethereum contract.
type StorageTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// StorageFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type StorageFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// StorageSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type StorageSession struct {
	Contract     *Storage          // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// StorageCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type StorageCallerSession struct {
	Contract *StorageCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts  // Call options to use throughout this session
}

// StorageTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type StorageTransactorSession struct {
	Contract     *StorageTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts  // Transaction auth options to use throughout this session
}

// StorageRaw is an auto generated low-level Go binding around an Ethereum contract.
type StorageRaw struct {
	Contract *Storage // Generic contract binding to access the raw methods on
}

// StorageCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type StorageCallerRaw struct {
	Contract *StorageCaller // Generic read-only contract binding to access the raw methods on
}

// StorageTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type StorageTransactorRaw struct {
	Contract *StorageTransactor // Generic write-only contract binding to access the raw methods on
}

// NewStorage creates a new instance of Storage, bound to a specific deployed contract.
func NewStorage(address common.Address, backend bind.ContractBackend) (*Storage, error) {
	contract, err := bindStorage(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &Storage{StorageCaller: StorageCaller{contract: contract}, StorageTransactor: StorageTransactor{contract: contract}, StorageFilterer: StorageFilterer{contract: contract}}, nil
}

// NewStorageCaller creates a new read-only instance of Storage, bound to a specific deployed contract.
func NewStorageCaller(address common.Address, caller bind.ContractCaller) (*StorageCaller, error) {
	contract, err := bindStorage(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &StorageCaller{contract: contract}, nil
}

// NewStorageTransactor creates a new write-only instance of Storage, bound to a specific deployed contract.
func NewStorageTransactor(address common.Address, transactor bind.ContractTransactor) (*StorageTransactor, error) {
	contract, err := bindStorage(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &StorageTransactor{contract: contract}, nil
}

// NewStorageFilterer creates a new log filterer instance of Storage, bound to a specific deployed contract.
func NewStorageFilterer(address common.Address, filterer bind.ContractFilterer) (*StorageFilterer, error) {
	contract, err := bindStorage(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &StorageFilterer{contract: contract}, nil
}

// bindStorage binds a generic wrapper to an already deployed contract.
func bindStorage(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := abi.JSON(strings.NewReader(StorageABI))
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_Storage *StorageRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _Storage.Contract.StorageCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_Storage *StorageRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Storage.Contract.StorageTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_Storage *StorageRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _Storage.Contract.StorageTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_Storage *StorageCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _Storage.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_Storage *StorageTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Storage.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_Storage *StorageTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _Storage.Contract.contract.Transact(opts, method, params...)
}

// GetAddress is a free data retrieval call binding the contract method 0x21f8a721.
//
// Solidity: function getAddress(bytes32 key) view returns(address r)
func (_Storage *StorageCaller) GetAddress(opts *bind.CallOpts, key [32]byte) (common.Address, error) {
	var out []interface{}
	err := _Storage.contract.Call(opts, &out, "getAddress", key)

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// GetAddress is a free data retrieval call binding the contract method 0x21f8a721.
//
// Solidity: function getAddress(bytes32 key) view returns(address r)
func (_Storage *StorageSession) GetAddress(key [32]byte) (common.Address, error) {
	return _Storage.Contract.GetAddress(&_Storage.CallOpts, key)
}

// GetAddress is a free data retrieval call binding the contract method 0x21f8a721.
//
// Solidity: function getAddress(bytes32 key) view returns(address r)
func (_Storage *StorageCallerSession) GetAddress(key [32]byte) (common.Address, error) {
	return _Storage.Contract.GetAddress(&_Storage.CallOpts, key)
}

// GetBool is a free data retrieval call binding the contract method 0x7ae1cfca.
//
// Solidity: function getBool(bytes32 key) view returns(bool r)
func (_Storage *StorageCaller) GetBool(opts *bind.CallOpts, key [32]byte) (bool, error) {
	var out []interface{}
	err := _Storage.contract.Call(opts, &out, "getBool", key)

	if err != nil {
		return *new(bool), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)

	return out0, err

}

// GetBool is a free data retrieval call binding the contract method 0x7ae1cfca.
//
// Solidity: function getBool(bytes32 key) view returns(bool r)
func (_Storage *StorageSession) GetBool(key [32]byte) (bool, error) {
	return _Storage.Contract.GetBool(&_Storage.CallOpts, key)
}

// GetBool is a free data retrieval call binding the contract method 0x7ae1cfca.
//
// Solidity: function getBool(bytes32 key) view returns(bool r)
func (_Storage *StorageCallerSession) GetBool(key [32]byte) (bool, error) {
	return _Storage.Contract.GetBool(&_Storage.CallOpts, key)
}

// GetBytes is a free data retrieval call binding the contract method 0xc031a180.
//
// Solidity: function getBytes(bytes32 key) view returns(bytes)
func (_Storage *StorageCaller) GetBytes(opts *bind.CallOpts, key [32]byte) ([]byte, error) {
	var out []interface{}
	err := _Storage.contract.Call(opts, &out, "getBytes", key)

	if err != nil {
		return *new([]byte), err
	}

	out0 := *abi.ConvertType(out[0], new([]byte)).(*[]byte)

	return out0, err

}

// GetBytes is a free data retrieval call binding the contract method 0xc031a180.
//
// Solidity: function getBytes(bytes32 key) view returns(bytes)
func (_Storage *StorageSession) GetBytes(key [32]byte) ([]byte, error) {
	return _Storage.Contract.GetBytes(&_Storage.CallOpts, key)
}

// GetBytes is a free data retrieval call binding the contract method 0xc031a180.
//
// Solidity: function getBytes(bytes32 key) view returns(bytes)
func (_Storage *StorageCallerSession) GetBytes(key [32]byte) ([]byte, error) {
	return _Storage.Contract.GetBytes(&_Storage.CallOpts, key)
}

// GetBytes32 is a free data retrieval call binding the contract method 0xa6ed563e.
//
// Solidity: function getBytes32(bytes32 key) view returns(bytes32 r)
func (_Storage *StorageCaller) GetBytes32(opts *bind.CallOpts, key [32]byte) ([32]byte, error) {
	var out []interface{}
	err := _Storage.contract.Call(opts, &out, "getBytes32", key)

	if err != nil {
		return *new([32]byte), err
	}

	out0 := *abi.ConvertType(out[0], new([32]byte)).(*[32]byte)

	return out0, err

}

// GetBytes32 is a free data retrieval call binding the contract method 0xa6ed563e.
//
// Solidity: function getBytes32(bytes32 key) view returns(bytes32 r)
func (_Storage *StorageSession) GetBytes32(key [32]byte) ([32]byte, error) {
	return _Storage.Contract.GetBytes32(&_Storage.CallOpts, key)
}

// GetBytes32 is a free data retrieval call binding the contract method 0xa6ed563e.
//
// Solidity: function getBytes32(bytes32 key) view returns(bytes32 r)
func (_Storage *StorageCallerSession) GetBytes32(key [32]byte) ([32]byte, error) {
	return _Storage.Contract.GetBytes32(&_Storage.CallOpts, key)
}

// GetGuardian is a free data retrieval call binding the contract method 0xa75b87d2.
//
// Solidity: function getGuardian() view returns(address)
func (_Storage *StorageCaller) GetGuardian(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _Storage.contract.Call(opts, &out, "getGuardian")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// GetGuardian is a free data retrieval call binding the contract method 0xa75b87d2.
//
// Solidity: function getGuardian() view returns(address)
func (_Storage *StorageSession) GetGuardian() (common.Address, error) {
	return _Storage.Contract.GetGuardian(&_Storage.CallOpts)
}

// GetGuardian is a free data retrieval call binding the contract method 0xa75b87d2.
//
// Solidity: function getGuardian() view returns(address)
func (_Storage *StorageCallerSession) GetGuardian() (common.Address, error) {
	return _Storage.Contract.GetGuardian(&_Storage.CallOpts)
}

// GetInt is a free data retrieval call binding the contract method 0xdc97d962.
//
// Solidity: function getInt(bytes32 key) view returns(int256 r)
func (_Storage *StorageCaller) GetInt(opts *bind.CallOpts, key [32]byte) (*big.Int, error) {
	var out []interface{}
	err := _Storage.contract.Call(opts, &out, "getInt", key)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetInt is a free data retrieval call binding the contract method 0xdc97d962.
//
// Solidity: function getInt(bytes32 key) view returns(int256 r)
func (_Storage *StorageSession) GetInt(key [32]byte) (*big.Int, error) {
	return _Storage.Contract.GetInt(&_Storage.CallOpts, key)
}

// GetInt is a free data retrieval call binding the contract method 0xdc97d962.
//
// Solidity: function getInt(bytes32 key) view returns(int256 r)
func (_Storage *StorageCallerSession) GetInt(key [32]byte) (*big.Int, error) {
	return _Storage.Contract.GetInt(&_Storage.CallOpts, key)
}

// GetString is a free data retrieval call binding the contract method 0x986e791a.
//
// Solidity: function getString(bytes32 key) view returns(string)
func (_Storage *StorageCaller) GetString(opts *bind.CallOpts, key [32]byte) (string, error) {
	var out []interface{}
	err := _Storage.contract.Call(opts, &out, "getString", key)

	if err != nil {
		return *new(string), err
	}

	out0 := *abi.ConvertType(out[0], new(string)).(*string)

	return out0, err

}

// GetString is a free data retrieval call binding the contract method 0x986e791a.
//
// Solidity: function getString(bytes32 key) view returns(string)
func (_Storage *StorageSession) GetString(key [32]byte) (string, error) {
	return _Storage.Contract.GetString(&_Storage.CallOpts, key)
}

// GetString is a free data retrieval call binding the contract method 0x986e791a.
//
// Solidity: function getString(bytes32 key) view returns(string)
func (_Storage *StorageCallerSession) GetString(key [32]byte) (string, error) {
	return _Storage.Contract.GetString(&_Storage.CallOpts, key)
}

// GetUint is a free data retrieval call binding the contract method 0xbd02d0f5.
//
// Solidity: function getUint(bytes32 key) view returns(uint256 r)
func (_Storage *StorageCaller) GetUint(opts *bind.CallOpts, key [32]byte) (*big.Int, error) {
	var out []interface{}
	err := _Storage.contract.Call(opts, &out, "getUint", key)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetUint is a free data retrieval call binding the contract method 0xbd02d0f5.
//
// Solidity: function getUint(bytes32 key) view returns(uint256 r)
func (_Storage *StorageSession) GetUint(key [32]byte) (*big.Int, error) {
	return _Storage.Contract.GetUint(&_Storage.CallOpts, key)
}

// GetUint is a free data retrieval call binding the contract method 0xbd02d0f5.
//
// Solidity: function getUint(bytes32 key) view returns(uint256 r)
func (_Storage *StorageCallerSession) GetUint(key [32]byte) (*big.Int, error) {
	return _Storage.Contract.GetUint(&_Storage.CallOpts, key)
}

// AddUint is a paid mutator transaction binding the contract method 0xadb353dc.
//
// Solidity: function addUint(bytes32 key, uint256 amount) returns()
func (_Storage *StorageTransactor) AddUint(opts *bind.TransactOpts, key [32]byte, amount *big.Int) (*types.Transaction, error) {
	return _Storage.contract.Transact(opts, "addUint", key, amount)
}

// AddUint is a paid mutator transaction binding the contract method 0xadb353dc.
//
// Solidity: function addUint(bytes32 key, uint256 amount) returns()
func (_Storage *StorageSession) AddUint(key [32]byte, amount *big.Int) (*types.Transaction, error) {
	return _Storage.Contract.AddUint(&_Storage.TransactOpts, key, amount)
}

// AddUint is a paid mutator transaction binding the contract method 0xadb353dc.
//
// Solidity: function addUint(bytes32 key, uint256 amount) returns()
func (_Storage *StorageTransactorSession) AddUint(key [32]byte, amount *big.Int) (*types.Transaction, error) {
	return _Storage.Contract.AddUint(&_Storage.TransactOpts, key, amount)
}

// ConfirmGuardian is a paid mutator transaction binding the contract method 0x1e0ea61e.
//
// Solidity: function confirmGuardian() returns()
func (_Storage *StorageTransactor) ConfirmGuardian(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Storage.contract.Transact(opts, "confirmGuardian")
}

// ConfirmGuardian is a paid mutator transaction binding the contract method 0x1e0ea61e.
//
// Solidity: function confirmGuardian() returns()
func (_Storage *StorageSession) ConfirmGuardian() (*types.Transaction, error) {
	return _Storage.Contract.ConfirmGuardian(&_Storage.TransactOpts)
}

// ConfirmGuardian is a paid mutator transaction binding the contract method 0x1e0ea61e.
//
// Solidity: function confirmGuardian() returns()
func (_Storage *StorageTransactorSession) ConfirmGuardian() (*types.Transaction, error) {
	return _Storage.Contract.ConfirmGuardian(&_Storage.TransactOpts)
}

// DeleteAddress is a paid mutator transaction binding the contract method 0x0e14a376.
//
// Solidity: function deleteAddress(bytes32 key) returns()
func (_Storage *StorageTransactor) DeleteAddress(opts *bind.TransactOpts, key [32]byte) (*types.Transaction, error) {
	return _Storage.contract.Transact(opts, "deleteAddress", key)
}

// DeleteAddress is a paid mutator transaction binding the contract method 0x0e14a376.
//
// Solidity: function deleteAddress(bytes32 key) returns()
func (_Storage *StorageSession) DeleteAddress(key [32]byte) (*types.Transaction, error) {
	return _Storage.Contract.DeleteAddress(&_Storage.TransactOpts, key)
}

// DeleteAddress is a paid mutator transaction binding the contract method 0x0e14a376.
//
// Solidity: function deleteAddress(bytes32 key) returns()
func (_Storage *StorageTransactorSession) DeleteAddress(key [32]byte) (*types.Transaction, error) {
	return _Storage.Contract.DeleteAddress(&_Storage.TransactOpts, key)
}

// DeleteBool is a paid mutator transaction binding the contract method 0x2c62ff2d.
//
// Solidity: function deleteBool(bytes32 key) returns()
func (_Storage *StorageTransactor) DeleteBool(opts *bind.TransactOpts, key [32]byte) (*types.Transaction, error) {
	return _Storage.contract.Transact(opts, "deleteBool", key)
}

// DeleteBool is a paid mutator transaction binding the contract method 0x2c62ff2d.
//
// Solidity: function deleteBool(bytes32 key) returns()
func (_Storage *StorageSession) DeleteBool(key [32]byte) (*types.Transaction, error) {
	return _Storage.Contract.DeleteBool(&_Storage.TransactOpts, key)
}

// DeleteBool is a paid mutator transaction binding the contract method 0x2c62ff2d.
//
// Solidity: function deleteBool(bytes32 key) returns()
func (_Storage *StorageTransactorSession) DeleteBool(key [32]byte) (*types.Transaction, error) {
	return _Storage.Contract.DeleteBool(&_Storage.TransactOpts, key)
}

// DeleteBytes is a paid mutator transaction binding the contract method 0x616b59f6.
//
// Solidity: function deleteBytes(bytes32 key) returns()
func (_Storage *StorageTransactor) DeleteBytes(opts *bind.TransactOpts, key [32]byte) (*types.Transaction, error) {
	return _Storage.contract.Transact(opts, "deleteBytes", key)
}

// DeleteBytes is a paid mutator transaction binding the contract method 0x616b59f6.
//
// Solidity: function deleteBytes(bytes32 key) returns()
func (_Storage *StorageSession) DeleteBytes(key [32]byte) (*types.Transaction, error) {
	return _Storage.Contract.DeleteBytes(&_Storage.TransactOpts, key)
}

// DeleteBytes is a paid mutator transaction binding the contract method 0x616b59f6.
//
// Solidity: function deleteBytes(bytes32 key) returns()
func (_Storage *StorageTransactorSession) DeleteBytes(key [32]byte) (*types.Transaction, error) {
	return _Storage.Contract.DeleteBytes(&_Storage.TransactOpts, key)
}

// DeleteBytes32 is a paid mutator transaction binding the contract method 0x0b9adc57.
//
// Solidity: function deleteBytes32(bytes32 key) returns()
func (_Storage *StorageTransactor) DeleteBytes32(opts *bind.TransactOpts, key [32]byte) (*types.Transaction, error) {
	return _Storage.contract.Transact(opts, "deleteBytes32", key)
}

// DeleteBytes32 is a paid mutator transaction binding the contract method 0x0b9adc57.
//
// Solidity: function deleteBytes32(bytes32 key) returns()
func (_Storage *StorageSession) DeleteBytes32(key [32]byte) (*types.Transaction, error) {
	return _Storage.Contract.DeleteBytes32(&_Storage.TransactOpts, key)
}

// DeleteBytes32 is a paid mutator transaction binding the contract method 0x0b9adc57.
//
// Solidity: function deleteBytes32(bytes32 key) returns()
func (_Storage *StorageTransactorSession) DeleteBytes32(key [32]byte) (*types.Transaction, error) {
	return _Storage.Contract.DeleteBytes32(&_Storage.TransactOpts, key)
}

// DeleteInt is a paid mutator transaction binding the contract method 0x8c160095.
//
// Solidity: function deleteInt(bytes32 key) returns()
func (_Storage *StorageTransactor) DeleteInt(opts *bind.TransactOpts, key [32]byte) (*types.Transaction, error) {
	return _Storage.contract.Transact(opts, "deleteInt", key)
}

// DeleteInt is a paid mutator transaction binding the contract method 0x8c160095.
//
// Solidity: function deleteInt(bytes32 key) returns()
func (_Storage *StorageSession) DeleteInt(key [32]byte) (*types.Transaction, error) {
	return _Storage.Contract.DeleteInt(&_Storage.TransactOpts, key)
}

// DeleteInt is a paid mutator transaction binding the contract method 0x8c160095.
//
// Solidity: function deleteInt(bytes32 key) returns()
func (_Storage *StorageTransactorSession) DeleteInt(key [32]byte) (*types.Transaction, error) {
	return _Storage.Contract.DeleteInt(&_Storage.TransactOpts, key)
}

// DeleteString is a paid mutator transaction binding the contract method 0xf6bb3cc4.
//
// Solidity: function deleteString(bytes32 key) returns()
func (_Storage *StorageTransactor) DeleteString(opts *bind.TransactOpts, key [32]byte) (*types.Transaction, error) {
	return _Storage.contract.Transact(opts, "deleteString", key)
}

// DeleteString is a paid mutator transaction binding the contract method 0xf6bb3cc4.
//
// Solidity: function deleteString(bytes32 key) returns()
func (_Storage *StorageSession) DeleteString(key [32]byte) (*types.Transaction, error) {
	return _Storage.Contract.DeleteString(&_Storage.TransactOpts, key)
}

// DeleteString is a paid mutator transaction binding the contract method 0xf6bb3cc4.
//
// Solidity: function deleteString(bytes32 key) returns()
func (_Storage *StorageTransactorSession) DeleteString(key [32]byte) (*types.Transaction, error) {
	return _Storage.Contract.DeleteString(&_Storage.TransactOpts, key)
}

// DeleteUint is a paid mutator transaction binding the contract method 0xe2b202bf.
//
// Solidity: function deleteUint(bytes32 key) returns()
func (_Storage *StorageTransactor) DeleteUint(opts *bind.TransactOpts, key [32]byte) (*types.Transaction, error) {
	return _Storage.contract.Transact(opts, "deleteUint", key)
}

// DeleteUint is a paid mutator transaction binding the contract method 0xe2b202bf.
//
// Solidity: function deleteUint(bytes32 key) returns()
func (_Storage *StorageSession) DeleteUint(key [32]byte) (*types.Transaction, error) {
	return _Storage.Contract.DeleteUint(&_Storage.TransactOpts, key)
}

// DeleteUint is a paid mutator transaction binding the contract method 0xe2b202bf.
//
// Solidity: function deleteUint(bytes32 key) returns()
func (_Storage *StorageTransactorSession) DeleteUint(key [32]byte) (*types.Transaction, error) {
	return _Storage.Contract.DeleteUint(&_Storage.TransactOpts, key)
}

// SetAddress is a paid mutator transaction binding the contract method 0xca446dd9.
//
// Solidity: function setAddress(bytes32 key, address value) returns()
func (_Storage *StorageTransactor) SetAddress(opts *bind.TransactOpts, key [32]byte, value common.Address) (*types.Transaction, error) {
	return _Storage.contract.Transact(opts, "setAddress", key, value)
}

// SetAddress is a paid mutator transaction binding the contract method 0xca446dd9.
//
// Solidity: function setAddress(bytes32 key, address value) returns()
func (_Storage *StorageSession) SetAddress(key [32]byte, value common.Address) (*types.Transaction, error) {
	return _Storage.Contract.SetAddress(&_Storage.TransactOpts, key, value)
}

// SetAddress is a paid mutator transaction binding the contract method 0xca446dd9.
//
// Solidity: function setAddress(bytes32 key, address value) returns()
func (_Storage *StorageTransactorSession) SetAddress(key [32]byte, value common.Address) (*types.Transaction, error) {
	return _Storage.Contract.SetAddress(&_Storage.TransactOpts, key, value)
}

// SetBool is a paid mutator transaction binding the contract method 0xabfdcced.
//
// Solidity: function setBool(bytes32 key, bool value) returns()
func (_Storage *StorageTransactor) SetBool(opts *bind.TransactOpts, key [32]byte, value bool) (*types.Transaction, error) {
	return _Storage.contract.Transact(opts, "setBool", key, value)
}

// SetBool is a paid mutator transaction binding the contract method 0xabfdcced.
//
// Solidity: function setBool(bytes32 key, bool value) returns()
func (_Storage *StorageSession) SetBool(key [32]byte, value bool) (*types.Transaction, error) {
	return _Storage.Contract.SetBool(&_Storage.TransactOpts, key, value)
}

// SetBool is a paid mutator transaction binding the contract method 0xabfdcced.
//
// Solidity: function setBool(bytes32 key, bool value) returns()
func (_Storage *StorageTransactorSession) SetBool(key [32]byte, value bool) (*types.Transaction, error) {
	return _Storage.Contract.SetBool(&_Storage.TransactOpts, key, value)
}

// SetBytes is a paid mutator transaction binding the contract method 0x2e28d084.
//
// Solidity: function setBytes(bytes32 key, bytes value) returns()
func (_Storage *StorageTransactor) SetBytes(opts *bind.TransactOpts, key [32]byte, value []byte) (*types.Transaction, error) {
	return _Storage.contract.Transact(opts, "setBytes", key, value)
}

// SetBytes is a paid mutator transaction binding the contract method 0x2e28d084.
//
// Solidity: function setBytes(bytes32 key, bytes value) returns()
func (_Storage *StorageSession) SetBytes(key [32]byte, value []byte) (*types.Transaction, error) {
	return _Storage.Contract.SetBytes(&_Storage.TransactOpts, key, value)
}

// SetBytes is a paid mutator transaction binding the contract method 0x2e28d084.
//
// Solidity: function setBytes(bytes32 key, bytes value) returns()
func (_Storage *StorageTransactorSession) SetBytes(key [32]byte, value []byte) (*types.Transaction, error) {
	return _Storage.Contract.SetBytes(&_Storage.TransactOpts, key, value)
}

// SetBytes32 is a paid mutator transaction binding the contract method 0x4e91db08.
//
// Solidity: function setBytes32(bytes32 key, bytes32 value) returns()
func (_Storage *StorageTransactor) SetBytes32(opts *bind.TransactOpts, key [32]byte, value [32]byte) (*types.Transaction, error) {
	return _Storage.contract.Transact(opts, "setBytes32", key, value)
}

// SetBytes32 is a paid mutator transaction binding the contract method 0x4e91db08.
//
// Solidity: function setBytes32(bytes32 key, bytes32 value) returns()
func (_Storage *StorageSession) SetBytes32(key [32]byte, value [32]byte) (*types.Transaction, error) {
	return _Storage.Contract.SetBytes32(&_Storage.TransactOpts, key, value)
}

// SetBytes32 is a paid mutator transaction binding the contract method 0x4e91db08.
//
// Solidity: function setBytes32(bytes32 key, bytes32 value) returns()
func (_Storage *StorageTransactorSession) SetBytes32(key [32]byte, value [32]byte) (*types.Transaction, error) {
	return _Storage.Contract.SetBytes32(&_Storage.TransactOpts, key, value)
}

// SetGuardian is a paid mutator transaction binding the contract method 0x8a0dac4a.
//
// Solidity: function setGuardian(address newAddress) returns()
func (_Storage *StorageTransactor) SetGuardian(opts *bind.TransactOpts, newAddress common.Address) (*types.Transaction, error) {
	return _Storage.contract.Transact(opts, "setGuardian", newAddress)
}

// SetGuardian is a paid mutator transaction binding the contract method 0x8a0dac4a.
//
// Solidity: function setGuardian(address newAddress) returns()
func (_Storage *StorageSession) SetGuardian(newAddress common.Address) (*types.Transaction, error) {
	return _Storage.Contract.SetGuardian(&_Storage.TransactOpts, newAddress)
}

// SetGuardian is a paid mutator transaction binding the contract method 0x8a0dac4a.
//
// Solidity: function setGuardian(address newAddress) returns()
func (_Storage *StorageTransactorSession) SetGuardian(newAddress common.Address) (*types.Transaction, error) {
	return _Storage.Contract.SetGuardian(&_Storage.TransactOpts, newAddress)
}

// SetInt is a paid mutator transaction binding the contract method 0x3e49bed0.
//
// Solidity: function setInt(bytes32 key, int256 value) returns()
func (_Storage *StorageTransactor) SetInt(opts *bind.TransactOpts, key [32]byte, value *big.Int) (*types.Transaction, error) {
	return _Storage.contract.Transact(opts, "setInt", key, value)
}

// SetInt is a paid mutator transaction binding the contract method 0x3e49bed0.
//
// Solidity: function setInt(bytes32 key, int256 value) returns()
func (_Storage *StorageSession) SetInt(key [32]byte, value *big.Int) (*types.Transaction, error) {
	return _Storage.Contract.SetInt(&_Storage.TransactOpts, key, value)
}

// SetInt is a paid mutator transaction binding the contract method 0x3e49bed0.
//
// Solidity: function setInt(bytes32 key, int256 value) returns()
func (_Storage *StorageTransactorSession) SetInt(key [32]byte, value *big.Int) (*types.Transaction, error) {
	return _Storage.Contract.SetInt(&_Storage.TransactOpts, key, value)
}

// SetString is a paid mutator transaction binding the contract method 0x6e899550.
//
// Solidity: function setString(bytes32 key, string value) returns()
func (_Storage *StorageTransactor) SetString(opts *bind.TransactOpts, key [32]byte, value string) (*types.Transaction, error) {
	return _Storage.contract.Transact(opts, "setString", key, value)
}

// SetString is a paid mutator transaction binding the contract method 0x6e899550.
//
// Solidity: function setString(bytes32 key, string value) returns()
func (_Storage *StorageSession) SetString(key [32]byte, value string) (*types.Transaction, error) {
	return _Storage.Contract.SetString(&_Storage.TransactOpts, key, value)
}

// SetString is a paid mutator transaction binding the contract method 0x6e899550.
//
// Solidity: function setString(bytes32 key, string value) returns()
func (_Storage *StorageTransactorSession) SetString(key [32]byte, value string) (*types.Transaction, error) {
	return _Storage.Contract.SetString(&_Storage.TransactOpts, key, value)
}

// SetUint is a paid mutator transaction binding the contract method 0xe2a4853a.
//
// Solidity: function setUint(bytes32 key, uint256 value) returns()
func (_Storage *StorageTransactor) SetUint(opts *bind.TransactOpts, key [32]byte, value *big.Int) (*types.Transaction, error) {
	return _Storage.contract.Transact(opts, "setUint", key, value)
}

// SetUint is a paid mutator transaction binding the contract method 0xe2a4853a.
//
// Solidity: function setUint(bytes32 key, uint256 value) returns()
func (_Storage *StorageSession) SetUint(key [32]byte, value *big.Int) (*types.Transaction, error) {
	return _Storage.Contract.SetUint(&_Storage.TransactOpts, key, value)
}

// SetUint is a paid mutator transaction binding the contract method 0xe2a4853a.
//
// Solidity: function setUint(bytes32 key, uint256 value) returns()
func (_Storage *StorageTransactorSession) SetUint(key [32]byte, value *big.Int) (*types.Transaction, error) {
	return _Storage.Contract.SetUint(&_Storage.TransactOpts, key, value)
}

// SubUint is a paid mutator transaction binding the contract method 0xebb9d8c9.
//
// Solidity: function subUint(bytes32 key, uint256 amount) returns()
func (_Storage *StorageTransactor) SubUint(opts *bind.TransactOpts, key [32]byte, amount *big.Int) (*types.Transaction, error) {
	return _Storage.contract.Transact(opts, "subUint", key, amount)
}

// SubUint is a paid mutator transaction binding the contract method 0xebb9d8c9.
//
// Solidity: function subUint(bytes32 key, uint256 amount) returns()
func (_Storage *StorageSession) SubUint(key [32]byte, amount *big.Int) (*types.Transaction, error) {
	return _Storage.Contract.SubUint(&_Storage.TransactOpts, key, amount)
}

// SubUint is a paid mutator transaction binding the contract method 0xebb9d8c9.
//
// Solidity: function subUint(bytes32 key, uint256 amount) returns()
func (_Storage *StorageTransactorSession) SubUint(key [32]byte, amount *big.Int) (*types.Transaction, error) {
	return _Storage.Contract.SubUint(&_Storage.TransactOpts, key, amount)
}

// StorageGuardianChangedIterator is returned from FilterGuardianChanged and is used to iterate over the raw logs and unpacked data for GuardianChanged events raised by the Storage contract.
type StorageGuardianChangedIterator struct {
	Event *StorageGuardianChanged // Event containing the contract specifics and raw log

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
func (it *StorageGuardianChangedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(StorageGuardianChanged)
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
		it.Event = new(StorageGuardianChanged)
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
func (it *StorageGuardianChangedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *StorageGuardianChangedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// StorageGuardianChanged represents a GuardianChanged event raised by the Storage contract.
type StorageGuardianChanged struct {
	OldGuardian common.Address
	NewGuardian common.Address
	Raw         types.Log // Blockchain specific contextual infos
}

// FilterGuardianChanged is a free log retrieval operation binding the contract event 0xa14fc14d8620a708a896fd11392a235647d99385500a295f0d7da2a258b2e967.
//
// Solidity: event GuardianChanged(address oldGuardian, address newGuardian)
func (_Storage *StorageFilterer) FilterGuardianChanged(opts *bind.FilterOpts) (*StorageGuardianChangedIterator, error) {

	logs, sub, err := _Storage.contract.FilterLogs(opts, "GuardianChanged")
	if err != nil {
		return nil, err
	}
	return &StorageGuardianChangedIterator{contract: _Storage.contract, event: "GuardianChanged", logs: logs, sub: sub}, nil
}

// WatchGuardianChanged is a free log subscription operation binding the contract event 0xa14fc14d8620a708a896fd11392a235647d99385500a295f0d7da2a258b2e967.
//
// Solidity: event GuardianChanged(address oldGuardian, address newGuardian)
func (_Storage *StorageFilterer) WatchGuardianChanged(opts *bind.WatchOpts, sink chan<- *StorageGuardianChanged) (event.Subscription, error) {

	logs, sub, err := _Storage.contract.WatchLogs(opts, "GuardianChanged")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(StorageGuardianChanged)
				if err := _Storage.contract.UnpackLog(event, "GuardianChanged", log); err != nil {
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

// ParseGuardianChanged is a log parse operation binding the contract event 0xa14fc14d8620a708a896fd11392a235647d99385500a295f0d7da2a258b2e967.
//
// Solidity: event GuardianChanged(address oldGuardian, address newGuardian)
func (_Storage *StorageFilterer) ParseGuardianChanged(log types.Log) (*StorageGuardianChanged, error) {
	event := new(StorageGuardianChanged)
	if err := _Storage.contract.UnpackLog(event, "GuardianChanged", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
