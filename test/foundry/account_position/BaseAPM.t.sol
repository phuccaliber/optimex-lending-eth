// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {AccountPositionManager} from "../../../contracts/AccountPositionManager.sol";
import {AccountPositionManagerFactory} from "../../../contracts/AccountPositionManagerFactory.sol";
import {LendingManagement} from "../../../contracts/LendingManagement.sol";
import {OW_BTC} from "../../../contracts/tokens/OW_BTC.sol";
import {OptimexBundle} from "../../../contracts/OptimexBundle.sol";

import {
    IMorpho,
    Id,
    Position,
    Market,
    MarketParams
} from "../../../lib/metamorpho-v1.1/lib/morpho-blue/src/interfaces/IMorpho.sol";
import {MarketParamsLib} from "../../../lib/metamorpho-v1.1/lib/morpho-blue/src/libraries/MarketParamsLib.sol";
import {IrmMock} from "../../../lib/metamorpho-v1.1/src/mocks/IRMMock.sol";
import {OracleMock} from "../../../lib/metamorpho-v1.1/src/mocks/OracleMock.sol";

import {ERC20Mock} from "../../mock/ERC20Mock.sol";

contract BaseAPMTest is Test {
    using MarketParamsLib for MarketParams;

    IMorpho public MORPHO;
    IrmMock public IRM_MOCK;
    OracleMock public ORACLE_MOCK;
    Id public marketId;
    MarketParams public marketParams;
    ERC20Mock public USDC;
    OW_BTC public BTC;
    OptimexBundle public OPTIMEX_BUNDLE;
    LendingManagement public LENDING_MANAGEMENT;
    AccountPositionManager public APM;
    AccountPositionManagerFactory public APM_FACTORY;
    address public OWNER;
    address public SUPPLIER;
    address public BORROWER;
    address public MPC;

    function setUp() public virtual {
        vm.createSelectFork("http://localhost:8545");

        string memory path = string.concat(vm.projectRoot(), "/deployments/morpho.json");
        string memory json = vm.readFile(path);

        // Setup addresses
        OWNER = vm.parseJsonAddress(json, ".owner");
        SUPPLIER = makeAddr("SUPPLIER");
        BORROWER = makeAddr("BORROWER");
        MPC = makeAddr("MPC");

        // Setup token
        BTC = new OW_BTC(OWNER);
        USDC = new ERC20Mock("USDC", "USDC", 6);
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
        USDC.approve(address(MORPHO), type(uint256).max);

        // Setup Optimex framework
        APM = new AccountPositionManager();
        vm.startPrank(OWNER);
        BTC.addOperator(OWNER);
        LENDING_MANAGEMENT = new LendingManagement(address(APM), OWNER);
        LENDING_MANAGEMENT.setIsMPC(MPC, true);
        OPTIMEX_BUNDLE = new OptimexBundle(address(BTC), address(LENDING_MANAGEMENT));
        APM_FACTORY = new AccountPositionManagerFactory(address(LENDING_MANAGEMENT));
        BTC.addOperator(address(OPTIMEX_BUNDLE));
        address[] memory accounts = new address[](1);
        accounts[0] = address(MORPHO);
        BTC.addToWhitelistBatch(accounts);
        LENDING_MANAGEMENT.setPositionManagerFactory(address(APM_FACTORY));
        LENDING_MANAGEMENT.setMORPHO(address(MORPHO));
        APM_FACTORY.createAccountPositionManager(BORROWER);
        vm.stopPrank();

        vm.prank(SUPPLIER);
        MORPHO.supply(marketParams, 1000000e6, 0, SUPPLIER, "");
    }
}
