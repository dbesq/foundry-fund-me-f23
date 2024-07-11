// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// 1. Deploy Mocks on local chain

// 2. Keep track of K address accross different chains
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // IF LOCAL, DEPLOY MOCKS, OTHERWISE, GET ADDRESS FROM LIVE NETWORK

    NetworkConfig public activeNetworkConfig;

    // Use constant variables to make code more understandable below
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;


    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        // Use 'if/else' for every chain to test, with Anvil if not using public chain
        if(block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }
    
    function getSepoliaEthConfig() public pure returns(NetworkConfig memory) {
        // get priceFeed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory) {
        // get priceFeed address

        // Make sure you have not already created the Mock
        if(activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // 1. Deploy Mock 
        // 2. Return Mock address

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
    }
}