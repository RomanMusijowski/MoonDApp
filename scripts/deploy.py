from scripts.helpful_scripts import get_account, get_contract
from brownie import MoonFarmToken, FarmToTheMoon, network, config
from web3 import Web3

TOKEN_RESERVE = Web3.toWei(500, "ether")
TOKEN_SUPPLY = Web3.toWei(1000, "ether")

def deploy_token():
    account = get_account()
    token_contract = MoonFarmToken.deploy(
        TOKEN_SUPPLY,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify", False),
    )
    print("deployed gdyg toke")

    farm_contract = deploy_farm(token_contract)

    token_contract.transfer(
        farm_contract.address, TOKEN_SUPPLY - TOKEN_RESERVE, {"from": account}
    )

    return token_contract


def deploy_farm(_token):
    account = get_account()
    farm_contract = FarmToTheMoon.deploy(
        _token.address,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify", False),
    )

    dai_token = get_contract("fau_token")
    weth_token = get_contract("weth_token")
    token_price_feed_addresses = {
        _token: get_contract("dai_usd_price_feed"),
        dai_token: get_contract("dai_usd_price_feed"),
        weth_token: get_contract("eth_usd_price_feed"),
    }

    set_tokens_and_price_feeds(account, farm_contract, token_price_feed_addresses)
    return farm_contract


def set_tokens_and_price_feeds(account, farm, token_price_feed_addresses):
    for token in token_price_feed_addresses:
        tx = farm.addAllovedTokens(token.address, {"from": account})
        tx.wait(1)
        tx = farm.setPriceFeedAddress(
            token.address, token_price_feed_addresses[token], {"from": account}
        )
        tx.wait(1)


def main():
    deploy_token()
