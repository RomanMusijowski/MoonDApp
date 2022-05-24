from scripts.helpful_scripts import get_account, get_contract
from brownie import FarmToTheMoon, network, config
from web3 import Web3

STAKE_AMOUNT_1 = Web3.toWei(1, "ether")
STAKE_AMOUNT_2 = Web3.toWei(2, "ether")
STAKE_AMOUNT_4 = Web3.toWei(4, "ether")

def unstake_dai():
    account = get_account()
    farm_contract = FarmToTheMoon[-1]
    dai_contract = get_contract("fau_token")

    dai_contract.approve(farm_contract.address, STAKE_AMOUNT_1, {"from": account})
    tx = farm_contract.unstake(dai_contract.address, {"from": account})
    tx.wait(1)
    print("All of your dai were unstaked 1.")

def unstake_dai2():
    account = get_account(account="from_key2")
    farm_contract = FarmToTheMoon[-1]
    dai_contract = get_contract("fau_token")
    dai_contract.approve(farm_contract.address, STAKE_AMOUNT_2, {"from": account})

    tx = farm_contract.unstake(dai_contract.address, {"from": account})
    tx.wait(1)
    print("All of your dai were unstaked 2.")

def unstake_dai3():
    account = get_account(account="from_key3")
    farm_contract = FarmToTheMoon[-1]
    dai_contract = get_contract("fau_token")
    dai_contract.approve(farm_contract.address, STAKE_AMOUNT_4, {"from": account})

    tx = farm_contract.unstake(dai_contract.address, {"from": account})
    tx.wait(1)
    print("All of your dai were unstaked 4.")

def main():
    unstake_dai()
    unstake_dai2()
    unstake_dai3()
