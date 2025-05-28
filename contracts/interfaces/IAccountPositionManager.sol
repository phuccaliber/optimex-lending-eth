// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "lib/metamorpho-v1.1/lib/morpho-blue/src/interfaces/IMorpho.sol";

interface IAccountPositionManager {
    event CollateralSupplied(address indexed collateralToken, uint256 assets, address account);
    event Borrowed(address indexed loanToken, uint256 assets, address borrower);

    function initialize(address initialLendingManagement, address initialOwner) external;
    function supplyCollateral(MarketParams memory marketParams, bytes memory data) external;
    function borrow(MarketParams memory marketParams, uint256 assets) external;
}
