// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../../../lib/forge-std/src/Test.sol";
import "../../../contracts/AccountPositionManagerFactory.sol";
import "../../../contracts/AccountPositionManager.sol";
import "../../../contracts/interfaces/ILendingManagement.sol";
import "../../../contracts/LendingManagement.sol";
import "../../../contracts/AccountPositionManager.sol";
import "../../../contracts/interfaces/IAccountPositionManager.sol";

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
        assertEq(
            address(BaseOptimexLending(positionManager).lendingManagement()),
            address(lendingManagement),
            "Lending Management is not set correctly"
        );
    }

    function testAccountPositionManagerRevertedIfSetLendingManagementTwice(address onBehalf) public {
        address positionManager = factory.createAccountPositionManager(onBehalf);

        vm.expectRevert(
            abi.encodeWithSelector(
                BaseOptimexLending.LendingManagementAlreadyInitialized.selector, address(lendingManagement)
            )
        );
        AccountPositionManager(positionManager).setLendingManagement(address(lendingManagement));
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
        // Calculate expected proxy address based on create2 salt
        bytes memory data =
            abi.encodeWithSelector(IAccountPositionManager.initialize.selector, address(lendingManagement), USER);
        bytes32 salt = bytes32(uint256(uint160(USER)));
        address expectedManager = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            address(factory),
                            salt,
                            keccak256(
                                abi.encodePacked(
                                    type(BeaconProxy).creationCode, abi.encode(address(lendingManagement), data)
                                )
                            )
                        )
                    )
                )
            )
        );

        vm.expectEmit(true, true, false, true);
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
