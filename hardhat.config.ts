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

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337,
    },
    localhost: {
      chainId: 1337,
    }
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
      }
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
