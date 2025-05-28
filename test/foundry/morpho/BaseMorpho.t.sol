// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import "../../../contracts/AccountPositionManager.sol";
import {IMorpho, Id, Position, Market} from "../../../lib/metamorpho-v1.1/lib/morpho-blue/src/interfaces/IMorpho.sol";
import {MarketParamsLib} from "../../../lib/metamorpho-v1.1/lib/morpho-blue/src/libraries/MarketParamsLib.sol";
import "../../../lib/metamorpho-v1.1/src/mocks/IRMMock.sol";
import "../../../lib/metamorpho-v1.1/src/mocks/OracleMock.sol";

import "../../mock/ERC20Mock.sol";

contract BaseMorphoTest is Test {
    using MarketParamsLib for MarketParams;

    IMorpho public MORPHO;
    IrmMock public IRM_MOCK;
    OracleMock public ORACLE_MOCK;
    Id public marketId;
    MarketParams public marketParams;
    ERC20Mock public BTC;
    ERC20Mock public USDC;
    address public OWNER;
    address public SUPPLIER;
    address public BORROWER;
    address public MPC;

    function setUp() public {
        vm.createSelectFork("http://localhost:8545");

        string memory path = string.concat(vm.projectRoot(), "/deployments/morpho.json");
        string memory json = vm.readFile(path);

        // Setup addresses
        OWNER = vm.parseJsonAddress(json, ".owner");
        SUPPLIER = makeAddr("SUPPLIER");
        BORROWER = makeAddr("BORROWER");
        MPC = makeAddr("MPC");

        // Setup token
        BTC = new ERC20Mock("BTC", "BTC", 8);
        USDC = new ERC20Mock("USDC", "USDC", 6);
        BTC.mint(BORROWER, 1e8);
        USDC.mint(SUPPLIER, 1000000e6);
        // Setup Morpho
        address morphoAddress = vm.parseJsonAddress(json, ".address");
        MORPHO = IMorpho(morphoAddress);
        IRM_MOCK = new IrmMock();
        ORACLE_MOCK = new OracleMock();
        vm.startPrank(OWNER);
        MORPHO.enableIrm(address(IRM_MOCK));
        MORPHO.enableLltv(86e16);
        ORACLE_MOCK.setPrice(1000e36); // 1 BTC = 100.000 USDC
        marketParams = MarketParams({
            loanToken: address(USDC),
            collateralToken: address(BTC),
            oracle: address(ORACLE_MOCK),
            irm: address(IRM_MOCK),
            lltv: 86e16
        });
        MORPHO.createMarket(marketParams);
        marketId = marketParams.id();
        vm.stopPrank();

        // Approve tokens
        vm.prank(SUPPLIER);
        USDC.approve(address(MORPHO), type(uint256).max);

        vm.prank(BORROWER);
        BTC.approve(address(MORPHO), type(uint256).max);

        vm.prank(BORROWER);
        USDC.approve(address(MORPHO), type(uint256).max);
    }
}
