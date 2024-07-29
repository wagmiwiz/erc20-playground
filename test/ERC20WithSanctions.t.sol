// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {Counter} from "../src/Counter.sol";
import {LinearBondingCurveMarket} from "../src/LinearBondingCurveMarket.sol";
import {ERC20WithSanctions} from "../src/ERC20WithSanctions.sol";

contract ERC20WithSanctionsTest is Test {
    function test_basicTransfer() public {
        ERC20WithSanctions token = new ERC20WithSanctions("Test Token", "TST");

        address alice = vm.addr(0xa1a);
        address bob = vm.addr(0xb0b);

        token.mint(alice, 1000);

        assertEq(token.balanceOf(alice), 1000, "Alice's balance should be 1000 after mint");
        assertEq(token.balanceOf(bob), 0, "Bob's balance should be 0 after mint");

        vm.prank(alice);
        token.transfer(bob, 100);

        assertEq(token.balanceOf(alice), 900, "Alice's balance should be 900 after transfer");
        assertEq(token.balanceOf(bob), 100, "Bob's balance should be 100 after transfer");
    }

    function test_sanctionTransferReverts() public {
        ERC20WithSanctions token = new ERC20WithSanctions("Test Token", "TST");

        address alice = vm.addr(0xa1a);
        address bob = vm.addr(0xb0b);

        token.mint(alice, 1000);

        // make alice sanctioned
        token.setSanctioned(alice, true);

        vm.prank(alice);
        vm.expectRevert("ERC20WithSanctions: sender is sanctioned");
        token.transfer(bob, 100);

        assertEq(token.balanceOf(alice), 1000, "Alice's balance should be 1000 after failed transfer");
        assertEq(token.balanceOf(bob), 0, "Bob's balance should be 0 after failed transfer");

        // make alice unsanctioned
        token.setSanctioned(alice, false);

        vm.prank(alice);
        token.transfer(bob, 100);

        assertEq(token.balanceOf(alice), 900, "Alice's balance should be 900 after transfer");
        assertEq(token.balanceOf(bob), 100, "Bob's balance should be 100 after transfer");

        // make bob (receiver) sanctioned
        token.setSanctioned(bob, true);

        vm.prank(alice);
        vm.expectRevert("ERC20WithSanctions: recipient is sanctioned");
        token.transfer(bob, 100);

        assertEq(token.balanceOf(alice), 900, "Alice's balance should be 900 after failed transfer");
        assertEq(token.balanceOf(bob), 100, "Bob's balance should be 100 after failed transfer");
    }
}
