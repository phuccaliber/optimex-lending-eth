// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../../../lib/forge-std/src/Test.sol";
import "../../../contracts/AccountPositionManagerFactory.sol";
import "../../../contracts/AccountPositionManager.sol";
import "../../../contracts/interfaces/ILendingManagement.sol";
import "../../../contracts/LendingManagement.sol";

contract AccountPositionManagerFactoryTest is Test {
    AccountPositionManagerFactory factory;
    LendingManagement lendingManagement;
    address implementation;
    address OWNER;
    address USER;

    function setUp() public {
        OWNER = makeAddr("OWNER");
        USER = makeAddr("USER");

        vm.startPrank(OWNER);
        implementation = address(new AccountPositionManager());
        lendingManagement = new LendingManagement(address(implementation), OWNER);
        factory = new AccountPositionManagerFactory(address(lendingManagement));
        lendingManagement.setPositionManagerFactory(address(factory));
        vm.stopPrank();
    }

    function testContractIsInitializedCorrectly() public view {
        assertEq(
            address(factory.lendingManagement()), address(lendingManagement), "The lending management is not correct"
        );
    }

    function testCreateAccountPositionManager(address onBehalf) public {
        address positionManager = factory.createAccountPositionManager(onBehalf);

        // Verify position manager was created and mapped correctly
        assertEq(lendingManagement.accountPositionManagerAddresses(onBehalf), positionManager);
    }

    function testCannotCreateDuplicateManager(address onBehalf) public {
        // Create first position manager
        factory.createAccountPositionManager(onBehalf);

        // Attempt to create second position manager for same USER
        vm.expectRevert(
            abi.encodeWithSelector(
                AccountPositionManagerFactory.AlreadyHasPositionManager.selector,
                onBehalf,
                lendingManagement.accountPositionManagerAddresses(onBehalf)
            )
        );
        factory.createAccountPositionManager(onBehalf);
    }

    function testEmitsEventOnCreation() public {
        vm.expectEmit(true, true, false, true);
        address expectedManager = computeCreateAddress(address(factory), vm.getNonce(address(factory)));
        emit AccountPositionManagerFactory.PositionManagerCreated(USER, expectedManager);

        factory.createAccountPositionManager(USER);
    }

    function testCreateAccountPositionManagerOnBehalf(address onBehalf) public {
        vm.startPrank(USER);
        address positionManager = factory.createAccountPositionManager(onBehalf);
        assertEq(
            lendingManagement.accountPositionManagerAddresses(onBehalf),
            positionManager,
            "The position manager was not created for the correct user"
        );
        vm.stopPrank();
    }
}
