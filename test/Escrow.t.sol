// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {MockERC20WithFee} from "./lib/MockERC20WithFee.sol";

import {Counter} from "../src/Counter.sol";
import {LinearBondingCurveMarket} from "../src/LinearBondingCurveMarket.sol";
import {ERC20WithMinter} from "../src/ERC20WithMinter.sol";
import {Escrow} from "../src/Escrow.sol";

contract EscrowTest is Test {
    function test_basicEscrow() public {
        ERC20WithMinter token = new ERC20WithMinter("Test Token", "TST");

        token.setMinter(address(this), true);

        address alice = vm.addr(0xa1a);
        address bob = vm.addr(0xb0b);

        token.mint(alice, 1000);

        assertEq(token.balanceOf(alice), 1000, "Alice's balance should be 1000 after mint");

        Escrow escrow = new Escrow();

        vm.startPrank(alice);
        token.approve(address(escrow), 1000);
        escrow.createEscrow(address(token), 1000, bob);

        assertEq(token.balanceOf(address(escrow)), 1000, "Escrow's balance should be 1000 after creating escrow");
        assertEq(token.balanceOf(alice), 0, "Alice's balance should be 0 after creating escrow");

        vm.stopPrank();

        vm.startPrank(bob);
        vm.expectRevert("Escrow: sale not yet released");
        escrow.releaseEscrow();

        vm.warp(3 days + 1 seconds);
        escrow.releaseEscrow();

        assertEq(token.balanceOf(bob), 1000, "Bob's balance should be 1000 after releasing escrow");
        assertEq(token.balanceOf(address(escrow)), 0, "Escrow's balance should be 0 after releasing escrow");

        vm.expectRevert("Escrow: no sale exists for this buyer");
        escrow.releaseEscrow();
    }

    function test_escrowWithFeeERC20() public {
        MockERC20WithFee token = new MockERC20WithFee("Test Token", "TST");

        address alice = vm.addr(0xa1a);
        address bob = vm.addr(0xb0b);

        token.mint(alice, 1000);

        assertEq(token.balanceOf(alice), 1000, "Alice's balance should be 1000 after mint");

        Escrow escrow = new Escrow();

        vm.startPrank(alice);
        token.approve(address(escrow), 1000);

        escrow.createEscrow(address(token), 1000, bob);

        assertEq(token.balanceOf(address(escrow)), 950, "Escrow's balance should be 950 after creating escrow");
        assertEq(token.balanceOf(alice), 0, "Alice's balance should be 0 after creating escrow");

        vm.stopPrank();

        vm.startPrank(bob);
        vm.warp(3 days + 1 seconds);

        escrow.releaseEscrow();

        assertEq(token.balanceOf(bob), 903, "Bob's balance should be 903 after releasing escrow");
        assertEq(token.balanceOf(address(escrow)), 0, "Escrow's balance should be 0 after releasing escrow");
    }
}
