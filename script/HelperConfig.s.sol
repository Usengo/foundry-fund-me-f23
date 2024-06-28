// SPDX-License-Identifier: MIT

// 1. Deploy mocks when we are on a local anvil chain
// 2. Keep track of contract address across different chains
// Sapolia ETH/USD
// Mainnet ETH/USD

pragma solidity ^0.8.18;

import  {Script} from "forge-std/Script.sol";
import { MockV3Aggregator } from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{

    NetWorkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

struct NetWorkConfig {
    address priceFeed; // ETH/USD price feed address

}

constructor() {
    if (block.chainid == 11155111) {
        activeNetworkConfig = getSepoliaConfig();
    }else if (block.chainid == 1) {
        activeNetworkConfig = getSepoliaConfig();
    } else {
        activeNetworkConfig = getOrCreateAnvilEthConfig();
    }
}

function getSepoliaConfig() public pure returns(NetWorkConfig memory){
// price feed address
NetWorkConfig memory SepoliaConfig = NetWorkConfig({
    priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
});
return SepoliaConfig;
}

function getMainnetEthConfig() public pure returns(NetWorkConfig memory) {
    // price feed address
    NetWorkConfig memory ethConfig = NetWorkConfig({
        priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
    });
    return ethConfig;
}

function getOrCreateAnvilEthConfig() public  returns (NetWorkConfig memory) {
    if (activeNetworkConfig.priceFeed != address(0)){
        return activeNetworkConfig;
    }
//     // price feed address

//     // 1. Deploy the mocks
//     //2. Return the mock address

   vm. startBroadcast();
    MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
        DECIMALS,
        INITIAL_PRICE
         );
    vm.stopBroadcast();

    NetWorkConfig memory anvilConfig = NetWorkConfig({
        priceFeed: address(mockPriceFeed)});
        return anvilConfig;
}




}