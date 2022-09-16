# Full Cycle Fake Rialto

```sh
# From scratch against an empty EVM
just setup-evm

# View state of system
just contracts-task debug:list_actor_balances
just contracts-task debug:list_vars
just contracts-task minipool:list

# Add validator node
export NODE=`just contracts-task debug:node_ids --name mynode | jq -r '.nodeID'` # non-existant but valid nodeID
echo $NODE

# Stake GGP
just contracts-task staking:stake_ggp --actor nodeOp1 --amt 300
just contracts-task staking:info
just contracts-task staking:staker_info --actor nodeOp1

# Create Minipool
just contracts-task minipool:create --actor nodeOp1 --node $NODE --duration 2m --avax 1000
just contracts-task minipool:list_claimable --actor rialto1
just contracts-task minipool:claim_one --actor rialto1 --node $NODE
just contracts-task minipool:recordStakingStart --actor rialto1 --node $NODE

# If we are running against haardhat we can advance time (wont work on ANR)
just contracts-task debug:skip --duration 14d
just contracts-task mine

# Finish Minipool
just contracts-task minipool:recordStakingEnd --actor rialto1 --node $NODE --reward 300
just contracts-task minipool:withdrawMinipoolFunds --actor nodeOp1 --node $NODE

# ggAVAX Rewards cycle
just contracts-task ggavax:sync_rewards --actor rialto1
just contracts-task debug:skip --duration 14d
just contracts-task mine
just contracts-task ggavax:sync_rewards --actor rialto1

just contracts-task ggavax:liqstaker_redeem_ggavax --actor alice --amt 1000
just contracts-task ggavax:liqstaker_redeem_ggavax --actor bob --amt 1000
```
