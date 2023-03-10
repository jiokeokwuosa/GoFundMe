import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config";
import "@nomiclabs/hardhat-etherscan";
import "hardhat-gas-reporter";
import "solidity-coverage"
import "@typechain/hardhat"
import "hardhat-deploy"
import "@nomiclabs/hardhat-ethers"

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.8",
      },
      {
        version: "0.6.6",
      },
    ],
  },
  defaultNetwork:"hardhat",
  networks:{
    goerli:{
      url:process.env.GOERLI_RPC_URL,
      accounts:[process.env.PRIVATE_KEY!],
      chainId:5      
    },
    localhost:{
      url: 'http://127.0.0.1:8545/',  
      /* you get the url abv when you run "yarn hardhat node" it comes with several address
       and private key, you don't need to specify accounts. The terminal needs to be active
        before you use localhost  to deploy, the terminal will be showing logs as you work */
      chainId:31337
    }
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: process.env.ETHERSCAN_API_KEY
  },
  gasReporter:{
    enabled:true,
    outputFile:'gas-report.txt',
    noColors:true,
    currency:'USD',
    // coinmarketcap:process.env.COINMARKERCAP_API
  },
  namedAccounts: {
    deployer: {
        default: 0, // here this will by default take the first account as deployer
        1: 0, // similarly on mainnet it will take the first account as deployer.
        5: 0, // on goerli it will take first account
    },
},
};

export default config;
