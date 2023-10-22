// pragma solidity ^0.8.19;

// //setup script contract of foundry
// import {Script} from "forge-std/Script.sol";
// import {Raffle} from "../src/Raffle.sol";
// import {HelperConfig} from "./HelperConfig.s.sol";
// import {CreateSubscription, FundSubscription, AddConsumer} from "./interactions.s.sol";

// contract DeployRaffle is Script {
//     function run() external returns (Raffle) {
//         HelperConfig helperConfig = new HelperConfig();
//         (
//             uint256 entranceFee,
//             uint256 interval,
//             address vrfCoodinator,
//             bytes32 gasLane,
//             uint64 subscriptionId,
//             uint32 callbackGasLimit,
//             address link,
//             uint256 deployerKey
//         ) = helperConfig.activeNetworkConfig();
//         if (subscriptionId == 0) {
//             CreateSubscription createSubscription = new CreateSubscription();
//             subscriptionId = createSubscription.createSubscription(
//                 vrfCoodinator,
//                 deployerKey
//             );
//             FundSubscription fundSubscription = new FundSubscription();
//             fundSubscription.fundSubscription(
//                 vrfCoodinator,
//                 subscriptionId,
//                 link,
//                 deployerKey
//             );

//             AddConsumer addConsumer = new AddConsumer();
//             Raffle raffle = new Raffle(
//                 entranceFee,
//                 interval,
//                 vrfCoodinator,
//                 gasLane,
//                 subscriptionId,
//                 callbackGasLimit
//             );
//             // address latestRaffleAddress = addConsumer.getLatestRaffleAddress();
//             addConsumer.addConsumer(
//                 address(raffle),
//                 vrfCoodinator,
//                 subscriptionId,
//                 deployerKey
//             );
//         }
//         vm.startBroadcast();
//         Raffle raffle = new Raffle(
//             entranceFee,
//             interval,
//             vrfCoodinator,
//             gasLane,
//             subscriptionId,
//             callbackGasLimit
//         );
//         vm.stopBroadcast();
//         return raffle;
//     }
// }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//setup script contract of foundry
import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./interactions.s.sol";

contract DeployRaffle is Script {
    struct RaffleConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoodinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
        address link;
        uint256 deployerKey;
    }
    RaffleConfig config;

    function setAndGetVariablesFromTheActiveConfig() public {
        HelperConfig helperConfig = new HelperConfig();

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
    }

    function run() external returns (Raffle) {
        setAndGetVariablesFromTheActiveConfig();
        if (config.subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            config.subscriptionId = createSubscription.createSubscription(
                config.vrfCoodinator,
                config.deployerKey
            );
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                config.vrfCoodinator,
                config.subscriptionId,
                config.link,
                config.deployerKey
            );

            AddConsumer addConsumer = new AddConsumer();
            Raffle raffle = new Raffle(
                config.entranceFee,
                config.interval,
                config.vrfCoodinator,
                config.gasLane,
                config.subscriptionId,
                config.callbackGasLimit
            );
            addConsumer.addConsumer(
                address(raffle),
                config.vrfCoodinator,
                config.subscriptionId,
                config.deployerKey
            );
        }
        vm.startBroadcast();
        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoodinator,
            config.gasLane,
            config.subscriptionId,
            config.callbackGasLimit
        );
        vm.stopBroadcast();
        return raffle;
    }
}
