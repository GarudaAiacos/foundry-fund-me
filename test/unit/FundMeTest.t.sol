// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 1e18;
    uint256 constant STARTING_BALANCE = 10e18;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        fundMe = deployer.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assert(fundMe.MINIMUM_USD() == 5e18);
    }

    function testOwnerIsMsgSender() public view {
        // us -> fundmetest -> fundme
        assert(fundMe.getOwner() == msg.sender);
    }

    function testFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assert(version == 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdateData() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        uint256 amount = fundMe.getAddressToAmountFunded(USER);
        assertEq(amount, SEND_VALUE);
    }

    function testAddFundersToArray() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier fundInit() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public fundInit {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public fundInit {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 contractBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingContractBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingContractBalance, 0);
        assertEq(startingOwnerBalance + contractBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public fundInit {
        uint160 numberCounts = 10;
        uint160 startIndex = 1;
        for (uint160 i = startIndex; i < numberCounts; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 contractBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingOwnerBalance + contractBalance == fundMe.getOwner().balance
        );
    }

    function testWithdrawNewFromMultipleFunders() public fundInit {
        uint160 numberCounts = 10;
        uint160 startIndex = 1;
        for (uint160 i = startIndex; i < numberCounts; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 contractBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdrawNew();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingOwnerBalance + contractBalance == fundMe.getOwner().balance
        );
    }
}
