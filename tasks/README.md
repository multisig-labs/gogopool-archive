# Task Runner

Scratchpad for easily running hardhat tasks.

In VSCode, set a keyboard shortcut for `workbench.action.terminal.runSelectedText` (I used F2) then select the line you want to run (clicking the line number selects the whole line) and hit the shortcut key.

### List all tasks with docs

npx hardhat

### Start a node in a terminal (just node), then set it up with this:

just deploy-local
npx hardhat debug:setup

### List system variables

npx hardhat debug:list_contracts
npx hardhat multisig:list
npx hardhat vault:list
npx hardhat minipool:list
npx hardhat minipool:list_claimable --actor rialto1
npx hardhat minipool:queue
npx hardhat minipool:expected_reward --duration 14d --amt 1000
npx hardhat minipool:calculate_slash --amt 1000
npx hardhat debug:list_vars
npx hardhat debug:list_actor_balances
npx hardhat ggp:deal --recip nodeOp1 --amt 1000
npx hardhat oracle:get_ggp
npx hardhat oracle:set_ggp --price 1 --timestamp 0
npx hardhat oracle:set_ggp --price 1 --interval 1d
npx hardhat oracle:get_ggp_price_oneinch

### This is a full cycle

just deploy-local
npx hardhat debug:setup
npx hardhat ggp:deal --recip nodeOp1 --amt 800

npx hardhat debug:list_actor_balances

npx hardhat minipool:create --actor nodeOp1 --node node1 --duration 14d --ggp 200 --avax 1000 &
npx hardhat minipool:create --actor nodeOp1 --node node2 --duration 14d --ggp 200 --avax 1000 &
npx hardhat minipool:create --actor nodeOp1 --node node3 --duration 14d --ggp 200 --avax 1000 &
npx hardhat minipool:create --actor nodeOp1 --node node4 --duration 14d --ggp 200 --avax 1000 &
npx hardhat ggavax:liqstaker_deposit_avax --actor alice --amt 2000 &
npx hardhat ggavax:liqstaker_deposit_avax --actor bob --amt 2000 &

npx hardhat minipool:list_claimable --actor rialto1
npx hardhat minipool:claim --actor rialto1
npx hardhat minipool:list

npx hardhat minipool:recordStakingStart --actor rialto1 --node node1 &
npx hardhat minipool:recordStakingStart --actor rialto1 --node node2 &
npx hardhat minipool:recordStakingStart --actor rialto1 --node node3 &
npx hardhat minipool:recordStakingStart --actor rialto1 --node node4 &
npx hardhat minipool:list

npx hardhat debug:skip --duration 14d
npx hardhat mine

npx hardhat minipool:recordStakingEnd --actor rialto1 --node node1 --reward 0 &
npx hardhat minipool:recordStakingEnd --actor rialto1 --node node2 --reward 300 &
npx hardhat minipool:recordStakingEnd --actor rialto1 --node node3 --reward 300 &
npx hardhat minipool:recordStakingEnd --actor rialto1 --node node4 --reward 300 &
npx hardhat minipool:list

npx hardhat minipool:withdrawMinipoolFunds --actor nodeOp1 --node node1 &
npx hardhat minipool:withdrawMinipoolFunds --actor nodeOp1 --node node2 &
npx hardhat minipool:withdrawMinipoolFunds --actor nodeOp1 --node node3 &
npx hardhat minipool:withdrawMinipoolFunds --actor nodeOp1 --node node4 &

npx hardhat ggavax:sync_rewards --actor rialto1
npx hardhat debug:skip --duration 14d
npx hardhat ggavax:sync_rewards --actor rialto1

npx hardhat ggavax:liqstaker_redeem_ggavax --actor alice --amt 2000 &
npx hardhat ggavax:liqstaker_redeem_ggavax --actor bob --amt 2000 &

npx hardhat debug:list_actor_balances

### Can cancel if it has not been launched yet

npx hardhat minipool:cancel --actor nodeOp1 --node node1

### Deposits/Withdraws from TokenggAVAX

npx hardhat ggavax:liqstaker_deposit_avax --actor alice --amt 2000
npx hardhat ggavax:liqstaker_redeem_ggavax --actor alice --amt 2000

npx hardhat ggavax:liqstaker_deposit_avax --actor bob --amt 2000
npx hardhat ggavax:liqstaker_redeem_ggavax --actor bob --amt 2000

npx hardhat ggavax:sync_rewards --actor rialto1
