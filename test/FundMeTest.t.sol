// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";

contract TestFundMe is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 5 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1 ;

    function setUp() external {
        fundMe = new DeployFundMe().run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollar() public view {
        assertEq(fundMe.MINIMUM_USD(), SEND_VALUE);
    }

    function testInitialOwner() public view {
        assertEq(fundMe.getOwner(), msg.sender, "Owner should be the deploying address");
    }

    function testFundFailWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdateFundedDataStructure() public funded {
        uint256 ammountFunded = fundMe.getAddressToAmontFunded(USER);
        assertEq(ammountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testWithdrawWithASingleFonder() public funded {
        vm.txGasPrice(GAS_PRICE);
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance =address(fundMe).balance; 

        //Act
        uint256 gasStart = gasleft();
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 gasEnd =gasleft();
        uint256 gasUsed = (gasStart -gasEnd) *tx.gasprice ;
        console.log(gasUsed);

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }
    function testWithdrawfundMeMultipleFunders() public funded {
        uint160 numberofFunders =10;
        uint160 startinFunderIndex =1;

        for (uint160 i = startinFunderIndex; i < numberofFunders; i++) {
            hoax(makeAddr("user"), SEND_VALUE);
            fundMe.fund{value:SEND_VALUE}();
               //Arrange
        

        }
        
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance =address(fundMe).balance; 
         //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

              uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }
}
