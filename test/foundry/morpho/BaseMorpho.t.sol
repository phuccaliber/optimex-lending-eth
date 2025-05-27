// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import "../../../lib/metamorpho-v1.1/lib/morpho-blue/src/Morpho.sol";

contract BaseMorphoTest is Test {
    Morpho public MORPHO;
    address public OWNER;

    function setUp() public {
        OWNER = makeAddr("OWNER");
        MORPHO = new Morpho(OWNER);
    }
}
