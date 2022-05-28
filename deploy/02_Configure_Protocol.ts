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
    LinkToken__factory
} from "../typechain";
import { constants, utils } from "ethers";

const deployFunction: DeployFunction = async (hre) => {
    const { getNamedAccounts, deployments } = hre
    const { deploy, log } = deployments

    const { deployer, governance } = await getNamedAccounts()
    const [deployerSigner, governanceSigner] = await hre.ethers.getSigners();
    const chainId: number | undefined = network.config.chainId
    if (!chainId) return

    const waitBlockConfirmations: number = developmentChains.includes(network.name)
        ? 1
        : VERIFICATION_BLOCK_CONFIRMATIONS




    let linkToken: string | undefined;
    let mockErc20: string | undefined;
    let poolAddressProvider: string | undefined
    let aLinkToken: string | undefined;

    if (chainId === 1337) {
        linkToken = (await deployments.get("LinkToken")).address;
        mockErc20 = (await deployments.get("MockERC20")).address;
        poolAddressProvider = (await deployments.get("MockPoolAddressesProvider")).address;
        aLinkToken = (await deployments.get("MockaToken")).address;
    } else {
        linkToken = networkConfig[chainId].linkToken; // TODO refer to hardhat helper config ts
        poolAddressProvider = networkConfig[chainId].poolAddressesProvider;
        aLinkToken = networkConfig[chainId].aLinkToken;
    }

    const hub = BuidlHub__factory.connect((await deployments.get("BuidlHub")).address, governanceSigner)
    await waitForTx(hub.whitelistERC20(linkToken ?? constants.AddressZero, true));
    await waitForTx(hub.setAavePoolAddressProvider(poolAddressProvider ?? constants.AddressZero));
    // await waitForTx(hub.setAaveaToken(linkToken, aLinkToken));

    log("Setting price feed addresses for native currency and whitelisted currencies:")
    if (chainId === 1337) {
        const mockPF = (await deployments.get("MockV3Aggregator")).address;
        await waitForTx(hub.whitelistERC20(mockErc20 ?? constants.AddressZero, true));
        await waitForTx(hub.setPriceFeed(linkToken ?? constants.AddressZero, mockPF));
        await waitForTx(hub.setPriceFeed(mockErc20 ?? constants.AddressZero, mockPF));
        // native
        await waitForTx(hub.setPriceFeed(constants.AddressZero, mockPF));
    } else {
        await waitForTx(hub.setPriceFeed(linkToken ?? constants.AddressZero, networkConfig[chainId].priceFeeds?.linkUsdPriceFeed || constants.AddressZero));
        // native
        await waitForTx(hub.setPriceFeed(constants.AddressZero, networkConfig[chainId].priceFeeds?.maticUsdPriceFeed || constants.AddressZero));
    }
    // whitelist link

    let linkFundAmount;
    if (chainId === 1337) {
        linkFundAmount = "200";
    } else {
        linkFundAmount = "1";
    }

    const linkTokenContract = LinkToken__factory.connect(linkToken ?? constants.AddressZero, deployerSigner);
    const backModule = await deployments.get("BackERC20ICOModule")
    log("Funding BackERC20ICOModule with link");
    log("Deployer link balance is: " + utils.formatEther(await linkTokenContract.balanceOf(deployerSigner.address)));
    // let tx = await linkTokenContract.increaseApproval(linkTokenContract.address, utils.parseEther(linkFundAmount))
    // log("Approved amount " + linkFundAmount);
    // await tx.wait(1);
    // log("Allowance is: " + utils.formatEther(await linkTokenContract.allowance(deployerSigner.address, linkTokenContract.address)));

    log("Transferring");
    let tx = await linkTokenContract.transfer(
        // deployerSigner.address,
        backModule.address,
        utils.parseEther(linkFundAmount)
    );
    await tx.wait(1);

    log("Contract link balance is: " + utils.formatEther(await linkTokenContract.balanceOf(backModule.address)));




    // log("Funding InvestERC20ICOModule with link");

    log(`Whitelisting modules`)
    const investModule = await deployments.get("BackerOnlyInvestModule")

    tx = await hub.connect(governanceSigner).whitelistBackModule(backModule.address, true);
    await tx.wait()
    tx = await hub.connect(governanceSigner).whitelistInvestModule(investModule.address, true);
    await tx.wait()

    log(`Finished configuring protocol!`)
    log("----------------------------------------------------")
}

export default deployFunction
deployFunction.tags = [`all`, `feed`, `main`]
