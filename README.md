# GoGoGadget GoGoPool!

## First time setup

```
yarn
brew install just
curl -L https://foundry.paradigm.xyz | bash
foundryup
forge install
just build
just test
```

## Justfile

Most commands used in the project are in the `Justfile`. To get a list of whats available type `just`

## Hardhat Deploy

A deploy script `scripts/deploy-local.ts` can be used to deploy and register all of the GoGo contracts.

`just deploy-local`

## Hardhat Tasks

The `tasks` directory is automatically loaded, and all defined tasks can be run from the command line.

`npx hardhat` will show you all the available tasks with a description

`npx hardhat <taskname> <args>`
