// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BaseAPMTest} from "./BaseAPM.t.sol";

contract SupplyCollateralTest is BaseAPMTest {
    function test_InitOptimexSucess() public view {
        assertEq(BTC.isOperator(address(OPTIMEX_BUNDLE)), true, "OPTIMEX_BUNDLE is not an operator");
        assertEq(BTC.isWhitelisted(address(MORPHO)), true, "MORPHO should be whitelisted");
    }
}
