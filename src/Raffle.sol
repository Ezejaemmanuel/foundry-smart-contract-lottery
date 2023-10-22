// SPDX-License-Identifier: MIT
// This line specifies the version of Solidity that the contract should be compiled with.
// It's important to specify this so that the contract will always be compiled with the correct version of Solidity.
pragma solidity ^0.8.18;

// Importing required interfaces and contracts
// These are the libraries that the contract is dependent on.
// They provide functionality that the contract uses, such as the ability to interact with the Chainlink VRF.
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

// This contract is a raffle game. It uses Chainlink's Verifiable Random Function (VRF) to pick a winner.
// The VRF is a way to generate random numbers that are provably fair and can be verified on-chain.
// This is important for a raffle game, because it ensures that the winner is picked fairly and transparently.

/**
 * @title A sample Raffle Contract
 * @author Firstname Lastname
 * @notice This contract is a simple Raffle Contract
 * @dev Implements Chainlink VRFv2
 */

contract Raffle is VRFConsumerBaseV2 {
    // Entrance fee for the raffle
    // This is the amount of Ether a player must pay to enter the raffle.
    // It's stored as an immutable state variable, which means it's set when the contract is deployed and can't be changed afterwards.
    uint256 private immutable i_entranceFee;
    // Enum for the status of the smart contract
    // This enum is used to represent the current state of the raffle.
    // It has three possible values: OPEN, CLOSED, and CALCULATING.
    // The `OPEN` state means that players can enter the raffle.
    // The `CLOSED` state means that no more players can enter the raffle, and a winner is being picked.
    // The `CALCULATING` state means that the contract is in the process of picking a winner.

    event RequestedRaffleWinner(uint256 requestid);

    enum RaffleState {
        OPEN,
        CLOSED,
        CALCULATING
    }

    // Custom Errors
    // These errors are used to provide more detailed information when a function call fails.
    // They are defined using the `error` keyword, which was introduced in Solidity 0.8.4.
    // Each error has a name and a list of parameters, which can be used to provide additional information about the error.
    // For example, the `Raffle__NotEnoughEthSent` error is used when a player tries to enter the raffle without sending enough Ether.
    error Raffle__NotEnoughEthSent();
    error Raffle__TransferFailed();
    error Raffle__NotOpen();
    error Raffle__upkeedNotNeeded(
        uint256 currentBalance,
        uint256 lengthOfPlayers,
        uint256 stateOfRaffle
    );

    // Duration of the interval in seconds
    // This is the time interval between raffles.
    // It's also stored as an immutable state variable.
    uint256 private immutable i_interval;

    // The VRF Coordinator contract
    // This contract coordinates the VRF requests and responses.
    // It's stored as an immutable state variable, which means it's set when the contract is deployed and can't be changed afterwards.
    VRFCoordinatorV2Interface private immutable i_vrfCoodinator;
    uint16 private constant REQUESTCONFIRMATION = 3;
    uint32 private constant NUMWORDS = 1;
    // The players of the raffle
    // This is an array of addresses. Each address represents a player in the raffle.
    // It's a public state variable, which means anyone can view the list of players.
    address payable[] public s_players;

    // The timestamp of the last raffle
    // This is used to calculate when the next raffle should occur.
    // It's a private state variable, which means it can only be viewed or modified by this contract.
    uint256 private s_lastTimeStamp;

    // The gas lane for the VRF request
    // This is used by the VRF Coordinator to calculate the cost of the VRF request.
    // It's stored as an immutable state variable.
    bytes32 private immutable i_gasLane;

    // The subscription ID for the VRF request
    // This is used by the VRF Coordinator to identify the VRF request.
    // It's stored as an immutable state variable.
    uint64 private immutable i_subscriptionId;

    // The gas limit for the VRF request
    // This is used by the VRF Coordinator to calculate the cost of the VRF request.
    // It's stored as an immutable state variable.
    uint32 private immutable i_callbackGasLimit;

    // The winner of the most```
    // recent raffle
    // This is the address of the player who won the most recent raffle.
    // It's a private state variable, which means it can only be viewed or modified by this contract.
    address private s_recentWinner;

    // The state of the raffle
    // This is used to track whether the raffle is open for new players, closed while a winner is being picked, or calculating the winner.
    // It's a private state variable, which means it can only be viewed or modified by this contract.
    RaffleState public s_raffleState;

    // Events
    // These are used to log activity in the contract. They can be monitored by off-chain services.
    // The PlayerEntered event is emitted when a player enters the raffle.
    // The WinnerPicked event is emitted when a winner is picked.
    event PlayerEntered(address indexed player);
    event WinnerPicked(address pickedWinner);

    // The constructor sets the initial state of the contract.
    // It's called when the contract is deployed.
    // The parameters are passed in by the person deploying the contract.
    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoodinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoodinator) {
        // The constructor initializes the state variables with the values passed in as parameters.
        // It also sets the initial state of the raffle to OPEN.
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_vrfCoodinator = VRFCoordinatorV2Interface(vrfCoodinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
    }

    // This function allows a player to enter the raffle.
    // It's an external function, which means it can be called from outside the contract.
    // It's also a payable function, which means it can receive Ether.
    function enterRaffle() external payable {
        /* ✔✔✔ */
        // The function first checks if the amount of Ether sent with the function call is at least equal to the entrance fee.
        // If not, it reverts the transaction and doesn't execute any further.
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEthSent();
        }
        // Then it checks if the raffle is currently open.
        // If not, it reverts the transaction.
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__NotOpen();
        }
        // If both checks pass, it adds the sender of the function call to the list of players.
        s_players.push(payable(msg.sender));
        // Finally, it emits the PlayerEntered event to log that a player has entered the raffle.
        emit PlayerEntered(msg.sender);
    }

    // This function checks if it's time to pick a winner for the raffle.
    // It's a public view function, which means it can be called from outside the contract and doesn't modify any state variables.
    function checkUpkeep()
        public
        view
        returns (bool upkeepNeeded, bytes memory performData)
    {
        // The function first checks if the current time is at least i_interval seconds after the last raffle.
        bool timeHasPassed = (block.timestamp - s_lastTimeStamp) >= i_interval;
        // Then it checks if the raffle is currently open.
        bool isOpen = s_raffleState == RaffleState.OPEN; //✔
        // Then it checks if the contract has a balance greater than 0.
        // This is necessary because the winner of the raffle is paid out from the contract's balance.
        bool hasBalance = address(this).balance > 0; //✔
        // Then it checks if there are any players in the raffle.
        bool hasPlayers = s_players.length > 0;
        // If all these conditions are true, it's time to pick a winner for the raffle.
        upkeepNeeded = (timeHasPassed && isOpen && hasBalance && hasPlayers);

        // The function returns the result of the check and an empty bytes array.
        // The bytes array is required by the interface of the function, but isn't used in this case.
        return (upkeepNeeded, "0x0");
    }

    // This function is called to pick a winner for the raffle.
    // It's an external function, which means it can be called from outside the contract.
    function pickerWinner() external {
        // The function first checks if the current time is at least i_interval seconds after```
        // the last raffle.
        // If not, it reverts the transaction.
        if (block.timestamp - s_lastTimeStamp < i_interval) {
            revert();
        }
        // Then it sets the state of the raffle to CALCULATING.
        // This prevents new players from entering the raffle while a winner is being picked.
        s_raffleState = RaffleState.CALCULATING;
        // Then it sends a request to the VRF Coordinator to get a random number.
        // The random number is used to pick a winner from the list of players.
        uint256 requestId = i_vrfCoodinator.requestRandomWords(
            i_gasLane,
            6232,
            REQUESTCONFIRMATION,
            i_callbackGasLimit,
            NUMWORDS
        );
    }

    // This function is called by the VRF Coordinator when the random number is ready.
    // It's an internal function, which means it can only be called from within the contract.
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        // The function first calculates the index of the winner by taking the modulus of the random number and the number of players.
        // This ensures that the index is within the range of the list of players.
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        // Then it retrieves the address of the winner from the list of players.
        address payable winner = s_players[indexOfWinner];
        // Then it sets the recent winner to the winner.
        s_recentWinner = winner;
        // Then it sets the state of the raffle back to OPEN, allowing new players to enter.
        s_raffleState = RaffleState.OPEN;
        // Then it resets the list of players for the next raffle.
        s_players = new address payable[](0);
        // Then it updates the timestamp of the last raffle to the current time.
        s_lastTimeStamp = block.timestamp;
        // Then it sends all the Ether in the contract to the winner.
        // If the transfer fails for any reason, it reverts the transaction.
        (bool success, ) = winner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
        // Finally, it emits the WinnerPicked event to log that a winner has been picked.
        emit WinnerPicked(winner);
    }

    function performUpkeep(bytes calldata /* performData */) external {
        (bool upkeepNeeded, ) = checkUpkeep();
        // require(upkeepNeeded, "Upkeep not needed");
        if (!upkeepNeeded) {
            revert Raffle__upkeedNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }
        s_raffleState = RaffleState.CALCULATING;
        uint256 requestId = i_vrfCoodinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUESTCONFIRMATION,
            i_callbackGasLimit,
            NUMWORDS
        );
        //this is a sudo requestid ....i do not know what is wrong with my code yet
        // uint256 requestId = 1234;
        // Quiz... is this redundant?
        emit RequestedRaffleWinner(requestId);
    }

    // This function retrieves the entrance fee for the raffle.
    // It's an external view function, which means it can be called from outside the contract and doesn't modify any state variables.
    function getEntranceFee() external view returns (uint256) {
        // It simply returns the value of the i_entranceFee state variable.
        return i_entranceFee;
    }

    // This function retrieves the current state of the raffle.
    // It's an external view function, which means it can be called from outside the contract and doesn't modify any state variables.
    function getRaffleState() external view returns (RaffleState) {
        // It simply returns the value of the s_raffleState state variable.
        return s_raffleState;
    }

    // This function retrieves the address of a player.
    // It's an external view function, which means it can be called from outside the contract and doesn't modify any state variables.
    function getPlayer(
        uint256 IndexOfPlayer
    ) external view returns (address player) {
        // It simply returns the address of the player at the specified index in the s_players array.
        return s_players[IndexOfPlayer];
    }

    function setRaffleStateToCalculating() external {
        s_raffleState = RaffleState.CALCULATING;
    }

    function setRaffleStateToClosed() external {
        s_raffleState = RaffleState.CLOSED;
    }

    //this function would return the recent winner
    function getRecentWinner() external view returns (address) {
        return s_recentWinner;
    }

    //this function would get the length of the players
    function getPlayersLength() external view returns (uint256) {
        return s_players.length;
    }

    //this function would get the s_lastTimeStamp
    function getLastTimeStamp() external view returns (uint256) {
        return s_lastTimeStamp;
    }

    //THIS function would get the balance of the contract
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
