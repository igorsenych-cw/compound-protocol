pragma solidity ^0.5.16;

/**
 * @title ERC20 mintable interface
 */
interface IERC20Mintable {
    function isMinter(address account) external view returns (bool);
    function minterAllowance(address minter) external view returns (uint256);
    function mint(address to, uint256 amount) external returns (bool);
}
