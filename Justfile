# Justfiles are better Makefiles (Don't @ me)
# Install the `just` command from here https://github.com/casey/just
# or if you have rust: cargo install just
# https://cheatography.com/linux-china/cheat-sheets/justfile/

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

# Compile the project with hardhat
compile:
  npx hardhat compile

# Clean and compile the project
build: clean compile

# Deploy contracts
deploy-local network="localhost":
	npx hardhat run --network {{network}} scripts/deploy-local.ts

# Deploy contracts to network specified in HARDHAT_NETWORK env var
deploy:
	npx hardhat run scripts/deploy-local.ts

# Start a local hardhat EVM node
node:
	npx hardhat node

# Run all tests (hh/forge)
test: test-forge test-hh

# Run forge unit tests
test-forge *FLAGS:
	@# Using date here to give some randomness to tests that use block.timestamp
	forge test -vv --allow-failure --block-timestamp `date '+%s'` {{FLAGS}}

# Run forge unit tests whenever file changes occur
test-forge-watch *FLAGS:
	@# Using date here to give some randomness to tests that use block.timestamp
	forge test -vv --allow-failure --block-timestamp `date '+%s'` {{FLAGS}} --watch contracts test --delay 1

# Run hardhat tests
test-hh:
	npx hardhat test --network hardhat

# Run cast command
# just cast send MultisigManager "registerMultisig(address)" 0xf39f...
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
	THATDIR=$PWD
	mkdir -p $THATDIR/gen
	cd $GOPATH/pkg/mod/github.com/ava-labs/coreth@v0.8.6
	cat $THATDIR/artifacts/contracts/contract/MinipoolManager.sol/MinipoolManager.json | jq '.abi' | go run cmd/abigen/main.go --abi - --pkg minipool_manager --out $THATDIR/gen/_MinipoolManager.go
	cat $THATDIR/artifacts/contracts/contract/Oracle.sol/Oracle.json | jq '.abi' | go run cmd/abigen/main.go --abi - --pkg oracle --out $THATDIR/gen/_Oracle.go
	echo "Complete!"

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

	# check if yarn is installed
	if ! yarn --version > /dev/null 2>&1; then
		echo "yarn is not installed"
		echo "You can install it via npm with 'npm install -g yarn'"
		exit 1
	fi

	if [ ! -e $HOME/.foundry/bin/forge ]; then
		echo "Install forge from https://book.getfoundry.sh/getting-started/installation.html"
		echo "(Make sure it gets installed to $HOME/.foundry/bin not $HOME/.cargo/bin if you want foundryup to work)"
		exit 1
	fi
	echo "forge ok"

# Im a recipie that doesnt show up in the default list
_secret:
	echo "Go Go Gadget Justfile!"
