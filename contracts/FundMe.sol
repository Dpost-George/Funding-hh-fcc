// SPDX-License-Identifier: MIT
//Best-practice 1- pragma
pragma solidity ^0.8.8;

/* This Contract Task:
    - Get fund from users(Set a minimum funding value in USD(using chinlink price feed))
    - Withraw funds(only contract creator)
    
*/
//Best-practice 2- import
import "./PriceConverter.sol";

//Best-practice 3- errors (precede with contract-name: ContractName_Errors())
//new custom error feature that save a lot of gaz instead of require
error FundMe_NotOwner();
error FundMe_NotEnoughFund();
error FundMe_CallFailed();

//Best-practice 4- Interfaces: None

//Best-practice 5- Libraries: None

//Best-practice 6- Contract
//NetSpec: important for readability, information sharing and documentation
/** @title A contract for crowd funding
 *   @author George Francis Mbongning T.
 *   @notice This contract is a demo sample funding contract
 *   @dev this implements chainlink price feeds as our library
 */
contract FundMe {
    //Best-practice 1- Type Declarations
    using PriceConverter for uint256;

    //Best-practice 2- State Variables

    uint256 public constant MINIMUM_USD = 50 * 1e18;
    //make it constant for gaz efficiency since we never change its value. 1e18 == 1 * 10 ** 18

    address[] private s_funders; //help us keep tract of all our wonderfull donatorsn//can be private and we callgetter
    mapping(address => uint256) private s_addressToAmountFunded; //keep tract of amount for each donator//can also be private

    address public immutable i_owner; //i_owner  of this contract(Who deploy this contract) we can make it private 12:06
    ///@notice memory variable, constant variable and immutable variable are not store in storage
    //since we declare it an initialize it in the constructor(once).never to be modified
    //we make it immutable for gaz efficiency: resume: constant and immutable
    AggregatorV3Interface private s_priceFeed;

    //Best-practice 3- Events: none for now

    //Best-practice 4- Modifiers
    modifier onlyOwner() {
        //we now have custom error in solidity that save a lot of gaz as to compare to require
        //require(msg.sender == i_owner,"Sender is not the owner");
        if (msg.sender != i_owner) {
            revert FundMe_NotOwner();
        }
        _; //this means verify it first then do the rest of the code
    }

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * @notice This function receives fund from users and fund this contract
     * @dev this implements chainlink price feeds as our library
     */

    function fund() public payable {
        //We want to be able to set a minimum amount to send(in usd)
        //require(msg.value.getConversionRate() >= MINIMUM_USD, 'Not enough fund'); //1e18 == 1 * 10 ** 18 == 1000000000000000000 == 1 Eth
        if (!(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD)) {
            revert FundMe_NotEnoughFund();
        }
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        //resetting the mapping datastructure
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        //resetting the array
        s_funders = new address[](0); //new array with 0 element

        //Now we want to withdraw the fund 3 ways for doing this (transfer, send,call)
        //in solidity to withdraw native token you need a payable address:
        // msg.sender = type  address while payable(msg.sender) = type payable address

        /*
        //1. transfer (if failed it will error and revert gas 2300)
        payable(msg.sender).transfer(address(this).balance);
        //2.send (if failed it doesnt revert, return a bool gas 2300)
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess,"Send failed");//if it fails then this help us  revert
        */
        //3.call   (very powerful discovert later) return a boolean and data(payload)
        //as of now this is the recommended way of sending eth or your blockchain native token
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        //require(callSuccess,"Call failed");//help revert
        if (!callSuccess) {
            revert FundMe_CallFailed();
        }
    }

    function cheaperWithdraw() public payable onlyOwner {
        //we want to take the storage data to memory so reading and writing will cost less gas
        address[] memory funders = s_funders; //mappings can't be in memory,sorry
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        //require(callSuccess,"Call failed");//help revert
        if (!callSuccess) {
            revert FundMe_CallFailed();
        }
    }

    //What happens if someone sends this contract ETH or native token without calling fund function
    //We have two special function in solidity: receive() and fallback()

    //Ether or native blockchain token is send to contract
    // is msg.data empty?
    //     |.      |.
    //.    yes     no
    //.    |.      |
    // receive()?  fallback()
    //.  |.     |
    //  yes.    no.
    //.  |.      |
    //receive().  fallack()

    //View/Pure functions
    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
