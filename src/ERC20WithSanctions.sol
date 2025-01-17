// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {ERC20} from "solady/tokens/ERC20.sol";
import {Ownable} from "solady/auth/Ownable.sol";

contract ERC20WithSanctions is ERC20, Ownable {
    string internal _name;
    string internal _symbol;

    mapping(address => bool) public sanctions;

    event Sanctioned(address indexed account, bool sanctioned);

    constructor(string memory name_, string memory symbol_) ERC20() Ownable() {
        _initializeOwner(msg.sender);

        _name = name_;
        _symbol = symbol_;
    }

    function setSanctioned(address account, bool sanctioned) public onlyOwner {
        sanctions[account] = sanctioned;
        emit Sanctioned(account, sanctioned);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(!sanctions[msg.sender], "ERC20WithSanctions: sender is sanctioned");
        require(!sanctions[recipient], "ERC20WithSanctions: recipient is sanctioned");
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(!sanctions[sender], "ERC20WithSanctions: sender is sanctioned");
        require(!sanctions[recipient], "ERC20WithSanctions: recipient is sanctioned");
        return super.transferFrom(sender, recipient, amount);
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
