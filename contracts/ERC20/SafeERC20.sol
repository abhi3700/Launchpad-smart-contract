pragma solidity >=0.6.0 <0.8.0;

// SPDX-License-Identifier: UNLICENSED

import "./IERC20.sol";

library SafeERC20 {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value), "transfer failed");
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value), "transferFrom failed");
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(token.approve(spender, value), "safeApprove failed");
    }
}
