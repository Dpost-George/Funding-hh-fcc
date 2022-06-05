const {
    networkConfig,
    developmentChains,
} = require("../helper-hardhat-config.js")
const { network } = require("hardhat")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log, get } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    //what happens when we want to change chains?
    //when going for localhost or hardhat network we want to use a mock

    //const ethUsdPriceFeedAddress = networkConfig[chainId].ethUsdPriceFeed
    let ethUsdPriceFeedAddress
    //if we are on a development chain:we want to get the recently(already deployed MockV3Aggregator and use it  )
    if (developmentChains.includes(network.name)) {
        const ethUsdAggregator = await get("MockV3Aggregator") //get(destructuring deployments)
        //getting the address now
        ethUsdPriceFeedAddress = ethUsdAggregator.address
    } else {
        //If we are not on a development chain
        ethUsdPriceFeedAddress = networkConfig[chainId].ethUsdPriceFeed
    }

    //The idea of mocking is that if there is no contract(ethUsdPriceFeedAddress), we deploy
    //a minimal version for our local testing
    const args = [ethUsdPriceFeedAddress]
    const fundMe = await deploy("FundMe", {
        from: deployer,
        args, // args: args (ES6-short-hand) /**we prefer define it out */,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1, //given etherscan time
    })
    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        await verify(fundMe.address, args)
    }
    log(
        "-----------------------------------------------------------------------"
    )
}
module.exports.tags = ["all", "fundme"]
