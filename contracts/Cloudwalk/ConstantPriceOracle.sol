// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

/**
 * @title Constant price oracle
 */
contract ConstantPriceOracle {
    function getUnderlyingPrice(address cToken) external view returns (uint) {
        cToken;
        return 2e18;
    }
}
