pragma solidity ^0.5.16;

/**
 * @title EIP20 mintable interface
 */
interface EIP20MintableInterface {
    function isMinter(address account) external view returns (bool);
    function minterAllowance(address minter) external view returns (uint256);
    function mint(address to, uint256 amount) external returns (bool);
}
