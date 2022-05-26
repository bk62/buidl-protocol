import fs from "fs";
import '@nomiclabs/hardhat-ethers';
import { Contract, ContractTransaction } from 'ethers';

export const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

export enum ProtocolState {
    Paused,
    Unpaused,
    BuidlingPaused,
    FundingPaused,
    DAOFactoryPaused,
}

export enum ProfileType {
    // TODO
}

export function getAddrs(): any {
    const json = fs.readFileSync("addresses.json", "utf-8");
    const addrs = JSON.parse(json);
    return addrs;
}

export async function waitForTx(tx: Promise<ContractTransaction>) {
    await (await tx).wait();
}

export async function deployContract(tx: any): Promise<Contract> {
    const result = await tx;
    await result.deployTransaction.wait();
    return result;
}