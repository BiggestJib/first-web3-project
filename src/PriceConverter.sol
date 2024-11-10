// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../node_modules/@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
// /home/jibola/solidity/node_modules/@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol

library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price * 1e10); // Adjust price to 18 decimal places
    }

    // Function to convert a specified ETH amount to USD
    function getConversion(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18; // Adjust for 18 decimal places
        return ethAmountInUsd;
    }
}
