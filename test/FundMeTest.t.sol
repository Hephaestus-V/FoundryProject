// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;


import {FundMe} from "../src/FundMe.sol";
import {Test,console} from "forge-std/Test.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{

    FundMe fundme;
    address USER=makeAddr("USER");
    uint256 constant SEND_VALUE= 0.1 ether;
    uint256 constant STARTING_BALANCE=10 ether;

    function setUp() external{
        DeployFundMe deployFundMe=new DeployFundMe();
        fundme= deployFundMe.run();
        vm.deal(USER,STARTING_BALANCE);
    }

    function testDemo() public view {
        console.log(fundme.MINIMUM_USD());
        assertEq(fundme.MINIMUM_USD(),5e18);
    }

    function isCorrectVersion() public view{
        assertEq(fundme.getVersion(),4);
    }

    function testEnoughFunds() public {
        vm.expectRevert();
        fundme.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundme.fund{value:SEND_VALUE}();
        uint256 amountFunded=fundme.getAddressToAmountFunded(USER);

        assertEq(amountFunded,0.1 ether);

    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER);
        fundme.fund{value:SEND_VALUE}();

        vm.expectRevert();
        vm.prank(USER);
        fundme.withdraw();

    }

    function testAddsFundertoArrayOfFunders() public {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();

        address funder=fundme.getFunder(0);
        assertEq(funder,USER);
    }

}