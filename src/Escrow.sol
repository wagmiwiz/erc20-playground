// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {ReentrancyGuard} from "solady/utils/ReentrancyGuard.sol";

contract Escrow is ReentrancyGuard {
    struct EscrowData {
        address token;
        uint256 amount;
        uint256 releaseTimestamp;
    }

    mapping(address => EscrowData) public escrows;

    uint256 public constant RELEASE_PERIOD = 3 days;

    function createEscrow(address token, uint256 amount, address to) external nonReentrant {
        // for simplicity of toy example, we use the buyer's address as the sale ID and only one sale per buyer
        require(escrows[to].releaseTimestamp == 0, "Escrow: sale already exists for this buyer");

        uint256 startingBalance = SafeTransferLib.balanceOf(token, address(this));
        SafeTransferLib.safeTransferFrom(token, msg.sender, address(this), amount);
        uint256 realAmount = SafeTransferLib.balanceOf(token, address(this)) - startingBalance;

        // we use real amount in case of transfer fees
        escrows[to] = EscrowData(token, realAmount, block.timestamp + RELEASE_PERIOD);
    }

    function releaseEscrow() external {
        EscrowData memory escrowData = escrows[msg.sender];

        require(escrowData.releaseTimestamp != 0, "Escrow: no sale exists for this buyer");
        require(block.timestamp >= escrowData.releaseTimestamp, "Escrow: sale not yet released");

        delete escrows[msg.sender];

        SafeTransferLib.safeTransfer(escrowData.token, msg.sender, escrowData.amount);
    }
}
