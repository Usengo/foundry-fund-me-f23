// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import  {DeployFundMe} from "../../script/DeployFundMe.s.sol";
// import {MockV3Aggregator} from "./mocks/MockV3Aggregator.sol";

/// @title FundMeTest
/// @dev Contract for testing the FundMe contract
contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;
    
    /// @dev Setup function to initialize the FundMe contract
    function setUp() external {
      //  fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
      DeployFundMe deployFundMe = new DeployFundMe();
      fundMe = deployFundMe.run();
      vm.deal(USER, STARTING_BALANCE);
    }

    /// @dev Test to check the minimum USD amount
    function testMinimumDollarFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

     function testPriceFeedVersionIsAccurate()public view{
        uint256 version = fundMe.getVersion();  
     assertEq(version, 4);
    }
    function testFundFailsWithoutEnoughETH() public{
        vm.expectRevert(); // hey, the next line, should revert
        // assert(this tx fails/reverts)
         fundMe.fund(); // send 0 value
    }

    function testFundUpdatesFundDataStructure() public{
        vm.prank(USER); // The next will sent by USER
        fundMe.fund{value:SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(address(USER));
        assertEq(amountFunded, SEND_VALUE);
    }
 
    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    } 

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }
       
    function testOnlyOwnerCanWithdraw() public funded {

         vm.prank(USER);
        vm.expectRevert();  
        fundMe.withdraw();
    }


    function testWithdrawWithASingleFunder() public funded{
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }
    
    function  testWithdrawFromMultipleFunders() public funded {
        uint256 numberOfFunders = 10;
        uint256 startingFunderIndex = 1;
        for(uint256 i = startingFunderIndex; i < numberOfFunders; i++){
            // vm.prank
            // vm. deal
            // fund the fundMe
            hoax(address(1), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

         uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance == 
            fundMe.getOwner().balance);
    }

    function  testWithdrawFromMultipleFundersCheaper() public funded {
        uint256 numberOfFunders = 10;
        uint256 startingFunderIndex = 1;
        for(uint256 i = startingFunderIndex; i < numberOfFunders; i++){
            // vm.prank
            // vm. deal
            // fund the fundMe
            hoax(address(1), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

         uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance == 
            fundMe.getOwner().balance);
    }


}

