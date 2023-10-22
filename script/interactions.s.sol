// // pragma solidity ^0.8.19;

// // // Importing required contracts and libraries
// // import {Script, console} from "forge-std/Script.sol";
// // import {HelperConfig} from "./HelperConfig.s.sol";
// // import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
// // import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
// // import {LinkToken} from "../test/mocks/LinkTokens.t.sol";

// // // This contract creates a subscription on the VRF Coordinator.
// // // It uses the HelperConfig contract to get the configuration for the subscription.
// // contract CreateSubscription is Script {
// //     // Declaring state variables for the subscription configuration
// //     // These are set in the createSubscriptionUsingConfig function and used in the createSubscription function.
// //     uint256 public entranceFee;
// //     uint256 public interval;
// //     address public vrfCoodinator;
// //     bytes32 public gasLane;
// //     uint64 public subscriptionId;
// //     uint32 public callbackGasLimit;
// //     address link;
// //     uint256 deployerKey;

// //     // Declaring a HelperConfig instance
// //     // This is used to get the configuration for the subscription.
// //     HelperConfig helperConfig = new HelperConfig();

// //     // This function creates a subscription on the VRF Coordinator.
// //     // It takes the address of the VRF Coordinator as a parameter.
// //     // It returns the ID of the new subscription.
// //     function createSubscription(
// //         address _vrfCoordiantor
// //     ) public returns (uint64) {
// //         console.log("creating subscription on chainid: ", block.chainid);
// //         vm.startBroadcast();
// //         subscriptionId = VRFCoordinatorV2Mock(_vrfCoordiantor)
// //             .createSubscription();
// //         vm.stopBroadcast();
// //         console.log("your subId is", subscriptionId);
// //         console.log(
// //             "please update subscription id in helper config",
// //             subscriptionId
// //         );
// //         return subscriptionId;
// //     }

// //     // This function creates a subscription using the configuration from the HelperConfig contract.
// //     // It returns the ID of the new subscription.
// //     function createSubscriptionUsingConfig() public returns (uint64) {
// //         (
// //             ,
// //             ,
// //             vrfCoodinator,
// //             ,
// //             subscriptionId,
// //             ,
// //             link,
// //             deployerKey
// //         ) = helperConfig.activeNetworkConfig();
// //         return createSubscription(vrfCoodinator);
// //     }

// //     // This function is the entry point for the script.
// //     // It calls the createSubscriptionUsingConfig function and returns the ID of the new subscription.
// //     function run() external returns (uint64) {
// //         return createSubscriptionUsingConfig();
// //     }
// // }

// // // This contract funds a subscription on the VRF Coordinator.
// // // It uses the HelperConfig contract to get the configuration for the subscription.
// // contract FundSubscription is Script {
// //     // Declaring state variables for the subscription configuration
// //     // These are set in the fundSubscriptionUsingConfig function and used in the fundSubscription function.
// //     uint256 public entranceFee;
// //     uint256 public interval;
// //     address public vrfCoodinator;
// //     bytes32 public gasLane;
// //     uint64 public subscriptionId;
// //     uint32 public callbackGasLimit;
// //     address link;
// //     uint256 deployerKey;

// //     // Declaring a HelperConfig instance
// //     // This is used to get the configuration for the subscription.
// //     HelperConfig helperConfig = new HelperConfig();

// //     // Declaring a constant for the amount of Ether to fund the subscription with
// //     uint96 public constant FUND_AMOUNT = 3 ether;

// //     // This function funds a subscription using the configuration from the HelperConfig contract.
// //     function fundSubscriptionUsingConfig() public {
// //         (
// //             ,
// //             ,
// //             vrfCoodinator,
// //             ,
// //             subscriptionId,
// //             ,
// //             link,
// //             deployerKey
// //         ) = helperConfig.activeNetworkConfig();
// //         //call the fundSubscription function passing in all these that is needed
// //         fundSubscription(vrfCoodinator, subscriptionId, link);
// //     }

