require("dotenv").config()

require("@nomiclabs/hardhat-etherscan")
require("@nomiclabs/hardhat-waffle")
require("hardhat-gas-reporter")
require("solidity-coverage")
require("hardhat-deploy")

const RINKEBY_RPC_URL = process.env.RINKEBY_RPC_URL || "key"
const RINKEBY_COMPLETE_B_PRIVATE_KEY =
    process.env.RINKEBY_COMPLETE_B_PRIVATE_KEY !== undefined
        ? [process.env.RINKEBY_COMPLETE_B_PRIVATE_KEY]
        : []
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || "key"
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY || "key"
module.exports = {
    //solidity: "0.8.8",
    solidity: {
        compilers: [{ version: "0.8.8" }, { version: "0.7.0" }],
    },
    defaultNetwork: "hardhat",
    networks: {
        rinkeby: {
            url: RINKEBY_RPC_URL,
            accounts: RINKEBY_COMPLETE_B_PRIVATE_KEY,
            chainId: 4,
            blockConfirmations: 6, //this actually help etherscan to catchup on verification
        },
    },
    gasReporter: {
        enabled: true, //false if we don't wanna work with the gas
        outputFile: "gas-report.txt",
        noColors: true,
        currency: "USD",
        coinmarketcap: COINMARKETCAP_API_KEY, //help us to calculate the price in usd
        token: "ETH", //if token added then we have information for deployment on the given chain with prices in usd
    },
    etherscan: {
        apiKey: ETHERSCAN_API_KEY,
    },
    namedAccounts: {
        deployer: {
            default: 0,
        },
        users: {
            default: 1,
        },
    },
}
