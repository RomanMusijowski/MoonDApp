from scripts.helpful_scripts import get_account, get_contract
from brownie import FarmToTheMoon
from web3 import Web3

STAKE_AMOUNT_1 = Web3.toWei(1, "ether")
STAKE_AMOUNT_2 = Web3.toWei(2, "ether")
STAKE_AMOUNT_4 = Web3.toWei(4, "ether")

def stake_dai():
    account = get_account()
    farm_contract = FarmToTheMoon[-1]
    dai_contract = get_contract("fau_token")
    dai_contract.approve(farm_contract.address, STAKE_AMOUNT_1, {"from": account})
    tx = farm_contract.stake(STAKE_AMOUNT_1, dai_contract.address, {"from": account})
    tx.wait(1)
    print("1 dai were staked.")

def stake_dai2():
    account = get_account(account="from_key2")
    farm_contract = FarmToTheMoon[-1]
    dai_contract = get_contract("fau_token")
    dai_contract.approve(farm_contract.address, STAKE_AMOUNT_2, {"from": account})
    tx = farm_contract.stake(STAKE_AMOUNT_2, dai_contract.address, {"from": account})
    tx.wait(1)
    print("2 dai were staked.")

def stake_dai3():
    account = get_account(account="from_key3")
    farm_contract = FarmToTheMoon[-1]
    dai_contract = get_contract("fau_token")
    dai_contract.approve(farm_contract.address, STAKE_AMOUNT_4, {"from": account})
    tx = farm_contract.stake(STAKE_AMOUNT_4, dai_contract.address, {"from": account})
    tx.wait(1)
    print("4 dai were staked.")

def main():
    stake_dai()
    stake_dai2()
    stake_dai3()