// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./BaseOptimexLending.sol";
import "./interfaces/IAccountPositionManager.sol";

contract AccountPositionManager is IAccountPositionManager, BaseOptimexLending {
    address public owner;

    function initialize(address initialLendingManagement, address initialOwner) external {
        _setLendingManagement(initialLendingManagement);
        owner = initialOwner;
    }

    function supplyCollateral(MarketParams memory marketParams, bytes memory data) external {
        IMorpho morpho = IMorpho(_getMORPHO());
        uint256 assets = IERC20(marketParams.collateralToken).balanceOf(address(this));
        morpho.supplyCollateral(marketParams, assets, address(this), data);
    }
}
