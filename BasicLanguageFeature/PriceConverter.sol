// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter{
    function getPrice()internal view returns(uint){
        AggregatorV3Interface priceFeed=AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (, int256 answer, , , )=priceFeed.latestRoundData();
        return uint(answer*1e10);
    }
    function getConversionRate(uint ethCount)internal view returns(uint){
        uint price = (getPrice()*ethCount)/1e18;
        return price;
    }
}