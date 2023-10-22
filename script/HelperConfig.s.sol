// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

// Importing required contracts and libraries
import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkTokens.t.sol";

// This contract provides configuration for different networks.
// It uses the Script contract from the forge-std library to provide scripting functionality.
// It also uses the VRFCoordinatorV2Mock contract from the Chainlink library to create a mock VRF Coordinator.
contract HelperConfig is Script {
    // Declaring a struct for the network configuration
    // This includes the entrance fee, interval, VRF Coordinator address, gas lane, subscription ID, callback gas limit, and LINK token address.
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoodinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
        address link;
        uint256 deployerKey;
    }

    // Declaring a LinkToken instance
    // This is used to get the address of the LINK token.
    LinkToken linkToken = new LinkToken();

    // The constructor sets the active network configuration based on the chain ID.
    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    // This function returns the configuration for the Sepolia network.
    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 1,
                interval: 30,
                vrfCoodinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                subscriptionId: 6232,
                callbackGasLimit: 500000,
                link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
                deployerKey: vm.envUint("PRIVATE KEY")
            });
    }

    // Declaring a state variable for the active network configuration
    NetworkConfig public activeNetworkConfig;
    uint256 public constant DEFAULT_ANVIL_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    // This function returns the configuration for the Anvil network.
    // If the active network configuration hasn't been set, it creates a new VRF Coordinator and sets the configuration.
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // Check to see if we set an active network config
        if (activeNetworkConfig.vrfCoodinator != address(0)) {
            return activeNetworkConfig;
        } else {
            uint96 baseFee = 0.25 ether;
            uint96 gasPriceLink = 0.000000000000000001 ether;
            vm.startBroadcast();
            VRFCoordinatorV2Mock vrfCoordinatorV2Mock = new VRFCoordinatorV2Mock(
                    baseFee,
                    gasPriceLink
                );
            vm.stopBroadcast();
            return
                NetworkConfig({
                    entranceFee: 1,
                    interval: 30,
                    vrfCoodinator: address(vrfCoordinatorV2Mock),
                    gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                    subscriptionId: 6232,
                    callbackGasLimit: 500000,
                    link: address(linkToken),
                    deployerKey: DEFAULT_ANVIL_KEY
                });
        }
    }
}
