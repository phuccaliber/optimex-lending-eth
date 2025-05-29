// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BaseAPMTest, MarketParams, Position, Market} from "./BaseAPM.t.sol";
import {BaseOptimexLending} from "../../../contracts/BaseOptimexLending.sol";
import {IAccountPositionManager} from "../../../contracts/interfaces/IAccountPositionManager.sol";

contract RepayTest is BaseAPMTest {
    function setUp() public override {
        super.setUp();
        vm.prank(MPC);
        // 1 BTC = 100_000 USDC
        uint256 amount = 1e8;
        OPTIMEX_BUNDLE.supplyCollateral(marketParams, amount, BORROWER, "");

        uint256 borrowAssets = 50000e6;
        // Borrow 50_000 USDC
        IAccountPositionManager BORROWER_APM =
            IAccountPositionManager(LENDING_MANAGEMENT.accountPositionManagerAddresses(BORROWER));
        vm.prank(BORROWER);
        BORROWER_APM.borrow(marketParams, borrowAssets);
    }

    function test_RepaySuccess() public {
        uint256 repayAssets = 20000e6;
        // Borrow 50_000 USDC
        IAccountPositionManager BORROWER_APM =
            IAccountPositionManager(LENDING_MANAGEMENT.accountPositionManagerAddresses(BORROWER));
        vm.startPrank(BORROWER);
        USDC.approve(address(BORROWER_APM), type(uint256).max);
        BORROWER_APM.repay(marketParams, repayAssets, 0, "");
        vm.stopPrank();
    }
}
