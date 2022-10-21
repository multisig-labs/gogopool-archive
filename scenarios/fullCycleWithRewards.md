### Select hardhat network

```
export HARDHAT_NETWORK=hardhat
export ETH_RPC_URL=http://127.0.0.1:8545
```

### Start a node in a terminal, then set it up with this:

If using ANR skip the node command:

```
just node
```

```
just deploy-base
just deploy
just task debug:list_contracts
just task debug:setup

just task multisig:list

just task debug:topup_actor_balances --amt 10000
just task ggp:deal --recip nodeOp1 --amt 800
just task ggp:deal --recip nodeOp2 --amt 800
just task debug:list_actor_balances
```

```
just task staking:stake_ggp --actor nodeOp1 --amt 300
just task staking:stake_ggp --actor nodeOp2 --amt 300
just task staking:list

just task dao:set_ggavax_reserve --reserve 0
just task ggavax:liqstaker_deposit_avax --actor alice --amt 2000
just task ggavax:liqstaker_deposit_avax --actor bob --amt 3000


just task minipool:create --actor nodeOp1 --node node2 --duration 4m
just task minipool:create --actor nodeOp1 --node node3 --duration 3m
just task minipool:create --actor nodeOp1 --node node4 --duration 2m
just task minipool:create --actor nodeOp2 --node node5 --duration 2m
just task minipool:create --actor nodeOp2 --node node6 --duration 5m

just task ggavax:available_for_staking
```

```
just task minipool:list
just task minipool:list_claimable --actor rialto1
just task minipool:claim --actor rialto1
just task ggavax:available_for_staking
```

---

1. sync rewards
2. skip forward
3. sync rewards
4. make sure total assets are still 0.
5. preview withdraw

```
just task ggavax:sync_rewards --actor rialto1
just task debug:skip --duration 14d
just task ggavax:sync_rewards --actor rialto1
just task ggavax:available_for_staking
just task ggavax:total_assets
just task ggavax:preview_withdraw --amt 2000
```

```
just task minipool:recordStakingStart --actor rialto1 --node node2
just task minipool:recordStakingStart --actor rialto1 --node node3
just task minipool:recordStakingStart --actor rialto1 --node node4
just task minipool:recordStakingStart --actor rialto1 --node node5
just task minipool:recordStakingStart --actor rialto1 --node node6
just task minipool:list
```

```
just task inflation:canCycleStart --actor rialto1
```

```
just task debug:skip --duration 14d
just task inflation:canCycleStart --actor rialto1
just task inflation:startRewardsCycle --actor rialto1
just task nopClaim:distributeRewards
just task staking:list
```

Round two of rewards:

```

just task debug:skip --duration 28d
just task inflation:canCycleStart --actor rialto1
just task inflation:startRewardsCycle --actor rialto1
just task nopClaim:distributeRewards
just task staking:list
just task nopClaim:claimAndRestakeHalf --staker nodeOp1
just task nopClaim:claimAndRestakeHalf --staker nodeOp2
just task staking:list
just task debug:list_actor_balances
```

```
just task minipool:recordStakingEnd --actor rialto1 --node node2 --reward 300 &
just task minipool:recordStakingEnd --actor rialto1 --node node3 --reward 300 &
just task minipool:recordStakingEnd --actor rialto1 --node node4 --reward 300 &
just task minipool:recordStakingEnd --actor rialto1 --node node5 --reward 300 &
just task minipool:recordStakingEnd --actor rialto1 --node node6 --reward 300 &
just task minipool:list

```

```
just task minipool:withdrawMinipoolFunds --actor nodeOp1 --node node2 &
just task minipool:withdrawMinipoolFunds --actor nodeOp1 --node node3 &
just task minipool:withdrawMinipoolFunds --actor nodeOp1 --node node4 &
just task minipool:withdrawMinipoolFunds --actor nodeOp2 --node node5 &
just task minipool:withdrawMinipoolFunds --actor nodeOp2 --node node6 &
```

```
just task debug:list_actor_balances
```

```
just task ggavax:sync_rewards --actor rialto1
just task debug:skip --duration 14d
just task ggavax:sync_rewards --actor rialto1

just task ggavax:preview_withdraw --amt 2000
just task ggavax:preview_withdraw --amt 1000
just task ggavax:total_assets

just task wavax:balance
just task ggavax:balance
```

```
just task ggavax:liqstaker_redeem_ggavax --actor alice --amt 2000 &
just task ggavax:liqstaker_redeem_ggavax --actor bob --amt 3000 &
```

```
just task debug:list_actor_balances
```
