// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BaseMorphoTest, MarketParams, Position, Market} from "./BaseMorpho.t.sol";
import "../../../lib/metamorpho-v1.1/lib/morpho-blue/src/libraries/ErrorsLib.sol";
import "forge-std/console.sol";

contract BaseMorphoSetupTest is BaseMorphoTest {
    function test_SupplyLoanTokenSuccess() public {
        vm.startPrank(SUPPLIER);
        uint256 assets = 500000e6;
        MORPHO.supply(marketParams, assets, 0, SUPPLIER, "");
        Position memory position = MORPHO.position(marketId, SUPPLIER);
        assertGt(position.supplyShares, 0, "Collateral is not correct");
        Market memory market = MORPHO.market(marketId);
        assertEq(market.totalSupplyShares, position.supplyShares, "Total supply shares is not correct");
        assertEq(market.totalSupplyAssets, assets, "Supply assets is not correct");
        vm.stopPrank();
    }

    function test_SupplyCollateralSuccess() public {
        // User deposit 1 BTC as collateral
        vm.startPrank(BORROWER);
        uint256 assets = 1e8;
        MORPHO.supplyCollateral(marketParams, assets, BORROWER, "");
        Position memory position = MORPHO.position(marketId, BORROWER);
        assertEq(position.collateral, assets, "Collateral is not correct");
        Market memory market = MORPHO.market(marketId);
        assertEq(market.totalSupplyShares, 0, "Total supply shares is not correct");
        assertEq(market.totalSupplyAssets, 0, "Supply assets is not correct");
        vm.stopPrank();
    }

    function test_BorrowLoanTokenSuccess() public {
        // SUPPLIER supply 500_000 USDC as supply
        vm.startPrank(SUPPLIER);
        uint256 supplyAssets = 500000e6;
        MORPHO.supply(marketParams, supplyAssets, 0, SUPPLIER, "");
        vm.stopPrank();

        // User deposit 1 BTC as collateral
        vm.startPrank(BORROWER);
        uint256 collateralAssets = 1e8;
        MORPHO.supplyCollateral(marketParams, collateralAssets, BORROWER, "");
        vm.stopPrank();

        // User borrow 50_000 USDC
        vm.startPrank(BORROWER);
        uint256 borrowAssets = 50000e6;
        MORPHO.borrow(marketParams, borrowAssets, 0, BORROWER, BORROWER);
        vm.stopPrank();

        // Check user position
        Position memory position = MORPHO.position(marketId, BORROWER);
        Market memory market = MORPHO.market(marketId);
        assertEq(position.borrowShares, market.totalBorrowShares, "Borrow shares is not correct");
        assertEq(market.totalBorrowAssets, borrowAssets, "Borrow assets is not correct");
    }

    function test_BorrowLoanTokenFailureNotEnoughCollateral() public {
        // SUPPLIER supply 500_000 USDC as supply
        vm.startPrank(SUPPLIER);
        uint256 supplyAssets = 500000e6;
        MORPHO.supply(marketParams, supplyAssets, 0, SUPPLIER, "");
        vm.stopPrank();

        // User deposit 1 BTC as collateral
        vm.startPrank(BORROWER);
        uint256 collateralAssets = 1e8;
        MORPHO.supplyCollateral(marketParams, collateralAssets, BORROWER, "");
        vm.stopPrank();

        // User borrow 50_000 USDC
        vm.startPrank(BORROWER);
        uint256 borrowAssets = 90000e6;
        vm.expectRevert(bytes(ErrorsLib.INSUFFICIENT_COLLATERAL));
        MORPHO.borrow(marketParams, borrowAssets, 0, BORROWER, BORROWER);
        vm.stopPrank();
    }
}
