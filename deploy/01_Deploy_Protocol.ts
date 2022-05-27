import { DeployFunction } from "hardhat-deploy/types"
import { network } from "hardhat"
import { hexlify, RLP, keccak256 } from "ethers/lib/utils";
import fs from "fs";



import {
    networkConfig,
    developmentChains,
    VERIFICATION_BLOCK_CONFIRMATIONS,
} from "../helper-hardhat-config"
import { verify } from "../helper-functions"

const deployFunction: DeployFunction = async (hre) => {
    const { getNamedAccounts, deployments } = hre

    const { deploy, log } = deployments

    const { deployer, governance } = await getNamedAccounts()

    const chainId: number | undefined = network.config.chainId
    if (!chainId) return

    const waitBlockConfirmations: number = developmentChains.includes(network.name)
        ? 1
        : VERIFICATION_BLOCK_CONFIRMATIONS
    log(`----------------------------------------------------`)

    // Track nonce
    let deployerNonce = await hre.ethers.provider.getTransactionCount(deployer);

    log("Deploying Libs...")
    const buidlingLogic = await deploy("BuidlingLogic", {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: waitBlockConfirmations,
        nonce: deployerNonce++
    })

    const fundingLogic = await deploy("FundingLogic", {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: waitBlockConfirmations,
        nonce: deployerNonce++
    })

    const hubLibs = {
        "BuidlingLogic": buidlingLogic.address,
        "FundingLogic": fundingLogic.address,
    };


    // Pre-computer nonces and addresses used to deploy contracts
    const hubNonce = hexlify(deployerNonce);
    const backNFTNonce = hexlify(deployerNonce + 1);
    const investNFTNonce = hexlify(deployerNonce + 2);
    const ytVaultNonce = hexlify(deployerNonce + 3);

    const backNFTAddress = "0x" + keccak256(RLP.encode([deployer, backNFTNonce])).slice(26);
    const investNFTAddress = "0x" + keccak256(RLP.encode([deployer, investNFTNonce])).slice(26);
    const ytVaultAddress = "0x" + keccak256(RLP.encode([deployer, ytVaultNonce])).slice(26);
    const hubAddress = "0x" + keccak256(RLP.encode([deployer, hubNonce])).slice(26);

    log("Deploying Hub...")

    // Invalid bytecode error for some reason TODO
    const hub = await deploy("BuidlHub", {
        from: deployer,
        libraries: hubLibs,
        args: [
            "BuidlHub",
            "BUIDLIT",
            governance,
            backNFTAddress,
            investNFTAddress,
            ytVaultAddress,
        ],
        nonce: deployerNonce++,
        log: true,
        waitConfirmations: waitBlockConfirmations,
    })

    // const buildHub = await deployContract(
    //     new BuidlHub__factory(hubLibs, deployer).deploy(
    //         "BuidlHub",
    //         "BUIDLIT",
    //         governance,
    //         backNFTAddress,
    //         investNFTAddress,
    //         ytVaultAddress,
    //         {
    //             nonce: deployerNonce++
    //         }
    //     )
    // );

    log("Deploying NFT Implementations...")
    const backNFT = await deploy("BackNFT", {
        from: deployer,
        args: [
            hubAddress,
        ],
        nonce: deployerNonce++,
        log: true,
        waitConfirmations: waitBlockConfirmations,
    })
    const investNFT = await deploy("InvestNFT", {
        from: deployer,
        args: [
            hubAddress,
        ],
        nonce: deployerNonce++,
        log: true,
        waitConfirmations: waitBlockConfirmations,
    })

    log("Deploying YTVault implementation...")
    const ytVault = await deploy("YieldTrustVault", {
        from: deployer,
        args: [
            hubAddress,
        ],
        nonce: deployerNonce++,
        log: true,
        waitConfirmations: waitBlockConfirmations,
    })

    log("Deploying modules...")
    const backerOnlyInvestModule = await deploy("BackerOnlyInvestModule", {
        from: deployer,
        args: [
            hubAddress,
        ],
        log: true,
        waitConfirmations: waitBlockConfirmations
    });

    const backErc20IcoModule = await deploy("BackERC20ICOModule", {
        from: deployer,
        args: [
            hubAddress,
        ],
        log: true,
        waitConfirmations: waitBlockConfirmations
    });

    // const investRandomNftModule = await deploy("InvestRandomNFTModule", {
    //     from: deployer,
    //     args: [
    //         hubAddress,
    //     ],
    //     log: true,
    //     waitConfirmations: waitBlockConfirmations
    // });

    log("Writing addresses to addresses.json for convenience...")
    const addrs = {
        "hub": hub.address,
        backNFTAddress,
        investNFTAddress,
        ytVaultAddress,
        "buidling-logic-lib": buidlingLogic.address,
        "funding-logic-lib": fundingLogic.address,
        "governance": governance,
        backerOnlyInvestModule,
        backErc20IcoModule,
        // investRandomNftModule,
    };
    const json = JSON.stringify(addrs, null, 2);
    fs.writeFileSync("addresses.json", json, "utf-8");


    log("Finished deploying protocol!")
    log("----------------------------------------------------")

}

export default deployFunction
deployFunction.tags = [`all`, `protocol`, `main`]
