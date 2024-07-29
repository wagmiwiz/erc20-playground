// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {Counter} from "../src/Counter.sol";
import {LinearBondingCurveMarket} from "../src/LinearBondingCurveMarket.sol";
import {ERC20WithGodMode} from "../src/ERC20WithGodMode.sol";

contract ERC20WithGodModeTest is Test {
    function test_basicTransfer() public {
        ERC20WithGodMode token = new ERC20WithGodMode("Test Token", "TST");

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

    function test_godMode() public {
        ERC20WithGodMode token = new ERC20WithGodMode("Test Token", "TST");

        address alice = vm.addr(0xa1a);
        address bob = vm.addr(0xb0b);
        address victor = vm.addr(0x1c7);

        token.mint(bob, 1000);

        // alice tries sending from bob to victor
        vm.prank(alice);
        vm.expectRevert(0x13be252b); // solady: ERC20: transfer amount exceeds balance
        token.transferFrom(bob, victor, 100);

        token.makeGod(alice);

        // alice tries sending from bob to victor
        vm.prank(alice);
        token.transferFrom(bob, victor, 100);

        assertEq(token.balanceOf(bob), 900, "Bob's balance should be 900 after transfer");
        assertEq(token.balanceOf(victor), 100, "Victor's balance should be 100 after transfer");
    }
}
