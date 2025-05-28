// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BaseAPMTest, MarketParams, Position, Market} from "./BaseAPM.t.sol";
import {BaseOptimexLending} from "../../../contracts/BaseOptimexLending.sol";
import {IAccountPositionManager} from "../../../contracts/interfaces/IAccountPositionManager.sol";

contract BorrowTest is BaseAPMTest {
    function setUp() public override {
        super.setUp();
        vm.prank(MPC);
        // 1 BTC = 100_000 USDC
        uint256 amount = 1e8;
        OPTIMEX_BUNDLE.supplyCollateral(marketParams, amount, BORROWER, "");
    }

    function test_BorrowSuccess() public {
        uint256 assets = 50000e6;
        // Borrow 50_000 USDC
        IAccountPositionManager BORROWER_APM =
            IAccountPositionManager(LENDING_MANAGEMENT.accountPositionManagerAddresses(BORROWER));
        vm.prank(BORROWER);
        BORROWER_APM.borrow(marketParams, assets);

        Position memory position = MORPHO.position(marketId, address(BORROWER_APM));
        assertGt(position.borrowShares, 0, "Borrow should be greater than 0");
        Market memory market = MORPHO.market(marketId);
        assertEq(market.totalBorrowAssets, assets, "Borrow should be 50_000 USDC");
        assertEq(market.totalBorrowShares, position.borrowShares, "BORROWER should borrow all shares");
    }
}