// //     // This function funds a subscription on the VRF Coordinator.
// //     // It takes the address of the VRF Coordinator, the ID of the subscription, and the address of the LINK token as parameters.
// //     function fundSubscription(
// //         address _vrfCoordiantor,
// //         uint64 _subId,
// //         address _linkToken
// //     ) public {
// //         console.log("funding subscription id", _subId);
// //         console.log("using vrfCoordinator", _vrfCoordiantor);
// //         console.log("on the chainId", block.chainid);
// //         if (block.chainid == 31337) {
// //             vm.startBroadcast();
// //             VRFCoordinatorV2Mock(_vrfCoordiantor).fundSubscription(
// //                 _subId,
// //                 FUND_AMOUNT
// //             );
// //             vm.stopBroadcast();
// //         } else {
// //             console.log("paying into the sepolia network");
// //             vm.startBroadcast();
// //             LinkToken(_linkToken).transfer(_vrfCoordiantor, FUND_AMOUNT);
// //             vm.stopBroadcast();
// //         }
// //     }

// //     // This function is the entry point for the script.
// //     // It calls the fundSubscriptionUsingConfig function.
// //     function run() external {
// //         fundSubscriptionUsingConfig();
// //     }
// // }

// // // This contract deploys a new Raffle contract.
// // // It uses the HelperConfig contract to get the configuration for the raffle.
// // contract AddConsumer is Script {
// //     uint256 public entranceFee;
// //     uint256 public interval;
// //     address public vrfCoodinator;
// //     bytes32 public gasLane;
// //     uint64 public subscriptionId;
// //     uint32 public callbackGasLimit;
// //     address link;
// //     uint256 deployerKey;

// //     HelperConfig helperConfig = new HelperConfig();

// //     function addConsumer(
// //         address _raffle,
// //         address _vrfCoodinator,
// //         uint64 _subId,
// //         uint256 _deployerKey
// //     ) public {
// //         console.log("adding consumer on chainid: ", block.chainid);
// //         console.log("Most recent deployment: ", _raffle);
// //         console.log("subId22222: ", _subId);
// //         console.log("vrfCoodinator22222: ", _vrfCoodinator);

// //         vm.startBroadcast(_deployerKey);
// //         VRFCoordinatorV2Mock(_vrfCoodinator).addConsumer(_subId, _raffle);
// //         vm.stopBroadcast();
// //         console.log("your raffle is deployed at", address(_raffle));
// //     }

// //     function addConsumerUsingConfig(address _raffle) public {
// //         (
// //             entranceFee,
// //             interval,
// //             vrfCoodinator,
// //             gasLane,
// //             subscriptionId,
// //             callbackGasLimit,
// //             link,
// //             deployerKey
// //         ) = helperConfig.activeNetworkConfig();
// //         console.log("entranceFee: ", entranceFee);
// //         console.log("interval: ", interval);
// //         console.log("vrfCoodinator: ", vrfCoodinator);
// //         //console.log("gasLane: ", gasLane);
// //         console.log("subId: ", subscriptionId);
// //         console.log("callbackGasLimit: ", callbackGasLimit);
// //         console.log("link: ", link);
// //         addConsumer(_raffle, vrfCoodinator, subscriptionId, deployerKey);
// //     }

// //     function run() external {
// //         address raffle = DevOpsTools.get_most_recent_deployment(
// //             "Raffle",
// //             block.chainid
// //         );
// //         addConsumerUsingConfig(address(raffle));
// //     }
// // }

// // contract LogStuff is Script {
// //     HelperConfig helperConfig = new HelperConfig();

// //     function logStuff(
// //         uint256 entranceFeeParam,
// //         uint256 interval,
// //         address vrfCoodinator,
// //         bytes32 gasLane,
// //         uint64 subId,
// //         uint32 callbackGasLimit,
// //         address link,
// //         address raffle
// //     ) public view {
// //         console.log("entranceFee: ", entranceFeeParam);
// //         console.log("interval: ", interval);
// //         console.log("vrfCoodinator: ", vrfCoodinator);
// //         //console.log("gasLane: ", gasLane);
// //         console.log("subId: ", subId);
// //         console.log("callbackGasLimit: ", callbackGasLimit);
// //         console.log("link: ", link);
// //         console.log("Most recent deployment: ", raffle);
// //     }

// //     function run() external {
// //         uint256 entranceFee;
// //         uint256 interval;
// //         address vrfCoodinator;
// //         bytes32 gasLane;
// //         uint64 subId;
// //         uint32 callbackGasLimit;
// //         address link;
// //         uint256 deployerKey;

