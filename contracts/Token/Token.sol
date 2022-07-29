// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title Token contract
 * @dev for testing purpose in case of deploying stablecoin BUSD,
 * the address of which has to be parsed into the IGO launchpad contract
 */
contract Token is ERC20 {
    uint8 private immutable customDecimals;

    constructor(
        string memory _erc20Name,
        string memory _erc20Symbol,
        uint8 _decimals
    ) public ERC20(_erc20Name, _erc20Symbol) {
        customDecimals = _decimals;
    }

    function decimals() public view override returns (uint8) {
        return customDecimals;
    }
}
