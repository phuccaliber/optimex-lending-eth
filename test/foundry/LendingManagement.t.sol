// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../../lib/forge-std/src/Test.sol";
import "../../contracts/LendingManagement.sol";
import "../../contracts/AccountPositionManager.sol";
import "../../contracts/AccountPositionManagerFactory.sol";

contract LendingManagementTest is Test {
    LendingManagement lendingManagement;
    AccountPositionManagerFactory factory;
    address implementation;
    address OWNER;
    address USER;
    address FACTORY;

    function setUp() public {
        OWNER = makeAddr("OWNER");
        USER = makeAddr("USER");
        FACTORY = makeAddr("FACTORY");

        vm.startPrank(OWNER);
        implementation = address(new AccountPositionManager());
        lendingManagement = new LendingManagement(implementation, OWNER);
        lendingManagement.setPositionManagerFactory(FACTORY);
        vm.stopPrank();
    }

    function testInitialState() public view {
        assertEq(lendingManagement.implementation(), implementation, "Implementation not set correctly");
        assertEq(lendingManagement.owner(), OWNER, "Owner not set correctly");
        assertEq(lendingManagement.positionManagerFactory(), FACTORY, "Factory not set correctly");
    }

    function testSetPositionManagerFactory(address newFactory) public {
        vm.assume(newFactory != address(0));

        vm.prank(OWNER);
        lendingManagement.setPositionManagerFactory(newFactory);
        assertEq(lendingManagement.positionManagerFactory(), newFactory, "Factory not updated");
    }

    function testCannotSetFactoryIfNotOwner(address notOwner, address newFactory) public {
        vm.assume(notOwner != OWNER);

        vm.prank(notOwner);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, notOwner));
        lendingManagement.setPositionManagerFactory(newFactory);
    }

    function testSetAccountPositionManager(address user, address positionManager) public {
        vm.assume(user != address(0));
        vm.assume(positionManager != address(0));

        vm.prank(FACTORY);
        lendingManagement.setAccountPositionManager(user, positionManager);
        assertEq(
            lendingManagement.accountPositionManagerAddresses(user),
            positionManager,
            "Position manager not set correctly"
        );
    }

    function testCannotSetAccountPositionManagerIfNotFactory(address notFactory, address user, address positionManager)
        public
    {
        vm.assume(notFactory != FACTORY);

        vm.prank(notFactory);
        vm.expectRevert("Only the position manager factory can call this function");
        lendingManagement.setAccountPositionManager(user, positionManager);
    }
}
