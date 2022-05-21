#!/usr/bin/env bash
set -Eeuo pipefail

# Experiment to see how using foundry for deploys would work

if [ "${BASH_VERSINFO:-0}" -lt 4 ]; then
 echo "script requires bash version >= 4"
 exit 1
fi

# Where are we running from
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

# Regex to grab the deployed contract addr from `forge create`
deployedRE='Deployed to: (0x[0-9a-f]+)'

legacy="--legacy"

# Type signatures for setting Storage values
declare -A typeSig
typeSig[bool]="setBool(bytes32,bool)"
typeSig[address]="setAddress(bytes32,address)"
typeSig[string]="setString(bytes32,string)"
typeSig[uint]="setUint(bytes32,uint256)"

# @params type key value
function setStorageKeyVal() {
	local data=`cast calldata "${typeSig[$1]}" $2 $3`
	cast send $legacy --private-key=$PRIVATE_KEY $storage $data &>/dev/null
}

# Register a contract with a Storage instance
# @params name address
function registerContract() {
	setStorageKeyVal "bool" `$script_dir/hash-key.sh contract.exists $2` true
	setStorageKeyVal "address" `$script_dir/hash-key.sh contract.address $1` $2
	setStorageKeyVal "string" `$script_dir/hash-key.sh contract.name $2` $1
}

# Deploy a contract called [name], located at [path]
# @params path name
function createContract() {
	[[ `forge create $legacy --private-key=$PRIVATE_KEY $1:$2` =~ $deployedRE ]]
	echo ${BASH_REMATCH[1]}
}

# @params "constructorArgs1 constructorArgs2..." contractPath contractName
function createAndRegisterContractWithArgs() {
	[[ `forge create $legacy --private-key=$PRIVATE_KEY --constructor-args $1 -- $2:$3` =~ $deployedRE ]]
	local addr=${BASH_REMATCH[1]}
	registerContract $3 $addr
	echo $addr
}

echo "Deploying Contracts..."

wavax=`createContract contracts/contract/tokens/WAVAX.sol WAVAX`
storage=`createContract contracts/contract/Storage.sol Storage`
vault=`createAndRegisterContractWithArgs $storage contracts/contract/Vault.sol Vault`

ggAVAX=`createAndRegisterContractWithArgs "$storage $wavax" contracts/contract/tokens/TokenggAVAX.sol TokenggAVAX`
multisigManager=`createAndRegisterContractWithArgs $storage contracts/contract/MultisigManager.sol MultisigManager`
minipoolQueue=`createAndRegisterContractWithArgs $storage contracts/contract/MinipoolQueue.sol MinipoolQueue`
GGP=`createAndRegisterContractWithArgs $storage contracts/contract/tokens/TokenGGP.sol TokenGGP`

echo "Complete."

declare -A addrs

addrs["WAVAX"]=$wavax
addrs["Storage"]=$storage
addrs["Vault"]=$vault
addrs["ggAVAX"]=$ggAVAX
addrs["MultisigManager"]=$multisigManager
addrs["MinipoolQueue"]=$minipoolQueue
addrs["GGP"]=$GGP

declare -p addrs
declare -p addrs > "$script_dir/../cache/deployed_addrs"

# function echoAddr() {
# 	local data=`cast calldata "getAddr(string)" $1`
# 	local result=`cast call ${deployment} ${data}`
# 	local addr=`cast --abi-decode "getAddr(string)(address)" ${result}`
# 	echo $1: ${addr}
# }
