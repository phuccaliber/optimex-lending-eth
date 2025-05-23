// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../../contracts/AccountPositionManagerFactory.sol";
import "../../../contracts/AccountPositionManager.sol";

contract AccountPositionManagerFactoryTest is Test {
    AccountPositionManagerFactory factory;
    address implementation;
    address OWNER;
    address USER;

    function setUp() public {
        OWNER = makeAddr("OWNER");
        USER = makeAddr("USER");

        vm.startPrank(OWNER);
        implementation = address(new AccountPositionManager());
        factory = new AccountPositionManagerFactory(address(implementation), OWNER);
        vm.stopPrank();
    }

    function testAccountPositionManagerIsInitialized() public view {
        assertEq(factory.implementation(), implementation, "The implementaion contract is not correct");
        assertEq(factory.owner(), OWNER, "The owner is not correct");
    }

    function testCreateAccountPositionManager() public {
        address positionManager = factory.createAccountPositionManager(USER);

        // Verify position manager was created and mapped correctly
        assertEq(factory.positionManagerAddresses(USER), positionManager);
    }

    function testCannotCreateDuplicateManager() public {
        // Create first position manager
        factory.createAccountPositionManager(USER);

        // Attempt to create second position manager for same USER
        vm.expectRevert(
            abi.encodeWithSelector(
                AccountPositionManagerFactory.AlreadyHasPositionManager.selector,
                USER,
                factory.positionManagerAddresses(USER)
            )
        );
        factory.createAccountPositionManager(USER);
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
            factory.positionManagerAddresses(onBehalf),
            positionManager,
            "The position manager was not created for the correct user"
        );
        vm.stopPrank();
    }
}
