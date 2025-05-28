// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BaseAPMTest, MarketParams, Position} from "./BaseAPM.t.sol";
import {BaseOptimexLending} from "../../../contracts/BaseOptimexLending.sol";

contract SupplyCollateralTest is BaseAPMTest {
    function test_InitOptimexSucess() public view {
        assertEq(BTC.isOperator(address(OPTIMEX_BUNDLE)), true, "OPTIMEX_BUNDLE is not an operator");
        assertEq(BTC.isWhitelisted(address(MORPHO)), true, "MORPHO should be whitelisted");
    }

    function test_SupplyCollateralSuccess() public {
        vm.prank(MPC);
        // 1 BTC
        uint256 amount = 1e8;
        OPTIMEX_BUNDLE.supplyCollateral(marketParams, amount, BORROWER, "");
        address BORROWER_APM = LENDING_MANAGEMENT.accountPositionManagerAddresses(BORROWER);
        Position memory position = MORPHO.position(marketId, BORROWER_APM);
        assertEq(position.collateral, amount, "Collateral should be 1 BTC");
    }

    function test_SupplyCollateralFailureNotMpc() public {
        vm.prank(BORROWER);
        uint256 amount = 1e8;
        vm.expectRevert(abi.encodeWithSelector(BaseOptimexLending.NotMPC.selector, BORROWER));
        OPTIMEX_BUNDLE.supplyCollateral(marketParams, amount, BORROWER, "");
    }
}