// //         address raffle;
// //         raffle = DevOpsTools.get_most_recent_deployment(
// //             "Raffle",
// //             block.chainid
// //         );
// //         (
// //             entranceFee,
// //             interval,
// //             vrfCoodinator,
// //             gasLane,
// //             subId,
// //             callbackGasLimit,
// //             link,
// //             deployerKey
// //         ) = helperConfig.activeNetworkConfig();

// //         logStuff(
// //             entranceFee,
// //             interval,
// //             vrfCoodinator,
// //             gasLane,
// //             subId,
// //             callbackGasLimit,
// //             link,
// //             raffle
// //         );
// //     }
// // }

// pragma solidity ^0.8.19;

// // Importing required contracts and libraries
// import {Script, console} from "forge-std/Script.sol";
// import {HelperConfig} from "./HelperConfig.s.sol";
// import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
// import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
// import {LinkToken} from "../test/mocks/LinkTokens.t.sol";

// // This contract creates a subscription on the VRF Coordinator.
// // It uses the HelperConfig contract to get the configuration for the subscription.
// contract CreateSubscription is Script {
//     // Declaring a HelperConfig instance
//     // This is used to get the configuration for the subscription.
//     HelperConfig helperConfig = new HelperConfig();

//     // This function creates a subscription on the VRF Coordinator.
//     // It takes the address of the VRF Coordinator as a parameter.
//     // It returns the ID of the new subscription.
//     function createSubscription(
//         address _vrfCoordiantor
//     ) public returns (uint64) {
//         console.log("creating subscription on chainid: ", block.chainid);
//         vm.startBroadcast();
//         uint64 subscriptionId = VRFCoordinatorV2Mock(_vrfCoordiantor)
//             .createSubscription();
//         vm.stopBroadcast();
//         console.log("your subId is", subscriptionId);
//         console.log(
//             "please update subscription id in helper config",
//             subscriptionId
//         );
//         return subscriptionId;
//     }

//     // This function creates a subscription using the configuration from the HelperConfig contract.
//     // It returns the ID of the new subscription.
//     function createSubscriptionUsingConfig() public returns (uint64) {
//         (, , address vrfCoodinator, , , , , ) = helperConfig
//             .activeNetworkConfig();
//         return createSubscription(vrfCoodinator);
//     }

//     // This function is the entry point for the script.
//     // It calls the createSubscriptionUsingConfig function and returns the ID of the new subscription.
//     function run() external returns (uint64) {
//         return createSubscriptionUsingConfig();
//     }
// }

// // This contract funds a subscription on the VRF Coordinator.
// // It uses the HelperConfig contract to get the configuration for the subscription.
// contract FundSubscription is Script {
//     // Declaring a HelperConfig instance
//     // This is used to get the configuration for the subscription.
//     HelperConfig helperConfig = new HelperConfig();

//     // Declaring a constant for the amount of Ether to fund the subscription with
//     uint96 public constant FUND_AMOUNT = 3 ether;

//     // This function funds a subscription using the configuration from the HelperConfig contract.
//     function fundSubscriptionUsingConfig() public {
//         (
//             ,
//             ,
//             address vrfCoodinator,
//             ,
//             uint64 subscriptionId,
//             ,
//             address link,

//         ) = helperConfig.activeNetworkConfig();
//         //call the fundSubscription function passing in all these that is needed
//         fundSubscription(vrfCoodinator, subscriptionId, link);
//     }

//     // This function funds a subscription on the VRF Coordinator.
//     // It takes the address of the VRF Coordinator, the ID of the subscription, and the address of the LINK token as parameters.
//     function fundSubscription(
//         address _vrfCoordiantor,
//         uint64 _subId,
//         address _linkToken
//     ) public {
//         console.log("funding subscription id", _subId);
//         console.log("using vrfCoordinator", _vrfCoordiantor);
//         console.log("on the chainId", block.chainid);
//         if (block.chainid == 31337) {
//             vm.startBroadcast();
//             VRFCoordinatorV2Mock(_vrfCoordiantor).fundSubscription(
//                 _subId,
//                 FUND_AMOUNT
//             );
//             vm.stopBroadcast();
//         } else {
//             console.log("paying into the sepolia network");
//             vm.startBroadcast();
//             LinkToken(_linkToken).transfer(_vrfCoordiantor, FUND_AMOUNT);
//             vm.stopBroadcast();
//         }
//     }

