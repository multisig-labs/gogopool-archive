# Task Runner

Scratchpad for easily running hardhat tasks.

In VSCode, set a keyboard shortcut for `workbench.action.terminal.runSelectedText` (I used F2) then put the cursor on the line you want to run and hit the shortcut key.


```sh
# List all tasks with docs
just task
# Help is avail for each task
just task help minipool:create


# Select hardhat node
export HARDHAT_NETWORK=localhost # DO NOT use hardhat
export ETH_RPC_URL=http://localhost:8545
just node

# Select ANR network (custom)
Make sure you have ANR running locally. Instructions can be found in the ANR repo here: https://github.com/multisig-labs/anr
export HARDHAT_NETWORK=custom
export ETH_RPC_URL=http://localhost:8545

# Commands

# TODO Make sure there are examples of every task in this list

just task debug:list_contracts
just task debug:list_vars
just task debug:list_actor_balances
just task debug:topup_actor_balance --actor rialto --amt 10000
just task debug:topup_actor_balance --actor alice --amt 10000
just task debug:topup_actor_balance --actor bob --amt 1000
just task debug:topup_actor_balance --actor nodeOp1 --amt 10000
just task debug:topup_actor_balance --actor rewarder --amt 10000
just task debug:skip --duration 14d
just task mine
just task multisig:list
just task multisig:disable --name rialto1
just task multisig:register --name rialto
just task debug:topup_actor_balance --actor rialto --amt 10000
just task minipool:list
just task minipool:list_claimable --actor rialto
just task minipool:can_claim --node 0xfFea5e64F3818859d75b26050C094e40C4783884 --actor rialto
just task minipool:claim --node NodeID-P7oB2McjBGgW2NXXWVYjV8JEDFoW9xDE5 --actor rialto
just task minipool:calculate_slash --amt 1000
just task minipool:cancel --actor nodeOp1 --node node1
just task minipool:expected_reward --duration 14d --amt 1000
just task minipool:recordStakingStart --actor rialto1 --node node1
just task minipool:recordStakingEnd --actor rialto1 --node node1 --reward 300
just task minipool:withdrawMinipoolFunds --actor nodeOp1 --node node1
just task ggp:deal --recip nodeOp1 --amt 10000
just task ggavax:liqstaker_deposit_avax --actor alice --amt 2000
just task ggavax:liqstaker_redeem_ggavax --actor alice --amt 2000
just task ggavax:sync_rewards --actor rialto1
just task oracle:get_ggp
just task oracle:set_ggp --actor rialto1 --price 2 --timestamp 0
just task oracle:set_ggp --actor rialto1 --price 1 --interval 1d
just task oracle:get_ggp_price_oneinch
just task oracle:set_ggp_price_oneinch --price 1.1
just task vault:list
just task inflation:cycleStatus
```



