// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./BaseOptimexLending.sol";
import "./interfaces/IAccountPositionManager.sol";

contract AccountPositionManager is IAccountPositionManager, BaseOptimexLending {
    error NotOwner(address sender);

    address public owner;

    function initialize(address initialLendingManagement, address initialOwner) external {
        _setLendingManagement(initialLendingManagement);
        owner = initialOwner;
    }

    function supplyCollateral(MarketParams memory marketParams, bytes memory data) external {
        IMorpho morpho = IMorpho(_getMORPHO());
        uint256 assets = IERC20(marketParams.collateralToken).balanceOf(address(this));
        IERC20(marketParams.collateralToken).approve(address(morpho), assets);
        morpho.supplyCollateral(marketParams, assets, address(this), data);
        emit CollateralSupplied(marketParams.collateralToken, assets, address(this));
    }

    function borrow(MarketParams memory marketParams, uint256 assets) external {
        if (msg.sender != owner) revert NotOwner(msg.sender);
        IMorpho morpho = IMorpho(_getMORPHO());
        morpho.borrow(marketParams, assets, 0, address(this), owner);
        emit Borrowed(marketParams.loanToken, assets, owner);
    }
}
