// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import "../../../contracts/AccountPositionManager.sol";
import {Morpho} from "../../../lib/metamorpho-v1.1/lib/morpho-blue/src/Morpho.sol";
import "../../mock/ERC20Mock.sol";
import "../../mock/interfaces/IERC20Mock.sol";

contract BaseMorphoTest is Test {
    Morpho public MORPHO;
    IERC20Mock public BTC;
    IERC20Mock public USDC;
    address public OWNER;
    address public SUPPLIER;
    address public BORROWER;
    address public MPC;

    function setUp() public {
        OWNER = makeAddr("OWNER");
        SUPPLIER = makeAddr("SUPPLIER");
        BORROWER = makeAddr("BORROWER");
        MPC = makeAddr("MPC");
        MORPHO = new Morpho(OWNER);
        BTC = IERC20Mock(new MockERC20("BTC", "BTC", 8));
        USDC = IERC20Mock(new MockERC20("USDC", "USDC", 6));
        BTC.mint(BORROWER, 1e8);
        USDC.mint(SUPPLIER, 1000000e6);
    }
}
