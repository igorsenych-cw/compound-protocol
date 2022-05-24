pragma solidity ^0.5.16;

import "../InterestRateModel.sol";
import "../SafeMath.sol";

/**
 * @title Transient InterestRateModel implementation
 */
contract TransientBorrowRateModel is InterestRateModel {
    using SafeMath for uint256;

    event OwnerChanged(address indexed newOwner, address indexed oldOwner);
    event ManagerChanged(address indexed newManager, address indexed oldManager);
    event NewRatePerBlock(uint256 newRatePerBlock, uint256 oldRatePerBlock);
    event NewBlocksPerYear(uint256 newBlocksPerYear, uint256 oldBlocksPerYear);

    /**
     * @dev Contract owner address
     */
    address public owner;

    /**
     * @dev Contract manager address
     */
    address public manager;

    /**
     * @dev Throws if called by any account other than owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not owner");
        _;
    }

    /**
     * @dev Throws if called by any account other than manager
     */
    modifier onlyManager() {
        require(msg.sender == manager, "caller is not manager");
        _;
    }

    /**
     * @notice The min number of blocks per year that is assumed by the interest rate model
     */
    uint256 public constant blocksPerYearMax = 34689600;

    /**
     * @notice The max number of blocks per year that is assumed by the interest rate model
     */
    uint256 public constant blocksPerYearMin = 29959200;

    /**
     * @notice The approximate number of blocks per year that is assumed by the interest rate model
     */
    uint256 public blocksPerYear = 31536000;

    /**
     * @notice The base interest rate which is the y-intercept when utilization rate is 0
     */
    uint256 public baseRatePerBlock;

    /**
     * @notice The approximate target base APR, as a mantissa (scaled by 1e18)
     */
    uint256 public baseRatePerYear;

    /**
     * @notice Construct an interest rate model
     * @param baseRatePerYear_ The approximate target base APR, as a mantissa (scaled by 1e18)
     */
    constructor(uint256 baseRatePerYear_) public {
        owner = msg.sender;
        baseRatePerYear = baseRatePerYear_;
        UpdateRatePerBlock();
    }

    /**
     * @notice Calculates the utilization rate of the market: `borrows / (cash + borrows - reserves)`
     * @param cash The amount of cash in the market
     * @param borrows The amount of borrows in the market
     * @param reserves The amount of reserves in the market (currently unused)
     * @return The utilization rate as a mantissa between [0, 1e18]
     */
    function utilizationRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) public pure returns (uint256) {
        // Utilization rate is 0 when there are no borrows
        if (borrows == 0) {
            return 0;
        }
        return borrows.mul(1e18).div(cash.add(borrows).sub(reserves));
    }

    /**
     * @notice Calculates the current borrow rate per block, with the error code expected by the market
     * @param cash The amount of cash in the market
     * @param borrows The amount of borrows in the market
     * @param reserves The amount of reserves in the market
     * @return The borrow rate percentage per block as a mantissa (scaled by 1e18)
     */
    function getBorrowRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) public view returns (uint256) {
        cash;
        borrows;
        reserves;
        return baseRatePerBlock;
    }

    /**
     * @notice Calculates the current supply rate per block
     * @param cash The amount of cash in the market
     * @param borrows The amount of borrows in the market
     * @param reserves The amount of reserves in the market
     * @param reserveFactorMantissa The current reserve factor for the market
     * @return The supply rate percentage per block as a mantissa (scaled by 1e18)
     */
    function getSupplyRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveFactorMantissa
    ) public view returns (uint256) {
        uint256 oneMinusReserveFactor = uint256(1e18).sub(
            reserveFactorMantissa
        );
        uint256 borrowRate = getBorrowRate(cash, borrows, reserves);
        uint256 rateToPool = borrowRate.mul(oneMinusReserveFactor).div(1e18);
        return
            utilizationRate(cash, borrows, reserves).mul(rateToPool).div(1e18);
    }

    /**
     * @dev Configure `manager` address
     * Can only be called by the contract owner
     * Emits an {ManagerChanged} event
     */
    function setManager(address newManager) external onlyOwner {
        emit ManagerChanged(newManager, manager);
        manager = newManager;
    }

    /**
     * @dev Transfers ownership of the contract to a new account
     * Can only be called by the current owner
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "new owner is the zero address");
        emit OwnerChanged(newOwner, owner);
        owner = newOwner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`)
     * Can only be called by the current owner
     */
    function updateBlocksPerYear(uint256 newBlocksPerYear) external onlyManager {
        require(newBlocksPerYear >= blocksPerYearMin, "max out of range");
        require(newBlocksPerYear <= blocksPerYearMax, "min out of range");
        emit NewBlocksPerYear(newBlocksPerYear, blocksPerYear);
        blocksPerYear = newBlocksPerYear;
        UpdateRatePerBlock();
    }

    function UpdateRatePerBlock() internal {
        uint256 newBaseRatePerBlock = baseRatePerYear.div(blocksPerYear);
        emit NewRatePerBlock(newBaseRatePerBlock, baseRatePerBlock);
        baseRatePerBlock = newBaseRatePerBlock;
    }
}
