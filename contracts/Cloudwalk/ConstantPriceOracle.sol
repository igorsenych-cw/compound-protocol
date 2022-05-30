pragma solidity ^0.5.16;

/**
 * @title Constant price oracle
 */
contract ConstantPriceOracle {
    function getUnderlyingPrice(address cToken) external view returns (uint) {
        cToken;
        return 2e18;
    }
}
