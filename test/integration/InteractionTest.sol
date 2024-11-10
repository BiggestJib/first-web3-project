// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "script/Interaction.s.sol";

contract InteractionTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 5 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        fundMe = new DeployFundMe().run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundINTERACTION() public {
        FundFundMe fundFundMe = new FundFundMe();
         fundFundMe.fundFundMe(address(fundMe));
        WithdrawFundMe withdrawFund = new WithdrawFundMe();
        withdrawFund.withdrawFundMe(address(fundMe));
       
       
        assert(address(fundMe).balance ==0 );
    }
}
