// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface dataFeed
    ) internal view returns (uint256) {
        // 调用合约
        // Address:0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI:
        // AggregatorV3Interface dataFeed = AggregatorV3Interface(
        //     0x694AA1769357215DE4FAC081bf1f309aDC325306
        // );
        // 获取最新价格
        (
            ,
            /* uint80 roundId */ int256 answer /* uint256 startedAt */ /* uint256 updatedAt */ /* uint80 answeredInRound */,
            ,
            ,

        ) = dataFeed.latestRoundData();
        return uint256(answer * 1e10); // 2533.75973941$
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface dataFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(dataFeed);
        uint256 ethAmountInUSD = (ethAmount * ethPrice) / 1e18;
        return ethAmountInUSD;
    }
}
