# Justfiles are better Makefiles (Don't @ me)
# Install the `just` command from here https://github.com/casey/just
# or if you have rust: cargo install just
# https://cheatography.com/linux-china/cheat-sheets/justfile/

export HARDHAT_NETWORK := env_var_or_default("HARDHAT_NETWORK", "localhost")
export ETH_RPC_URL := env_var_or_default("ETH_RPC_URL", "http://127.0.0.1:8545")

# Autoload a .env if one exists
set dotenv-load

# Print out some help
default:
	@just --list --unsorted

# Install dependencies
install:
	yarn install

# Delete compilation artifacts
clean:
	npx hardhat clean
	forge clean
	rm -rf .openzeppelin

# Compile the project with hardhat
compile:
  npx hardhat compile

# Clean and compile the project
build: clean compile

# Deploy base contracts to HARDHAT_NETWORK
deploy-base: (_ping ETH_RPC_URL)
	npx hardhat run --network {{HARDHAT_NETWORK}} scripts/deploy-base.ts

# Deploy non-base contracts to HARDHAT_NETWORK
deploy contracts="": (_ping ETH_RPC_URL)
	DEPLOY_CONTRACTS="{{contracts}}" npx hardhat run --network {{HARDHAT_NETWORK}} scripts/deploy.ts

# HARDHAT_NETWORK should be "localhost" for tasks, but must be "hardhat" when starting the node
# Start a local hardhat EVM node
node:
	HARDHAT_NETWORK=hardhat npx hardhat node

# Run all tests (hh/forge)
test: test-forge test-hh

# Run forge unit tests
test-forge contract="." test="." *flags="":
	@# Using date here to give some randomness to tests that use block.timestamp
	forge test --allow-failure --block-timestamp `date '+%s'` --match-contract {{contract}} --match-test {{test}} {{flags}}

# Run forge unit tests whenever file changes occur
test-forge-watch contract="." test="." *flags="":
	@# Using date here to give some randomness to tests that use block.timestamp
	forge test --allow-failure --block-timestamp `date '+%s'` --match-contract {{contract}} --match-test {{test}} {{flags}} --watch contracts test --watch-delay 1

# Run hardhat tests
test-hh:
	npx hardhat test --network hardhat

# Deploy contracts and init actors to a fresh EVM
setup-evm:
	just clean
	just deploy-base
	just deploy
	just task debug:setup
	just task debug:topup_actor_balances --amt 20000
	@sleep 2
	just task ggp:deal --recip nodeOp1 --amt 10000
	just task ggavax:liqstaker_deposit_avax --actor alice --amt 10000
	just task ggavax:liqstaker_deposit_avax --actor bob --amt 10000

# Having these recipies named the same as the ones in the anr repo makes copypasta of scenarios easier
# Run a hardhat task (or list all available tasks)
task *cmd:
	npx hardhat {{cmd}}

# just cast send MultisigManager "registerMultisig(address)" 0xf39f...
# Run cast command
cast cmd contractName sig *args:
	#!/usr/bin/env bash
	source -- "cache/deployed_addrs_${HARDHAT_NETWORK:-localhost}.bash"
	if ([ "{{cmd}}" == "send" ]); then legacy="--legacy"; else legacy=""; fi;
	cast {{cmd}} ${legacy} --private-key $PRIVATE_KEY ${addrs[{{contractName}}]} "{{sig}}" {{args}}

# Run solhint linter and output table of results
solhint:
	npx solhint -f table contracts/**/*.sol

# Allow the Remix ide to connect to your local files
remix:
	remixd -s `pwd` --remix-ide https://remix.ethereum.org

# Generate Go code interface for contracts
gen:
	#!/bin/bash
	CORETH=0.8.16
	echo "Generating GO code with Coreth v${CORETH}"
	THATDIR=$PWD
	mkdir -p $THATDIR/gen
	cd $GOPATH/pkg/mod/github.com/ava-labs/coreth@v${CORETH}
	cat $THATDIR/artifacts/contracts/contract/MinipoolManager.sol/MinipoolManager.json | jq '.abi' | go run cmd/abigen/main.go --abi - --pkg minipool_manager --out $THATDIR/gen/minipool_manager.go
	cat $THATDIR/artifacts/contracts/contract/Oracle.sol/Oracle.json | jq '.abi' | go run cmd/abigen/main.go --abi - --pkg oracle --out $THATDIR/gen/oracle.go
	cat $THATDIR/artifacts/contracts/contract/Storage.sol/Storage.json | jq '.abi' | go run cmd/abigen/main.go --abi - --pkg storage --out $THATDIR/gen/storage.go
	echo "Complete! Copying to rialto repo..."
	cp $THATDIR/gen/minipool_manager.go $THATDIR/../rialto/pkg/contracts/minipool_manager
	cp $THATDIR/gen/oracle.go $THATDIR/../rialto/pkg/contracts/oracle
	cp $THATDIR/gen/storage.go $THATDIR/../rialto/pkg/contracts/storage

# Update foundry binaries to the nightly version
update-foundry:
	foundryup --version nightly

# Update git submodules
update-submodules:
	git submodule update --recursive --remote

# Diagnose any obvious setup issues for new folks
doctor:
	#!/usr/bin/env bash
	set -euo pipefail

	# check if yarn is installed
	if ! yarn --version > /dev/null 2>&1; then
		echo "yarn is not installed"
		echo "You can install it via npm with 'npm install -g yarn'"
		exit 1
	fi
	echo "yarn ok"

	if [ ! -e $HOME/.foundry/bin/forge ]; then
		echo "Install forge from https://book.getfoundry.sh/getting-started/installation.html"
		echo "(Make sure it gets installed to $HOME/.foundry/bin not $HOME/.cargo/bin if you want foundryup to work)"
		exit 1
	fi
	echo "forge ok"

# Im a recipie that doesnt show up in the default list
# Check if there is an http(s) server lisening on [url]
_ping url:
	@if ! curl -k --silent --connect-timeout 2 {{url}} >/dev/null 2>&1; then echo 'No server at {{url}}!' && exit 1; fi
