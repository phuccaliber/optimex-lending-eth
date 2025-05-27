// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {BaseMorphoTest} from "./BaseMorpho.t.sol";

contract BaseMorphoSetupTest is BaseMorphoTest {
    function test_InitBaseMorpho() public view {
        assertNotEq(address(MORPHO), address(0), "Morpho blue is not initialized");
    }
}
