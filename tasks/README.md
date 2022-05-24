# Task Runner

Scratchpad for easily running hardhat tasks.

In VSCode, set a keyboard shortcut for `workbench.action.terminal.runSelectedText` (I used F2) then select the line you want to run (clicking the line number selects the whole line) and hit the shortcut key.

### Start a node in a terminal (just node), then set it up with this:

just deploy-local
npx hardhat multisig:register --name rialto

### List system variables

npx hardhat debug:list_contracts
npx hardhat multisig:list
npx hardhat vault:list
npx hardhat minipool:list
npx hardhat minipool:queue
npx hardhat debug:list_vars
npx hardhat debug:list_actor_balances

### This is a full cycle

npx hardhat minipool:create --actor nodeOp1 --node node1 --duration 10000000 --fee 0 --ggp 0 --avax 2000
npx hardhat minipool:update_status --actor nodeOp1 --node node1 --status 1
npx hardhat minipool:claim --actor rialto --node node1
npx hardhat minipool:update_status --actor nodeOp1 --node node1 --status 2
npx hardhat minipool:recordStakingStart --actor rialto --node node1 --start 1234
npx hardhat minipool:recordStakingEnd --actor rialto --node node1 --end 1235 --avax 2000 --reward 333
npx hardhat minipool:withdrawMinipoolFunds --actor nodeOp1 --node node1

### Can cancel if it has not been launched yet

npx hardhat minipool:cancel --actor nodeOp1 --node node1

### Deposits/Withdraws from TokenggAVAX

npx hardhat debug:liqstaker_deposit_avax --actor alice --amt 2000
npx hardhat debug:liqstaker_withdraw_avax --actor alice --amt 2000

npx hardhat debug:liqstaker_deposit_avax --actor bob --amt 2000
npx hardhat debug:liqstaker_withdraw_avax --actor bob --amt 2000
