// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";
import "node_modules/@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwnert();

contract FundMe {
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe__NotOwnert();
        }
        _;
    }

    using PriceConverter for uint256;

    address[] private s_funders;

    uint256 public constant MINIMUM_USD = 5 * 1e18; // Minimum amount in USD with 18 decimal places
    mapping(address => uint256) public s_addressToAmontFunded;
    AggregatorV3Interface private s_priceFeed;
    // Function to allow funding with ETH

    function fund() public payable {
        require(msg.value.getConversion(s_priceFeed) >= MINIMUM_USD, "Insufficient ETH! Minimum 5 USD worth required.");
        s_funders.push(msg.sender);
        s_addressToAmontFunded[msg.sender] += msg.value;
    }

    address private immutable i_owner;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    // Placeholder function for withdrawing funds (implement logic if needed)
    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmontFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");

        require(callSuccess, "Send failed");
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmontFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");

        require(callSuccess, "Send failed");
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getAddressToAmontFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmontFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
