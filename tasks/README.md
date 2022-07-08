# Task Runner

Scratchpad for easily running hardhat tasks.

In VSCode, set a keyboard shortcut for `workbench.action.terminal.runSelectedText` (I used F2) then put the cursor on the line you want to run and hit the shortcut key.

### List all tasks with docs

```
npx hardhat
```

### Select hardhat network

```
export HARDHAT_NETWORK=hardhat
export ETH_RPC_URL=http://127.0.0.1:8545
```

### Select anr network (custom)

Make sure you have ANR running locally. Instructions can be found in the ANR repo here: https://github.com/multisig-labs/anr

```
export HARDHAT_NETWORK=custom
export ETH_RPC_URL=`curl --silent -X POST -k http://localhost:8081/v1/control/uris -d '' | jq -j '.uris | .[0]'`
export RIALTO=`curl --silent -X GET -k https://127.0.0.1:7400/info -H "Authorization: Bearer sekret" | jq -j '.CChainAddr'`
```

### Start a node in a terminal, then set it up with this:

If using ANR skip the node command:

```
just node
```

```
just deploy-base
just deploy
npx hardhat debug:setup
```

### Commands

```
npx hardhat debug:list_contracts
npx hardhat debug:list_vars
npx hardhat debug:list_actor_balances
npx hardhat debug:topup_actor_balance --actor rialto --amt 10000
npx hardhat debug:topup_actor_balance --actor alice --amt 10000
npx hardhat debug:topup_actor_balance --actor bob --amt 1000
npx hardhat debug:topup_actor_balance --actor nodeOp1 --amt 10000
npx hardhat debug:topup_actor_balance --actor rewarder --amt 10000
npx hardhat debug:skip --duration 14d
npx hardhat mine
```

```
npx hardhat multisig:list
npx hardhat multisig:disable --addr 0x78A23300E04FB5d5D2820E23cc679738982e1fd5
npx hardhat multisig:register --addr 0xB654A60A22b9c307B4a0B8C200CdB75A78c4187c
npx hardhat debug:topup_actor_balance --actor rialto --amt 10000 &

```
npx hardhat minipool:list
npx hardhat minipool:list_claimable --actor rialto
npx hardhat minipool:can_claim --nodeaddr 0xfFea5e64F3818859d75b26050C094e40C4783884 --actor rialto
npx hardhat minipool:claim --nodeaddr 0xfFea5e64F3818859d75b26050C094e40C4783884 --actor rialto
npx hardhat minipool:calculate_slash --amt 1000
npx hardhat minipool:cancel --actor nodeOp1 --node node1
npx hardhat minipool:expected_reward --duration 14d --amt 1000
npx hardhat minipool:recordStakingStart --actor rialto1 --node node1
npx hardhat minipool:recordStakingEnd --actor rialto1 --node node1 --reward 300
npx hardhat minipool:withdrawMinipoolFunds --actor nodeOp1 --node node1
npx hardhat ggp:deal --recip nodeOp1 --amt 10000
npx hardhat ggavax:liqstaker_deposit_avax --actor alice --amt 2000
npx hardhat ggavax:liqstaker_redeem_ggavax --actor alice --amt 2000
npx hardhat ggavax:sync_rewards --actor rialto1
npx hardhat oracle:get_ggp
npx hardhat oracle:set_ggp --price 2 --timestamp 0
npx hardhat oracle:set_ggp --price 1 --interval 1d
npx hardhat oracle:get_ggp_price_oneinch
npx hardhat oracle:set_ggp_price_oneinch --price 1.1
npx hardhat vault:list
```

### This is a full cycle

export HARDHAT_NETWORK=custom
export ETH_RPC_URL=`curl --silent -X POST -k http://localhost:8081/v1/control/uris -d '' | jq -j '.uris | .[0]'`

```
just deploy-base
just deploy
npx hardhat debug:list_contracts
npx hardhat debug:setup

npx hardhat multisig:list
npx hardhat multisig:disable --addr 0x78A23300E04FB5d5D2820E23cc679738982e1fd5
npx hardhat multisig:register --addr 0xB654A60A22b9c307B4a0B8C200CdB75A78c4187c
npx hardhat debug:topup_actor_balance --actor rialto --amt 10000 &

```
npx hardhat debug:topup_actor_balance --actor alice --amt 10000 &
npx hardhat debug:topup_actor_balance --actor bob --amt 10000 &
npx hardhat debug:topup_actor_balance --actor cam --amt 10000 &
npx hardhat debug:topup_actor_balance --actor nodeOp1 --amt 10000 &
npx hardhat debug:topup_actor_balance --actor nodeOp2 --amt 10000 &
npx hardhat debug:topup_actor_balance --actor rialto1 --amt 10000 &
npx hardhat debug:topup_actor_balance --actor rialto2 --amt 10000 &
npx hardhat debug:topup_actor_balance --actor rewarder --amt 10000 &
npx hardhat ggp:deal --recip nodeOp1 --amt 800 &
```

```
npx hardhat debug:list_actor_balances
```

```
npx hardhat minipool:create --actor nodeOp1 --node NodeID-P7oB2McjBGgW2NXXWVYjV8JEDFoW9xDE5 --duration 5m --ggp 200 --avax 1000 &
npx hardhat minipool:create --actor nodeOp1 --node node2 --duration 4m --ggp 200 --avax 1000 &
npx hardhat minipool:create --actor nodeOp1 --node node3 --duration 3m --ggp 200 --avax 1000 &
npx hardhat minipool:create --actor nodeOp1 --node node4 --duration 2m --ggp 200 --avax 1000 &
npx hardhat ggavax:liqstaker_deposit_avax --actor alice --amt 2000 &
npx hardhat ggavax:liqstaker_deposit_avax --actor bob --amt 2000 &
```

```
npx hardhat minipool:list
npx hardhat minipool:list_claimable --actor rialto1
npx hardhat minipool:claim --actor rialto1
```

```
npx hardhat minipool:recordStakingStart --actor rialto1 --node node1 &
npx hardhat minipool:recordStakingStart --actor rialto1 --node node2 &
npx hardhat minipool:recordStakingStart --actor rialto1 --node node3 &
npx hardhat minipool:recordStakingStart --actor rialto1 --node node4 &
npx hardhat minipool:list
```

```
npx hardhat debug:skip --duration 14d
npx hardhat mine
```

```
npx hardhat minipool:recordStakingEnd --actor rialto1 --node node1 --reward 0 &
npx hardhat minipool:recordStakingEnd --actor rialto1 --node node2 --reward 300 &
npx hardhat minipool:recordStakingEnd --actor rialto1 --node node3 --reward 300 &
npx hardhat minipool:recordStakingEnd --actor rialto1 --node node4 --reward 300 &
npx hardhat minipool:list
```

```
npx hardhat minipool:withdrawMinipoolFunds --actor nodeOp1 --node node1 &
npx hardhat minipool:withdrawMinipoolFunds --actor nodeOp1 --node node2 &
npx hardhat minipool:withdrawMinipoolFunds --actor nodeOp1 --node node3 &
npx hardhat minipool:withdrawMinipoolFunds --actor nodeOp1 --node node4 &
```

```
npx hardhat debug:list_actor_balances
```

```
npx hardhat ggavax:sync_rewards --actor rialto1
npx hardhat debug:skip --duration 14d
npx hardhat ggavax:sync_rewards --actor rialto1
```

```
npx hardhat ggavax:liqstaker_redeem_ggavax --actor alice --amt 2000 &
npx hardhat ggavax:liqstaker_redeem_ggavax --actor bob --amt 2000 &
```

```
npx hardhat debug:list_actor_balances
```
