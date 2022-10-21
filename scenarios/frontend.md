This is the flow for testing rewards on the front end.

My goal is to get the contracts into a state that I can see someone eligible for rewards

On the frontend do the following
GGP from faucet
avax from faucet
create a minipool

export NODE=NodeID-5W6Qhki3Uao9Q2QTnwL5uHszFkHAiLZCy

npx hardhat minipool:list

npx hardhat minipool:can_claim --node $NODE --actor rialto1
npx hardhat minipool:list_claimable --actor rialto1
npx hardhat minipool:claim_one --actor rialto1 --node $NODE
npx hardhat minipool:recordStakingStart --actor rialto1 --node $NODE

npx hardhat debug:skip --duration 14d
npx hardhat debug:skip --duration 14d

npx hardhat inflation:canCycleStart --actor rialto1
npx hardhat inflation:startRewardsCycle --actor rialto1

npx hardhat minipool:recordStakingEnd --actor rialto1 --reward 300 --node $NODE
npx hardhat nopClaim:distributeRewards

npx hardhat staking:getGGPRewards --actor cam
npx hardhat vault:depositToken --actor cam --contract NOPClaim --amt 200
