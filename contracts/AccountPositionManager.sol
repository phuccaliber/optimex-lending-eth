// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IMorphoRepayCallback} from "lib/metamorpho-v1.1/lib/morpho-blue/src/interfaces/IMorphoCallbacks.sol";
import "./BaseOptimexLending.sol";
import "./interfaces/IAccountPositionManager.sol";

contract AccountPositionManager is IAccountPositionManager, BaseOptimexLending, IMorphoRepayCallback {
    modifier onlyMorpho() {
        if (msg.sender != _getMORPHO()) revert InvalidMorpho();
        _;
    }

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

    function repay(MarketParams memory marketParams, uint256 assets, uint256 shares, bytes memory) external {
        IMorpho morpho = IMorpho(_getMORPHO());
        IERC20 loanToken = IERC20(marketParams.loanToken);

        bytes memory data = abi.encode(msg.sender, address(loanToken));
        (uint256 assetsRepaid, uint256 sharesRepaid) = morpho.repay(marketParams, assets, shares, address(this), data);
        emit Repaid(marketParams.loanToken, assetsRepaid, sharesRepaid, owner);
    }

    function onMorphoRepay(uint256 assets, bytes calldata data) external {
        address morpho = _getMORPHO();
        if (msg.sender != morpho) revert InvalidMorpho();
        (address sender, address loanToken) = abi.decode(data, (address, address));
        IERC20(loanToken).transferFrom(sender, address(this), assets);
        IERC20(loanToken).approve(address(morpho), assets);
    }
}
