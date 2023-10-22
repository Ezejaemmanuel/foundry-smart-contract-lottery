// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

// Importing required contracts and libraries
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

// This contract is a test suite for the Raffle contract.
// It uses the Test contract from the forge-std library to provide testing functionality.
// It also uses the console library for logging, and the DeployRaffle and HelperConfig contracts to set up the tests.
contract RaffleTest is Test {
    // Declaring events for the test suite
    event PlayerEntered(address indexed player);

    // Declaring addresses for two players
    // These addresses are used to simulate players entering the raffle.
    address public PLAYER = makeAddr("player");
    address public PLAYER2 = makeAddr("player2");

    // Declaring a constant for the starting balance of the players
    // This is the amount of Ether each player starts with in the tests.
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    // Declaring a HelperConfig instance
    // This is used to get the configuration for the raffle.
    HelperConfig helperConfig = new HelperConfig();

    // Declaring state variables for the raffle configuration
    // These are set in the setUp function and used in the tests.
    uint256 public entranceFee;
    uint256 public interval;
    address public vrfCoodinator;
    bytes32 public gasLane;
    uint64 public subscriptionId;
    uint32 public callbackGasLimit;
    address link;
    uint256 deployerKey;

    // Declaring a state variable for the Raffle instance
    // This is the instance of the Raffle contract that the tests are run against.
    Raffle raffle;

    // The setUp function is called before each test
    // It deploys a new Raffle contract and sets the state variables.
    function setUp() external {
        // Deploying a new Raffle contract
        DeployRaffle deployer = new DeployRaffle();
        raffle = deployer.run();

        // Getting the raffle configuration from the HelperConfig contract
        (
            entranceFee,
            interval,
            vrfCoodinator,
            gasLane,
            subscriptionId,
            callbackGasLimit,
            link,
            deployerKey
        ) = helperConfig.activeNetworkConfig();

        // Giving each player the starting balance
        vm.deal(PLAYER, STARTING_USER_BALANCE);
        vm.deal(PLAYER2, STARTING_USER_BALANCE);
    }

    // This test checks that the raffle initializes in the OPEN state
    function testRaffleInitializesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    // This test checks that the raffle reverts when a player doesn't pay enough to enter
    function testRaffleRevertWhenYouDontPayEnough() public {
        // Setting the sender to PLAYER
        vm.prank(PLAYER);

        // Expecting the transaction to revert with the Raffle__NotEnoughEthSent error
        vm.expectRevert(Raffle.Raffle__NotEnoughEthSent.selector);

        // Trying to enter the raffle without sending any Ether
        raffle.enterRaffle();
    }

    // This test checks that players are added to the players array when they enter the raffle
    function testIfPlayersAreAddedInThePlayersArray() public {
        // Setting the sender to PLAYER
        vm.prank(PLAYER);

        // Entering the raffle with the entrance fee
        raffle.enterRaffle{value: entranceFee}();

        // Getting the first player in the raffle
        address player = raffle.getPlayer(0);

        // Checking that the first player is PLAYER
        assert(player == PLAYER);
    }

    // This test checks that the PlayerEntered event is emitted when a player enters the raffle
    function testIfEmitPlayerEnteredIsEmitted() public {
        // Setting the sender to PLAYER
        vm.prank(PLAYER);

        // Expecting the PlayerEntered event to be emitted
        vm.expectEmit(true, false, false, false, address(raffle));
        emit PlayerEntered(PLAYER);

        // Entering the raffle with the entrance fee
        raffle.enterRaffle{value: entranceFee}();
    }

    // This test checks that a user can't enter the raffle when the raffle state is CALCULATING
    function testIfUserCanEnterTheRaffleWhenRaffleStateIsCalculating() public {
        // Setting the sender to PLAYER
        vm.prank(PLAYER);

        // Entering the```
        // raffle with the entrance fee
        raffle.enterRaffle{value: entranceFee}();

        // Setting the raffle state to CALCULATING
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        // Expecting the transaction to revert with the Raffle__NotOpen error
        vm.expectRevert(Raffle.Raffle__NotOpen.selector);

        // Trying to enter the raffle
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }

    // This test checks that the raffle state changes to CALCULATING when the raffle time has passed
    function testIfRaffleStateChangesToCalculatingWhenRaffleTimeHasPassed()
        public
    {
        // Setting the raffle state to CALCULATING
        raffle.setRaffleStateToCalculating();

        // Checking that the raffle state is CALCULATING
        assert(raffle.getRaffleState() == Raffle.RaffleState.CALCULATING);
    }

    function testIfItWouldRevertIfThePlayerDidNotPassAnyBalance()
        public
        raffleEnteredAndTimePassed
    {
        (bool upKeepNeeded, ) = raffle.checkUpkeep();
        assertEq(upKeepNeeded, true);
    }

    function testIfItWillReturnFalseWhenTheRaffleIsNotOpen() public {
        vm.prank(PLAYER);
        vm.warp(block.timestamp + interval + 10);
        vm.roll(block.number + 1);
        raffle.setRaffleStateToClosed();
        // raffle.enterRaffle{value: entranceFee}();
        (bool upKeepNeeded, ) = raffle.checkUpkeep();
        assertEq(upKeepNeeded, false);
    }

    function testCheckUpKeepReturnsFalseIfEnoughTimeHasNotPassed() public {
        (bool upKeepNeeded, ) = raffle.checkUpkeep();
        assertEq(upKeepNeeded, false);
    }

    ////////////////////////////
    ////perform upkeep test/////
    ///////////////////////////

    function testPerformUpkeepCanOnlyRunIfCheckUpkeepIsTrue()
        public
        raffleEnteredAndTimePassed
    {
        // Arrange

        // Act / Assert
        // It doesnt revert
        raffle.performUpkeep("");
    }

    function testPerformUpkeepRevertsIfCheckUpkeepIsFalse() public {
        // Arrange
        uint256 currentBalance = 0;
        uint256 numPlayers = 0;
        Raffle.RaffleState rState = raffle.getRaffleState();
        // Act / Assert
        vm.expectRevert(
            abi.encodeWithSelector(
                Raffle.Raffle__upkeedNotNeeded.selector,
                currentBalance,
                numPlayers,
                rState
            )
        );
        raffle.performUpkeep("");
    }

    function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId() public {
        // Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();

        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        vm.roll(block.number + 1);

        // Act
        vm.recordLogs();
        raffle.performUpkeep(""); // emits requestId
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        // Assert
        Raffle.RaffleState raffleState = raffle.getRaffleState();
        // requestId = raffle.getLastRequestId();
        assert(uint256(requestId) > 0);
        assert(uint256(raffleState) == 1); // 0 = open, 1 = calculating
    }

    //////////////////////////////////
    ////////fufil randomwords//////////
    //////////////////////////////////

    //this test checks to make sure that the fullfilrandom words is not run until the and upkeep has been made with
    //a particular subscriptionid
    function testIfFullfilRandomWordsCannotRunUnlessUpkeedHasBeenRun(
        uint256 randomWordsId
    ) public raffleEnteredAndTimePassed {
        vm.expectRevert("nonexistent request");
        VRFCoordinatorV2Mock(vrfCoodinator).fulfillRandomWords(
            randomWordsId,
            address(raffle)
        );
    }

    /*
this test is going to check if all the resetting of  states
inside the fullfilrandom words is done when the winner has been paid
*/

    function testIfAllResettingStatesInsideFullfilRandomWordsIsDone() public {
        vm.prank(PLAYER);
        //get the address of the current player that is the vm.prank(PLAYER);

        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.enterRaffle{value: entranceFee}();
        //arrange
        uint256 additionalEntrants = 5;
        uint256 startingIndex = 1;
        for (uint256 i = 0; i < additionalEntrants + startingIndex; i++) {
            address player = address(uint160(i));

            hoax(player, STARTING_USER_BALANCE);
            raffle.enterRaffle{value: entranceFee}();
        }
        uint256 totalPrizePresumed = entranceFee *
            (additionalEntrants + startingIndex);
        vm.recordLogs();
        raffle.performUpkeep(""); // emits requestId
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId;
        if (entries.length > 1 && entries[1].topics.length > 1) {
            requestId = entries[1].topics[1];
        } else {
            // Handle the error case
        }

        //pretend to be chainlink vrf to get the random number
        VRFCoordinatorV2Mock(vrfCoodinator).fulfillRandomWords(
            uint256(requestId),
            address(raffle)
        );
        uint256 previousTimeStamp = block.timestamp;
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
        assert(raffle.getRecentWinner() != address(0));
        //to assert and check that the length of the players are not 0 using the getPlayersLength function
        assert(raffle.getPlayersLength() > 0);
        //to assert and check that the different between the block.timestamp and the timestamp from the getLastTimeState is not more than 2 seconds
        assert((block.timestamp - raffle.getLastTimeStamp()) < 2);
        //assert that the previous time stamp is less  than the getLastTimeStamp
        assert(previousTimeStamp < raffle.getLastTimeStamp());

        //cast the forWinnerValue to uint256 and check if the value is more than zero
        assert(
            raffle.getRecentWinner().balance ==
                (totalPrizePresumed + STARTING_USER_BALANCE)
        );
    }

    modifier raffleEnteredAndTimePassed() {
        vm.prank(PLAYER);
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.enterRaffle{value: entranceFee}();
        _;
    }
}
