# TODO

Review this stuff and turn into scenario files?

### Simple full test with two deposits and staking rewards

```
just deploy-base
just deploy
npx hardhat debug:list_contracts
npx hardhat debug:setup

npx hardhat multisig:list

npx hardhat debug:list_actor_balances
```

```
npx hardhat staking:get_ggp --actor nodeOp1 --amt 300 &
npx hardhat staking:stake_ggp --actor nodeOp1 --ggp 300 &

npx hardhat dao:set_ggavax_reserve --reserve 0 &
npx hardhat ggavax:liqstaker_deposit_avax --actor alice --amt 2000 &
npx hardhat ggavax:liqstaker_deposit_avax --actor bob --amt 1000 &


npx hardhat minipool:create --actor nodeOp1 --node node2 --duration 4m &
npx hardhat minipool:create --actor nodeOp1 --node node3 --duration 3m &
npx hardhat minipool:create --actor nodeOp1 --node node4 --duration 2m &
npx hardhat ggavax:available_for_staking
```

```
npx hardhat minipool:list
npx hardhat minipool:list_claimable --actor rialto1
npx hardhat minipool:claim --actor rialto1
npx hardhat ggavax:available_for_staking
```

---

1. sync rewards
2. skip forward
3. sync rewards
4. make sure total assets are still 0.
5. preview withdraw

```
npx hardhat ggavax:sync_rewards --actor rialto1
npx hardhat debug:skip --duration 14d
npx hardhat ggavax:sync_rewards --actor rialto1
npx hardhat ggavax:available_for_staking
npx hardhat ggavax:total_assets
npx hardhat ggavax:preview_withdraw --amt 2000
```

```
npx hardhat minipool:recordStakingStart --actor rialto1 --node node2 &
npx hardhat minipool:recordStakingStart --actor rialto1 --node node3 &
npx hardhat minipool:recordStakingStart --actor rialto1 --node node4 &
npx hardhat minipool:list
```

```
npx hardhat debug:skip --duration 14d
```

```
npx hardhat minipool:recordStakingEnd --actor rialto1 --node node2 --reward 300 &
npx hardhat minipool:recordStakingEnd --actor rialto1 --node node3 --reward 300 &
npx hardhat minipool:recordStakingEnd --actor rialto1 --node node4 --reward 300 &
npx hardhat minipool:list

```

```
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

npx hardhat ggavax:preview_withdraw --amt 2000
npx hardhat ggavax:preview_withdraw --amt 1000
npx hardhat ggavax:total_assets

npx hardhat wavax:balance
npx hardhat ggavax:balance
```

```
npx hardhat ggavax:liqstaker_redeem_ggavax --actor alice --amt 2000 &
npx hardhat ggavax:liqstaker_redeem_ggavax --actor bob --amt 1000 &
```

```
npx hardhat debug:list_actor_balances
```
