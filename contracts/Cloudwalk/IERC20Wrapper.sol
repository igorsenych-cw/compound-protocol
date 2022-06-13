pragma solidity ^0.5.16;

/**
 * @title ERC20 wrapper interface
 */
interface IERC20Wrapper {
    function isIERC20Wrapper() external view returns (bool);
    function wrapFor(address account, uint256 amount) external returns (bool);
    function unwrapFor(address account, uint256 amount) external returns (bool);
    function underlying() external view returns (address);
}
