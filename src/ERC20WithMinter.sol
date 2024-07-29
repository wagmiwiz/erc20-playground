// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {ERC20} from "solady/tokens/ERC20.sol";
import {Ownable} from "solady/auth/Ownable.sol";

contract ERC20WithMinter is ERC20, Ownable {
    string internal _name;
    string internal _symbol;

    mapping(address => bool) public minters;

    constructor(string memory name_, string memory symbol_) ERC20() Ownable() {
        _initializeOwner(msg.sender);

        _name = name_;
        _symbol = symbol_;
    }

    function setMinter(address account, bool minter) public onlyOwner {
        minters[account] = minter;
    }

    function mint(address account, uint256 amount) public {
        require(minters[msg.sender], "ERC20WithMinter: sender is not a minter");
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
