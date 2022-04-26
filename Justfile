# Justfiles are better Makefiles (Don't @ me)
# Install the `just` command from here https://github.com/casey/just
# or if you have rust: cargo install just
# https://cheatography.com/linux-china/cheat-sheets/justfile/

# Autoload a .env if one exists
set dotenv-load

# Print out some help
default:
	@just --list --unsorted

install:
	yarn install

clean:
	npx hardhat clean
	forge clean

compile:
  npx hardhat compile

build: clean compile

# Run all tests
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
	npx hardhat test

# Run solhint linter and output table of results
solhint:
	npx solhint -f table contracts/**/*.sol

# Update the foundry binaries for forge to the nightly version
foundryup:
	foundryup --version nightly

# Allow the Remix ide to connect to your local files
remix:
	remixd -s `pwd` --remix-ide https://remix.ethereum.org

# Generate Go code interface for contracts
gen:
	#!/bin/bash
	THATDIR=$PWD && cd $GOPATH/pkg/mod/github.com/ava-labs/coreth@v0.8.6 && cat $THATDIR/artifacts/contracts/Oracle.sol/Oracle.json | jq '.abi' | go run cmd/abigen/main.go --abi - --pkg oracle --out $THATDIR/gen/_oracle.go
	echo "Complete!"

# TODO Diagnose any obvious setup issues for new folks
doctor:
	#!/usr/bin/env bash
	set -euxo pipefail

	if [ ! -e $HOME/.foundry/bin/forge ]; then
		echo Install forge from https://book.getfoundry.sh/getting-started/installation.html
		echo (Make sure it gets installed to $HOME/.foundry/bin not $HOME/.cargo/bin if you want foundryup to work)
		exit 1
	fi

# Im a recipie that doesnt show up in the default list
_secret:
	echo "Go Go Gadget Justfile!"
