// Get Funds from users
// withdraw funds
// set a minimum funding value in USD


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {

    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;
    address[] public funders;
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    mapping (address funders => uint256 amount) public addressToAmountFunded;

    function fund() public payable {
        // allow users to send money
        // minimum amount to send
        // How to send ETH to the contract
        require(msg.value.getConversionRate() >= MINIMUM_USD, "didnt send enough ETH");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }


    function withdraw() public onlyOwner{

        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // reset the array
        funders = new address[](0);

        // transfer
        payable(msg.sender).transfer(address(this).balance);
        // send 
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "Send failed");
        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");

    }

    modifier onlyOwner() {
        // order of _ matters
        // require(msg.sender == i_owner, "Must be owner");
        if(msg.sender != i_owner) {revert NotOwner(); }
        _;
    }

     receive() external payable { 
        fund();
    }

    fallback() external payable { 
        fund();
    }
}