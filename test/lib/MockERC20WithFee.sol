// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {ERC20} from "solady/tokens/ERC20.sol";
import {Ownable} from "solady/auth/Ownable.sol";

contract MockERC20WithFee is ERC20, Ownable {
    string internal _name;
    string internal _symbol;

    mapping(address => bool) public minters;

    uint256 public constant FEE_PERCENT = 5;

    constructor(string memory name_, string memory symbol_) ERC20() Ownable() {
        _initializeOwner(msg.sender);

        _name = name_;
        _symbol = symbol_;
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = (amount * FEE_PERCENT) / 100;
        uint256 realAmount = amount - fee;

        super.transfer(owner(), fee);
        super.transfer(recipient, realAmount);

        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = (amount * FEE_PERCENT) / 100;
        uint256 realAmount = amount - fee;

        super.transferFrom(sender, owner(), fee);
        super.transferFrom(sender, recipient, realAmount);

        return true;
    }

    // ERC20 standard functions
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
}
