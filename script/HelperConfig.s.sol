// SPDX-License-Identifier: MIT

// Deploy mocks when on anvil chain
// Keep track of contract addresses across different chains
// Sepolia ETH/USD
// Mainnet ETH/USD

pragma solidity ^0.8.20;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // if on anvil deploy mocks

    NetworkConfig public activeNetworkConfig;

    uint8 constant public DECIMALS = 8;
    int256 constant public INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliETHConfig();
        } else if(block.chainid == 1){
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliETHConfig() public pure returns(NetworkConfig memory) {
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }
    function getMainnetEthConfig() public pure returns(NetworkConfig memory){
        NetworkConfig memory mainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainnetConfig;
    }
    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory) {
        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }

        // 1. Deploy Mock
        // 2. Return Price Feed Address ie: Mock Address

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;



    }

}