// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;
import "./IERC20.sol";

/**
 * @dev library for safe functions of ERC20 token
 */
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
