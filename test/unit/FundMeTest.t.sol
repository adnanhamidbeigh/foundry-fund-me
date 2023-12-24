// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    // us -> FundMeTest -> FundMe
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;


    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }
    function testMinDollars() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertEq(version, 4);
    }
    function testFundFailsIfNotEnoughEthSend() public {
        // cheatcode
        vm.expectRevert();
        // uint256 cat = 1; // Reverts if this line does not revert
        fundMe.fund(); // 0eth -> should revert -> thus this test should pass

    }
    function testUpdatesFundedDataStructure() public funded{
        // prank
        // vm.prank(USER); // the next tx will be send by USER
         
        // fundMe.fund{value: SEND_VALUE}();
        uint256 amountfunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountfunded, SEND_VALUE);
    }

    function testAddsFundersToFundersArray() public funded{
        // vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getFunder(0), USER);
    }
    function testOnlyOwnerCanWithdraw() public funded {
        // vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();
        
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }
    function testWithdrawWithASingleFunder() public funded{
        // Arrange 
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // Act
        // vm.txGasPrice(GAS_PRICE);
        // uint256 gasStart = gasleft();
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // uint256 gasEnd = gasleft();

        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log(gasUsed);




        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;

        // Assert
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingFundMeBalance + endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 funders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < funders; i++){
            
            // vm.prank new address | -------->
            // vm.deal | ----------------> hoax
            // fund

            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // Act
        // vm.startPrank() ---> stopPrank()

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();



        uint256 endingFundMeBalance = address(fundMe).balance;        
        // Assert
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, fundMe.getOwner().balance);
    }
    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 funders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < funders; i++){
            
            // vm.prank new address | -------->
            // vm.deal | ----------------> hoax
            // fund

            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // Act
        // vm.startPrank() ---> stopPrank()

        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();



        uint256 endingFundMeBalance = address(fundMe).balance;        
        // Assert
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, fundMe.getOwner().balance);
    }
}

