import { BigNumber } from "ethers"

type NetworkConfigItem = {
  name: string
  fundAmount: BigNumber
  fee?: string
  keyHash?: string
  interval?: string
  linkToken?: string
  vrfCoordinator?: string
  keepersUpdateInterval?: string
  oracle?: string
  jobId?: string
  ethUsdPriceFeed?: string

  // TODO
  // TESTNET ONLY
  // using Aave's Mintable Testnet for convenience
  //  for depositing into an Aave pool 
  aaveLinkToken?: string,

  aLinkToken?: string
  poolAddressesProvider?: string
  priceFeeds?: {
    linkUsdPriceFeed?: string,
    maticUsdPriceFeed?: string
  }
}

type NetworkConfigMap = {
  [chainId: string]: NetworkConfigItem
}

export const networkConfig: NetworkConfigMap = {
  default: {
    name: "hardhat",
    fee: "100000000000000000",
    keyHash: "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
    jobId: "29fa9aa13bf1468788b7cc4a500a45b8",
    fundAmount: BigNumber.from("1000000000000000000"),
    keepersUpdateInterval: "30",
  },
  1337: {
    name: "localhost",
    fee: "100000000000000000",
    keyHash: "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
    jobId: "29fa9aa13bf1468788b7cc4a500a45b8",
    fundAmount: BigNumber.from("1000000000000000000"),
    keepersUpdateInterval: "30",
    ethUsdPriceFeed: "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419",
  },
  80001: {
    name: "mumbai",
    linkToken: "0xa36085F69e2889c224210F603D836748e7dC0088",
    ethUsdPriceFeed: "0x9326BFA02ADD2366b30bacB125260Af641031331",
    oracle: "0xc57b33452b4f7bb189bb5afae9cc4aba1f7a4fd8",
    jobId: "d5270d1c311941d0b08bead21fea7747",
    fee: "100000000000000000",
    fundAmount: BigNumber.from("1000000000000000000"),
    keepersUpdateInterval: "30",

    // using Aave's Mintable Testnet for convenience
    //  for depositing into an Aave pool 
    aaveLinkToken: "0xD9E7e5dd6e122dDE11244e14A60f38AbA93097f2",
    aLinkToken: "0x3e1608F4Db4b37DDf86536ef441890fE3AA9F2Ea",
    poolAddressesProvider: "0x5343b5bA672Ae99d627A1C87866b8E53F47Db2E6",
    priceFeeds: {
      linkUsdPriceFeed: "0xd9FFdb71EbE7496cC440152d43986Aae0AB76665",
      maticUsdPriceFeed: "0xAB594600376Ec9fD91F8e885dADF0CE036862dE0"
    }

  }
}

export const developmentChains: string[] = ["hardhat", "localhost"]
export const VERIFICATION_BLOCK_CONFIRMATIONS = 6
