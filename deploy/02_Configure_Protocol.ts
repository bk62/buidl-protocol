import { DeployFunction } from "hardhat-deploy/types"
import { network } from "hardhat"
import {
    networkConfig,
    developmentChains,
    VERIFICATION_BLOCK_CONFIRMATIONS,
} from "../helper-hardhat-config"
import { deployContract, waitForTx, ProtocolState, ZERO_ADDRESS } from "../tasks/helpers/utils";
import {
    BuidlHub__factory,
} from "../typechain";
import { constants } from "ethers";

const deployFunction: DeployFunction = async (hre) => {
    const { getNamedAccounts, deployments } = hre
    const { deploy, log } = deployments

    const { deployer, governance } = await getNamedAccounts()
    const [deployerSigner, governanceSigner] = await hre.ethers.getSigners();
    const chainId: number | undefined = network.config.chainId
    if (!chainId) return

    let linkToken: string | undefined;
    // let mockErc20: string | undefined;
    let poolAddressProvider: string | undefined
    let aLinkToken: string | undefined;

    if (chainId === 1337) {
        linkToken = (await deployments.get("LinkToken")).address;
        // mockErc20 = (await deployments.get("MockERC20")).address;
        poolAddressProvider = (await deployments.get("MockPoolAddressesProvider")).address;
        aLinkToken = (await deployments.get("MockaToken")).address;
    } else {
        linkToken = networkConfig[chainId].aaveLinkToken; // TODO refer to hardhat helper config ts
        poolAddressProvider = networkConfig[chainId].poolAddressesProvider;
        aLinkToken = networkConfig[chainId].aLinkToken;
    }

    const hub = BuidlHub__factory.connect((await deployments.get("BuidlHub")).address, governanceSigner)
    await waitForTx(hub.whitelistERC20(linkToken ?? constants.AddressZero, true));
    await waitForTx(hub.setAavePoolAddressProvider(poolAddressProvider ?? constants.AddressZero));
    // await waitForTx(hub.setAaveaToken(linkToken, aLinkToken));


    const waitBlockConfirmations: number = developmentChains.includes(network.name)
        ? 1
        : VERIFICATION_BLOCK_CONFIRMATIONS

    log(`Finished configuring protocol!`)
    log("----------------------------------------------------")
}

export default deployFunction
deployFunction.tags = [`all`, `feed`, `main`]
