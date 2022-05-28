import fs from "fs";

import "@nomiclabs/hardhat-ethers";
import { hexlify, RLP, keccak256, AbiCoder } from "ethers/lib/utils";
import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { deployContract, waitForTx, ProtocolState, ZERO_ADDRESS } from "./helpers/utils";

import {
    BackNFT__factory,
    BuidlHub__factory,
    BuidlingLogic__factory,
    FundingLogic__factory,
    InvestNFT__factory,
    MockERC20__factory,
    YieldTrustVault__factory,
    MockERC20,
    MockPool__factory
} from "../typechain";
import { DataTypes } from "../typechain/BuidlHub";
import { BigNumber, utils } from "ethers";


task("seed", "Seed some data").setAction(
    async (taskArgs: TaskArguments, hre: HardhatRuntimeEnvironment): Promise<void> => {
        // TODO Don't use signers in production
        const { deployments } = hre
        const accounts: SignerWithAddress[] = await hre.ethers.getSigners();

        const deployer = accounts[0];
        const governance = accounts[1];

        const buildHub = BuidlHub__factory.connect((await deployments.get("BuidlHub")).address, governance)


        const mockErc20Dep = await deployments.get("MockERC20")
        const mockErc20 = MockERC20__factory.connect(mockErc20Dep.address, governance);

        console.log("whitelist all signers for convenience, and mint them all mock erc20s")
        for (const user of accounts.slice(2)) {
            await waitForTx(buildHub.connect(governance).whitelistProfileCreator(user.address, true));
            await waitForTx(mockErc20.mint(user.address, hre.ethers.utils.parseEther("500")));
        }

        console.log("whitelist and set aToken for mockERC20s")
        // whitelisted in deploy
        // await waitForTx(buildHub.connect(governance).whitelistERC20(mockErc20.address, true));
        await waitForTx(buildHub.connect(governance).setAaveaToken(mockErc20.address,
            (await deployments.get("MockaToken")).address
        ))
        await waitForTx(mockErc20.mint(governance.address, hre.ethers.utils.parseEther("50000")));


        console.log("creating profiles, projects, yield trusts")
        const backModule = (await deployments.get("BackERC20ICOModule")).address
        const investModule = (await deployments.get("BackerOnlyInvestModule")).address

        let profileIx = 0;
        const abiCoder = new AbiCoder();
        for (const user of accounts.slice(2)) {
            // await waitForTx(buildHub.connect(governance).whitelistProfileCreator(user.address, true));

            const backModuleInitData = abiCoder.encode(
                // name, symbol, tokenPriceInUsd 
                ["string", "string", "uint256"],
                [`profile-${profileIx}-bucks`, `P${profileIx}`, utils.parseEther("1")]
            )
            const profileData: DataTypes.CreateProfileDataStruct = {
                to: user.address,
                handle: `profile-${user.address.toLowerCase().slice(0, 10)}`,
                metadataURI: "ipfs://bafyreibfy74drzhxcnguhognxlebqg4hsrbyccddt5xjejr7xdwzobwy4u/metadata.json",
                backModule: backModule,
                backModuleInitData: backModuleInitData,
                // endorsedByModule: ZERO_ADDRESS,
                // endorsedByModuleInitData: ZERO_ADDRESS,
                profileType: 0,
                githubUsername: "patrickalphac"
            };
            const tx = await buildHub.connect(user).createProfile(profileData)
            const rc = await tx.wait();
            // console.log(rc.events.find((e: any) => e.event === "ProfileCreated"))
            profileIx++;

            const ytData: DataTypes.YieldTrustStructStruct = {
                profileId: profileIx,
                currency: mockErc20.address,
                vault: ZERO_ADDRESS
            }
            await waitForTx(buildHub.connect(user).createYieldTrust(ytData));

            // depositing into yield trust vault
            const ytv = (await buildHub.connect(user).getYieldTrust(profileIx, mockErc20.address)).vault;
            await waitForTx(mockErc20.approve(ytv, utils.parseEther("500")));
            await waitForTx(YieldTrustVault__factory.connect(ytv, governance).deposit(utils.parseEther("500"), governance.address));
            // simulate yield
            await waitForTx(MockPool__factory.connect(
                (await deployments.get("MockPool")).address,
                governance
            ).simulateYield(ytv, utils.parseEther("50")))

            const projectData: DataTypes.CreateProjectDataStruct = {
                profileId: profileIx,
                metadataURI: "ipfs://bafyreibfy74drzhxcnguhognxlebqg4hsrbyccddt5xjejr7xdwzobwy4u/metadata.json",
                handle: `project${profileIx}`,
                projectSize: 0,
                projectState: 0,
                projectType: 0,
                investModule: investModule,
                investModuleInitData: ZERO_ADDRESS,
                githubRepoName: "hardhat-nft-fcc"
            };
            await waitForTx(buildHub.connect(user).createProject(projectData));
        }
    }
)