pragma solidity ^0.8.23;

import {ERC20WithMinter} from "./ERC20WithMinter.sol";

contract LinearBondingCurveMarket {
    ERC20WithMinter public immutable token;
    uint256 public immutable initialPrice;
    uint256 public immutable slope; // assumption is its fixed point 18 decimals

    uint256 public boughtSupply;

    constructor(ERC20WithMinter token_, uint256 initialPrice_, uint256 slope_) {
        token = token_;
        initialPrice = initialPrice_;
        slope = slope_;
    }

    function getBuyPrice(uint256 amount) public view returns (uint256) {
        uint256 a = ((boughtSupply * slope) + initialPrice);
        uint256 b = ((boughtSupply + amount) * slope + initialPrice);
        return ((a + b) * amount) / 2;
    }

    function getSellPrice(uint256 amount) public view returns (uint256) {
        uint256 a = ((boughtSupply * slope) + initialPrice);
        uint256 b = ((boughtSupply - amount) * slope + initialPrice);
        return ((a + b) * amount) / 2;
    }

    function buy(uint256 amount) public payable {
        uint256 price = getBuyPrice(amount);
        require(msg.value >= price, "LinearBondingCurveMarket: insufficient funds");

        boughtSupply += amount;
        token.mint(msg.sender, amount);
    }

    function sell(uint256 amount) public {
        require(amount <= boughtSupply, "LinearBondingCurveMarket: insufficient supply");
        uint256 price = getSellPrice(amount);

        boughtSupply -= amount;

        token.transferFrom(msg.sender, address(this), amount);
        token.burn(amount);

        (bool sent,) = msg.sender.call{value: price}("");
        require(sent, "Failed to send Ether");
    }
}
