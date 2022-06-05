// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

/*
Librairy can send eth, never start with contract, you cant declare state variale
-All the function are internal
*/
//importing from npm package
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    //This function help us get eth price in usd:its interact with other(outside contract)
    function getPrice(AggregatorV3Interface priceFeed)
        internal
        view
        returns (uint256)
    {
        // we need the ABI and Adress of the contract to interact with.
        //the address is here: https://docs.chain.link/docs/ethereum-addresses/
        //look for eth/usd
        //Address: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        //ABI: look up the interface exposing allthe function compile it to get abi
        //ABI: AggregatorV3Interface

        /*A contract at this address will contain all the function from the interface*/
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        // );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        //ETH in terms of USD decimal(8)
        return uint256(price * 1e10); //we receive 8 decimal price and add 10 zeros to match msg.value unit
    }

    //This function convert the msg.value eth amount(wei)n to its dollar counterpart
    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18; //we divide by 1e18 to have a result with 1e18 since both values multiplied have each 18 decimal
        return ethAmountInUsd;
    }
}
