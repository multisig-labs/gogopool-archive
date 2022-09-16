# Full Cycle Fake Rialto

```sh
# From scratch against an empty EVM
just setup-evm

# View state of system
just task debug:list_actor_balances
just task debug:list_vars
just task minipool:list

# Add validator node
export NODE=`just task debug:node_ids --name mynode | jq -r '.nodeID'` # non-existant but valid nodeID
echo $NODE

# Stake GGP
just task staking:stake_ggp --actor nodeOp1 --amt 300
just task staking:info
just task staking:staker_info --actor nodeOp1

# Create Minipool
just task minipool:create --actor nodeOp1 --node $NODE --duration 2m --avax 1000
just task minipool:list_claimable --actor rialto1
just task minipool:claim_one --actor rialto1 --node $NODE
just task minipool:recordStakingStart --actor rialto1 --node $NODE

# If we are running against haardhat we can advance time (wont work on ANR)
just task debug:skip --duration 14d
just task mine

# Finish Minipool
just task minipool:recordStakingEnd --actor rialto1 --node $NODE --reward 300
just task minipool:withdrawMinipoolFunds --actor nodeOp1 --node $NODE

# ggAVAX Rewards cycle
just task ggavax:sync_rewards --actor rialto1
just task debug:skip --duration 14d
just task mine
just task ggavax:sync_rewards --actor rialto1

just task ggavax:liqstaker_redeem_ggavax --actor alice --amt 1000
just task ggavax:liqstaker_redeem_ggavax --actor bob --amt 1000
```
