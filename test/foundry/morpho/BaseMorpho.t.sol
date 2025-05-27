// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import "../../../contracts/AccountPositionManager.sol";
import {IMorpho} from "../../../lib/metamorpho-v1.1/lib/morpho-blue/src/interfaces/IMorpho.sol";
import "../../mock/ERC20Mock.sol";
import "../../mock/interfaces/IERC20Mock.sol";

contract BaseMorphoTest is Test {
    IMorpho public MORPHO;
    IERC20Mock public BTC;
    IERC20Mock public USDC;
    address public OWNER;
    address public SUPPLIER;
    address public BORROWER;
    address public MPC;

    function setUp() public {
        vm.createSelectFork("http://localhost:8545");
        string memory path = string.concat(vm.projectRoot(), "/deployments/morpho.json");
        string memory json = vm.readFile(path);
        address morphoAddress = vm.parseJsonAddress(json, ".address");
        MORPHO = IMorpho(morphoAddress);
        OWNER = makeAddr("OWNER");
        SUPPLIER = makeAddr("SUPPLIER");
        BORROWER = makeAddr("BORROWER");
        MPC = makeAddr("MPC");
        BTC = IERC20Mock(new MockERC20("BTC", "BTC", 8));
        USDC = IERC20Mock(new MockERC20("USDC", "USDC", 6));
        BTC.mint(BORROWER, 1e8);
        USDC.mint(SUPPLIER, 1000000e6);
    }
}
