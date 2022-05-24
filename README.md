# Moon DApp

Moon DApp is decentralised application used for 
- stakind different coins
- sending rewards (by smart contract owner) to users who staked founds
- unstaking staked coins
- fetching tokens price feed by chain link

The application uses Chainlink oracles for fetching prices for different crypto coins

### Built with:
* [Brownie](https://eth-brownie.readthedocs.io/en/stable/)
* [Solidity](https://docs.soliditylang.org/en/v0.8.14/)


Keywords/techstack:
- brownie (python framework)
- solidity
- smart contracts
- brownie framework
- chainlink oracle
- blockchain
- ERC20 token


### Getting started:
In order to run this project:
1. Create in root folder file .env with values:
```
- WEB3_INFURA_PROJECT_ID - your project PROJECT ID from https://infura.io/
- PRIVATE_KEY - your private key from 1 wallet
- PRIVATE_KEY2 - your private key from 2 wallet
- PRIVATE_KEY3 - your private key from 3 wallet
- ETHERSCAN_TOKEN - your API token
```
2. Make sure your wallets have enough: 
- eth (Ethereum) - faucet https://faucets.chain.link/
- FAU (FaucetToken) - faucet https://erc20faucet.com/

3. In root directory run:
```
- brownie compile - check if code compiles
- brownie run scripts/deploy.py - deploy contract
- brownie run scripts/stake_tokens.py - stake tokens 
- brownie run scripts/send_reward.py - send reward to stakers 
- brownie run scripts/unstake_tokens.py - unstake tokens 
```
