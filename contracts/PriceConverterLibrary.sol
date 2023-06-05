// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter{
    
    function getPrice(AggregatorV3Interface s_priceFeed) internal view returns(uint256) {         
        (,int256 price,,,) = s_priceFeed.latestRoundData();   
        // return uint256(price * 1e10); 
        return uint256(price); 

    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface s_priceFeed) internal view returns(uint256){
        uint256 ethPrice = getPrice(s_priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount)/1e18;
        return ethAmountInUsd;
    }    
}