//     // This function is the entry point for the script.
//     // It calls the fundSubscriptionUsingConfig function.
//     function run() external {
//         fundSubscriptionUsingConfig();
//     }
// }

// // This contract deploys a new Raffle contract.
// // It uses the HelperConfig contract to get the configuration for the raffle.
// contract AddConsumer is Script {
//     HelperConfig helperConfig = new HelperConfig();

//     function addConsumer(
//         address _raffle,
//         address _vrfCoodinator,
//         uint64 _subId,
//         uint256 _deployerKey
//     ) public {
//         console.log("adding consumer on chainid: ", block.chainid);
//         console.log("Most recent deployment: ", _raffle);
//         console.log("subId22222: ", _subId);
//         console.log("vrfCoodinator22222: ", _vrfCoodinator);

//         vm.startBroadcast(_deployerKey);
//         VRFCoordinatorV2Mock(_vrfCoodinator).addConsumer(_subId, _raffle);
//         vm.stopBroadcast();
//         console.log("your raffle is deployed at", address(_raffle));
//     }

//     function addConsumerUsingConfig(address _raffle) public {
//         (
//             ,
//             ,
//             address vrfCoodinator,
//             ,
//             uint64 subscriptionId,
//             ,
//             ,
//             uint256 deployerKey
//         ) = helperConfig.activeNetworkConfig();
//         addConsumer(_raffle, vrfCoodinator, subscriptionId, deployerKey);
//     }

//     function run() external {
//         address raffle = DevOpsTools.get_most_recent_deployment(
//             "Raffle",
//             block.chainid
//         );
//         addConsumerUsingConfig(address(raffle));
//     }
// }

// contract LogStuff is Script {
//     HelperConfig helperConfig = new HelperConfig();

//     function logStuff(
//         uint256 entranceFeeParam,
//         uint256 interval,
//         address vrfCoodinator,
//         bytes32 gasLane,
//         uint64 subId,
//         uint32 callbackGasLimit,
//         address link,
//         address raffle
//     ) public view {
//         console.log("entranceFee: ", entranceFeeParam);
//         console.log("interval: ", interval);
//         console.log("vrfCoodinator: ", vrfCoodinator);
//         console.log("subId: ", subId);
//         console.log("callbackGasLimit: ", callbackGasLimit);
//         console.log("link: ", link);
//         console.log("Most recent deployment: ", raffle);
//     }

//     function run() external {
//         (
//             uint256 entranceFee,
//             uint256 interval,
//             address vrfCoodinator,
//             bytes32 gasLane,
//             uint64 subId,
//             uint32 callbackGasLimit,
//             address link,

//         ) = helperConfig.activeNetworkConfig();

//         address raffle;
//         raffle = DevOpsTools.get_most_recent_deployment(
//             "Raffle",
//             block.chainid
//         );

//         logStuff(
//             entranceFee,
//             interval,
//             vrfCoodinator,
//             gasLane,
//             subId,
//             callbackGasLimit,
//             link,
//             raffle
//         );
//     }
// }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Importing required contracts and libraries
import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {LinkToken} from "../test/mocks/LinkTokens.t.sol";

struct SubscriptionConfig {
    uint256 entranceFee;
    uint256 interval;
    address vrfCoodinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;
    address link;
    uint256 deployerKey;
}

