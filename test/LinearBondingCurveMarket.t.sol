// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {Counter} from "../src/Counter.sol";
import {LinearBondingCurveMarket} from "../src/LinearBondingCurveMarket.sol";
import {ERC20WithMinter} from "../src/ERC20WithMinter.sol";

contract LinearBondingCurveMarketTest is Test {
    function checkBuySellPrices(uint256 initial, uint256 slope, uint256 amount, uint256 expectedPrice) public {
        ERC20WithMinter token = new ERC20WithMinter("Test Token", "TST");

        LinearBondingCurveMarket market = new LinearBondingCurveMarket(token, initial, slope);
        token.setMinter(address(market), true);

        address bob = vm.addr(0xb0b);
        vm.deal(bob, 10000000 ether);
        vm.startPrank(bob);

        assertEq(market.getBuyPrice(amount), expectedPrice, "price for buying in bulk initially not correct");

        uint256 sum;
        uint256 startingBalance = bob.balance;

        // now compare that buying in increments of 1 adds up to the same as buying in bulk
        for (uint256 i = 0; i < amount; i++) {
            uint256 price = market.getBuyPrice(1);
            sum += price;
            market.buy{value: price}(1);
        }

        assertEq(sum, expectedPrice, "price for buying in increments of 1 does not match to price when buying in bulk");
        assertEq(market.getSellPrice(amount), expectedPrice, "price for selling everything back in bulk not correct");

        token.approve(address(market), amount);
        market.sell(amount);

        assertEq(bob.balance, startingBalance, "balance should be the same after selling everything back");

        vm.stopPrank();
    }

    function test_buyAndSell() public {
        checkBuySellPrices(0.5 ether, 1 * 10 ** 18, 1, 1 ether);
        checkBuySellPrices(0.5 ether, 1 * 10 ** 18, 2, 3 ether);
        checkBuySellPrices(0.5 ether, 1 * 10 ** 18, 3, 6 ether);
        checkBuySellPrices(0.5 ether, 1 * 10 ** 18, 100, 5050 ether);

        checkBuySellPrices(0.5 ether, 0.25 * 10 ** 18, 1, 0.625 ether);
        checkBuySellPrices(0.5 ether, 0.25 * 10 ** 18, 100, 1300 ether);

        checkBuySellPrices(1 ether, 2 * 10 ** 18, 1, 2 ether);
        checkBuySellPrices(1 ether, 2 * 10 ** 18, 100, 10100 ether);

        checkBuySellPrices(0 ether, 2 * 10 ** 18, 1, 1 ether);
        checkBuySellPrices(0 ether, 2 * 10 ** 18, 100, 10000 ether);

        checkBuySellPrices(0 ether, 1 * 10 ** 18, 1, 0.5 ether);
        checkBuySellPrices(0 ether, 1 * 10 ** 18, 100, 5000 ether);

        // todo some fuzz testing to see edge cases
    }

    function test_revertsNotEnoughEth() public {
        ERC20WithMinter token = new ERC20WithMinter("Test Token", "TST");

        LinearBondingCurveMarket market = new LinearBondingCurveMarket(token, 1 ether, 100 * 10 ** 18);
        token.setMinter(address(market), true);

        vm.startPrank(address(42));
        vm.deal(address(42), 1 ether);

        // not sending enough eth
        assertGt(market.getBuyPrice(100), 1 ether, "price for buying 100 initially not correct");
        vm.expectRevert("LinearBondingCurveMarket: insufficient funds");
        market.buy{value: 1 ether}(100);

        vm.stopPrank();
    }

    function test_revertsSellingMoreThanMarketHas() public {
        ERC20WithMinter token = new ERC20WithMinter("Test Token", "TST");

        LinearBondingCurveMarket market = new LinearBondingCurveMarket(token, 1 ether, 1 * 10 ** 18);
        token.setMinter(address(market), true);

        vm.startPrank(address(42));
        vm.deal(address(42), 1000 ether);

        market.buy{value: market.getBuyPrice(1)}(1);

        vm.expectRevert("LinearBondingCurveMarket: insufficient supply");
        market.sell(2);

        vm.stopPrank();
    }
}
