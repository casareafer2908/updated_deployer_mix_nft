from scripts.mint_oneTM_nft import mint2


def deploy10():
    toDeploy = 10
    for n in range(toDeploy):
        print(f"run number {(n + 1)}")
        mint2()
        if n < toDeploy:
            print("done, execute next")
        else:
            print("job finished")


def main():
    deploy10()
