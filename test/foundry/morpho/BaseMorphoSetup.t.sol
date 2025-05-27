// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {BaseMorphoTest} from "./BaseMorpho.t.sol";

contract BaseMorphoSetupTest is BaseMorphoTest {
    function test_InitBaseMorpho() public view {
        assertNotEq(address(MORPHO), address(0), "Morpho blue is not initialized");
        assertNotEq(address(BTC), address(0), "BTC is not initialized");
        assertNotEq(address(USDC), address(0), "USDC is not initialized");
    }

    function test_InitBalanceSuccess() public view {
        assertEq(BTC.balanceOf(BORROWER), 1e8, "BTC balance is not correct");
        assertEq(USDC.balanceOf(SUPPLIER), 1000000e6, "USDC balance is not correct");
    }
}
