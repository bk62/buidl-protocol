import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { BuidlHub__factory } from "../typechain";
import { ProtocolState, waitForTx, getAddrs } from "./helpers/utils";

task("unpause", "unpauses the protocol").setAction(
    async(taskArgs: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        const [, governance] = await hre.ethers.getSigners();
        const addrs = getAddrs();

        const hub = BuidlHub__factory.connect(addrs["hub"], governance);

        console.log("Initial state", await hub.getState());
        await waitForTx(hub.setState(ProtocolState.Unpaused));
        console.log("Final state", await hub.getState());
    }
)