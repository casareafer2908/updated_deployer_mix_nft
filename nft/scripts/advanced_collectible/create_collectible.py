#!/usr/bin/python3
from brownie import AdvancedCollectible, accounts, config
from scripts.helpful_scripts import get_style, fund_with_link, listen_for_event
import time


def main():
    dev = accounts.add(config["wallets"]["from_key"])
    # get the latest of the contract to work with
    advanced_collectible = AdvancedCollectible[len(AdvancedCollectible) - 1]
    fund_with_link(advanced_collectible.address)
    # creates collectible with uri set as "none"
    transaction = advanced_collectible.createCollectible({"from": dev})
    print("Waiting on second transaction...")
    # wait for the 2nd transaction
    transaction.wait(1)
    # time.sleep(35)
    listen_for_event(
        advanced_collectible, "ReturnedCollectible", timeout=200, poll_interval=10
    )
    # gets the request id pushed in the "emit" statement
    requestId = transaction.events["RequestedCollectible"]["requestId"]
    # gets the token id from the map {requestid <==> tokenid} saved in the contract
    token_id = advanced_collectible.requestIdToTokenId(requestId)
    # reads the style from the map {tokenid <==> style}
    style = get_style(advanced_collectible.tokenIdToStyle(token_id))
    # prints it
    print("Style of tokenId {} is {}".format(token_id, style))
