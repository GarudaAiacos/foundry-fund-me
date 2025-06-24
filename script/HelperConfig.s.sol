// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";
import {Script, console} from "forge-std/Script.sol";

contract HelperConfig is Script {
    uint8 private constant DECIMALS = 8;
    int256 private constant INITIAL_PRICE = 2000e8;
    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    struct NetworkConfig {
        address priceFeed;
    }

    // ETH sepolia
    function getSepoliaEthConfig() private pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    // ETH mainnet
    function getMainnetEthConfig() private pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainnetConfig;
    }

    // ETH anvil
    function getAnvilEthConfig() private returns (NetworkConfig memory) {
        // TODO 本地模拟外部合约
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        console.log("Deploying MockV3Aggregator");
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        activeNetworkConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return activeNetworkConfig;
    }
}