contract CreateSubscription is Script {
    SubscriptionConfig public config;
    HelperConfig helperConfig = new HelperConfig();

    function createSubscription(
        address _vrfCoordiantor,
        uint256 _deployerKey
    ) public returns (uint64) {
        console.log("creating subscription on chainid: ", block.chainid);
        vm.startBroadcast(_deployerKey);
        config.subscriptionId = VRFCoordinatorV2Mock(_vrfCoordiantor)
            .createSubscription();
        vm.stopBroadcast();
        console.log("your subId is", config.subscriptionId);
        console.log(
            "please update subscription id in helper config",
            config.subscriptionId
        );
        return config.subscriptionId;
    }

    function createSubscriptionUsingConfig() public returns (uint64) {
        (
            ,
            ,
            config.vrfCoodinator,
            ,
            config.subscriptionId,
            ,
            config.link,
            config.deployerKey
        ) = helperConfig.activeNetworkConfig();
        return createSubscription(config.vrfCoodinator, config.deployerKey);
    }

    function run() external returns (uint64) {
        return createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script {
    SubscriptionConfig public config;
    HelperConfig helperConfig = new HelperConfig();
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        (
            ,
            ,
            config.vrfCoodinator,
            ,
            config.subscriptionId,
            ,
            config.link,
            config.deployerKey
        ) = helperConfig.activeNetworkConfig();
        fundSubscription(
            config.vrfCoodinator,
            config.subscriptionId,
            config.link,
            config.deployerKey
        );
    }

    function fundSubscription(
        address _vrfCoordiantor,
        uint64 _subId,
        address _linkToken,
        uint256 _deployerKey
    ) public {
        console.log("funding subscription id", _subId);
        console.log("using vrfCoordinator", _vrfCoordiantor);
        console.log("on the chainId", block.chainid);
        if (block.chainid == 31337) {
            vm.startBroadcast(_deployerKey);
            VRFCoordinatorV2Mock(_vrfCoordiantor).fundSubscription(
                _subId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            console.log("paying into the sepolia network");
            vm.startBroadcast(_deployerKey);
            LinkToken(_linkToken).transfer(_vrfCoordiantor, FUND_AMOUNT);
            vm.stopBroadcast();
        }
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    SubscriptionConfig public config;
    HelperConfig helperConfig = new HelperConfig();

    function addConsumer(
        address _raffle,
        address _vrfCoodinator,
        uint64 _subId,
        uint256 _deployerKey
    ) public {
        console.log("adding consumer on chainid: ", block.chainid);
        console.log("Most recent deployment: ", _raffle);
        console.log("subId22222: ", _subId);
        console.log("vrfCoodinator22222: ", _vrfCoodinator);

        vm.startBroadcast(_deployerKey);
        VRFCoordinatorV2Mock(_vrfCoodinator).addConsumer(_subId, _raffle);
        vm.stopBroadcast();
        console.log("your raffle is deployed at", address(_raffle));
    }

    function addConsumerUsingConfig(address _raffle) public {
        (
            config.entranceFee,
            config.interval,
            config.vrfCoodinator,
            config.gasLane,
            config.subscriptionId,
            config.callbackGasLimit,
            config.link,
            config.deployerKey
        ) = helperConfig.activeNetworkConfig();
        addConsumer(
            _raffle,
            config.vrfCoodinator,
            config.subscriptionId,
            config.deployerKey
        );
    }

    function run() external {
        address raffle = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        addConsumerUsingConfig(address(raffle));
    }
}

// contract LogStuff is Script {
//     SubscriptionConfig public config;
//     HelperConfig helperConfig = new HelperConfig();

//     function logStuff(
//         uint256 entranceFeeParam,
//         uint256 interval,
//         address vrfCoodinator,
//         bytes32 gasLane,
//         uint64 subId,
//         uint32 callbackGasLimit,
//         address link,
//         address raffle
//     ) public view {
//         console.log("entranceFee: ", entranceFeeParam);
//         console.log("interval: ", interval);
//         console.log("vrfCoodinator: ", vrfCoodinator);
//         console.log("subId: ", subId);
//         console.log("callbackGasLimit: ", callbackGasLimit);
//         console.log("link: ", link);
//         console.log("Most recent deployment: ", raffle);
//     }

//     function run() external {
//         address raffle;
//         raffle = DevOpsTools.get_most_recent_deployment(
//             "Raffle",
//             block.chainid
//         );
//         (
//             config.entranceFee,
//             config.interval,
//             config.vrfCoodinator,
//             config.gasLane,
//             config.subscriptionId,
//             config.callbackGasLimit,
//             config.link,
//             config.deployerKey
//         ) = helperConfig.activeNetworkConfig();

//         logStuff(
//             config.entranceFee,
//             config.interval,
//             config.vrfCoodinator,
//             config.gasLane,
//             config.subscriptionId,
//             config.callbackGasLimit,
//             config.link,
//             raffle
//         );
//     }
// }
