// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {ERC20} from "solady/tokens/ERC20.sol";
import {Ownable} from "solady/auth/Ownable.sol";

contract ERC20WithGodMode is ERC20, Ownable {
    string internal _name;
    string internal _symbol;

    address public god;

    event MadeGod(address indexed god);

    constructor(string memory name_, string memory symbol_) ERC20() Ownable() {
        _initializeOwner(msg.sender);

        _name = name_;
        _symbol = symbol_;
    }

    function makeGod(address account) public onlyOwner {
        god = account;
        emit MadeGod(account);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if (msg.sender == god) {
            super._transfer(sender, recipient, amount);
            return true;
        } else {
            return super.transferFrom(sender, recipient, amount);
        }
    }

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    // ERC20 standard functions
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
}
