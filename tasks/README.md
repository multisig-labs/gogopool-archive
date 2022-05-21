# Task Runner

Scratchpad for easily running hardhat tasks.

In VSCode, set a keyboard shortcut for `workbench.action.terminal.runSelectedText` (I used F2) then select the line you want to run (clicking the line number selects the whole line) and hit the shortcut key.

just deploy-local

npx hardhat debug:list_contracts

npx hardhat multisig:list
npx hardhat minipool:list
npx hardhat vault:list
npx hardhat minipool:queue

npx hardhat multisig:register --addr $RIALTO1

npx hardhat minipool:create --nodeid $NODEID1 --duration 10000000 --fee 0 --ggp 0 --avax 2000

# Forces status to 1 (skipping the part where we would assign user funds)

npx hardhat minipool:update_status --nodeid $NODEID1 --status 1

npx hardhat minipool:claim --nodeid $NODEID1 --pk $RIALTO1_PRIVATE_KEY
