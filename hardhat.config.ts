import * as dotenv from "dotenv"

import type { HardhatUserConfig } from "hardhat/config"
import "@nomiclabs/hardhat-waffle"
import "@nomiclabs/hardhat-ethers"
import "@nomiclabs/hardhat-etherscan"
import "@typechain/hardhat"
import "hardhat-deploy"
import "solidity-coverage"
import "hardhat-gas-reporter"
import "hardhat-contract-sizer"
import "@appliedblockchain/chainlink-plugins-fund-link"
import "./tasks"

dotenv.config()

const POLYGON_MUMBAI_RPC_URL = process.env.POLYGON_MUMBAI_RPC_URL || "https://rpc-mumbai.matic.today"
const DEPLOYER_ACCOUNT = process.env.DEPLOYER_ACCOUNT || 0
const GOVERNANCE_ACCOUNT = process.env.GOVERNANCE_ACCOUNT || 1
const SEEDER_ACCOUNT = process.env.SEEDER_ACCOUNT || 2
const PRIVATE_KEY = process.env.PRIVATE_KEY

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337,
    },
    localhost: {
      chainId: 1337,
    },
    mumbai: {
      url: POLYGON_MUMBAI_RPC_URL,
      // TODO only one pvt key
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY, PRIVATE_KEY, PRIVATE_KEY, PRIVATE_KEY] : [],
      saveDeployments: true,
      chainId: 80001
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
      "mumbai": DEPLOYER_ACCOUNT,
    },
    governance: {
      default: 1,
      "mumbai": GOVERNANCE_ACCOUNT,
    },
    seeder: {
      default: 2,
      "mumbai": SEEDER_ACCOUNT,
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.7",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
            details: {
              yul: true,
            },
          },
        }
      },
      {
        version: "0.6.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
            details: {
              yul: true,
            },
          },
        }
      },
      {
        version: "0.4.24",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
            details: {
              yul: true,
            },
          },
        }
      },
    ],
  },
  mocha: {
    timeout: 200000, // 200 seconds max for running tests
  },
  typechain: {
    outDir: "typechain",
    target: "ethers-v5",
  },
}

export default config
