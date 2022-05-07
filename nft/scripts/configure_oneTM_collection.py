#!/usr/bin/python3
from brownie import OneTMShowOff, accounts, network, config

metadataLibrary = config["networks"][network.show_active()]["metadata_library"]
collectionVault = config["networks"][network.show_active()]["collection_vault"]


def main():
    dev = accounts.add(config["wallets"]["from_key"])
    print(network.show_active())
    # Get the latest deployed contract
    one_tm_show_off = OneTMShowOff[len(OneTMShowOff) - 1]

    one_tm_show_off.setGallery(metadataLibrary)
    # address to deposit all the sales' eth
    one_tm_show_off.setVault(collectionVault)

    ##set merkle root

    ##set presale merkle root

    ##set claim merkle root

    return one_tm_show_off
