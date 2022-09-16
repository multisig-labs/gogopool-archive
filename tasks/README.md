# Task Runner

Scratchpad for easily running hardhat tasks.

In VSCode, set a keyboard shortcut for `workbench.action.terminal.runSelectedText` (I used F2) then put the cursor on the line you want to run and hit the shortcut key.


```sh
# List all tasks with docs
just contracts-task
# Help is avail for each task
just contracts-task help minipool:create


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

just contracts-task debug:list_contracts
just contracts-task debug:list_vars
just contracts-task debug:list_actor_balances
just contracts-task debug:topup_actor_balance --actor rialto --amt 10000
just contracts-task debug:topup_actor_balance --actor alice --amt 10000
just contracts-task debug:topup_actor_balance --actor bob --amt 1000
just contracts-task debug:topup_actor_balance --actor nodeOp1 --amt 10000
just contracts-task debug:topup_actor_balance --actor rewarder --amt 10000
just contracts-task debug:skip --duration 14d
just contracts-task mine
just contracts-task multisig:list
just contracts-task multisig:disable --name rialto1
just contracts-task multisig:register --name rialto
just contracts-task debug:topup_actor_balance --actor rialto --amt 10000
just contracts-task minipool:list
just contracts-task minipool:list_claimable --actor rialto
just contracts-task minipool:can_claim --node 0xfFea5e64F3818859d75b26050C094e40C4783884 --actor rialto
just contracts-task minipool:claim --node NodeID-P7oB2McjBGgW2NXXWVYjV8JEDFoW9xDE5 --actor rialto
just contracts-task minipool:calculate_slash --amt 1000
just contracts-task minipool:cancel --actor nodeOp1 --node node1
just contracts-task minipool:expected_reward --duration 14d --amt 1000
just contracts-task minipool:recordStakingStart --actor rialto1 --node node1
just contracts-task minipool:recordStakingEnd --actor rialto1 --node node1 --reward 300
just contracts-task minipool:withdrawMinipoolFunds --actor nodeOp1 --node node1
just contracts-task ggp:deal --recip nodeOp1 --amt 10000
just contracts-task ggavax:liqstaker_deposit_avax --actor alice --amt 2000
just contracts-task ggavax:liqstaker_redeem_ggavax --actor alice --amt 2000
just contracts-task ggavax:sync_rewards --actor rialto1
just contracts-task oracle:get_ggp
just contracts-task oracle:set_ggp --price 2 --timestamp 0
just contracts-task oracle:set_ggp --price 1 --interval 1d
just contracts-task oracle:get_ggp_price_oneinch
just contracts-task oracle:set_ggp_price_oneinch --price 1.1
just contracts-task vault:list
```



