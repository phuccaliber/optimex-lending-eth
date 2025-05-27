// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BaseMorphoTest, MarketParams} from "./BaseMorpho.t.sol";

contract BaseMorphoSetupTest is BaseMorphoTest {
    function test_InitBaseMorpho() public {
        assertNotEq(address(MORPHO), address(0), "Morpho blue is not initialized");
        assertNotEq(address(BTC), address(0), "BTC is not initialized");
        assertNotEq(address(USDC), address(0), "USDC is not initialized");
        assertNotEq(address(IRM_MOCK), address(0), "IRM is not initialized");
        assertNotEq(address(ORACLE_MOCK), address(0), "Oracle is not initialized");
    }

    function test_InitBalanceSuccess() public {
        assertEq(BTC.balanceOf(BORROWER), 1e8, "BTC balance is not correct");
        assertEq(USDC.balanceOf(SUPPLIER), 1000000e6, "USDC balance is not correct");
    }

    function test_InitMarketSuccess() public {
        MarketParams memory market = MORPHO.idToMarketParams(marketId);
        assertEq(market.loanToken, address(USDC), "Loan token is not correct");
        assertEq(market.collateralToken, address(BTC), "Collateral token is not correct");
        assertEq(market.oracle, address(ORACLE_MOCK), "Oracle is not correct");
        assertEq(market.irm, address(IRM_MOCK), "IRM is not correct");
        assertEq(market.lltv, 86e16, "LLTV is not correct");
    }
}
