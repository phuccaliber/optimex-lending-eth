// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../lib/openzeppelin-contracts/contracts/proxy/beacon/BeaconProxy.sol";
import "./BaseOptimexLending.sol";

contract AccountPositionManagerFactory is BaseOptimexLending {
    /**
     * @notice Emitted when a user already has a position manager
     * @param user The address that already has a position manager
     * @param positionManager The address of the created position manager
     */
    error AlreadyHasPositionManager(address user, address positionManager);

    /**
     * @notice Emitted when a new account position manager is created
     * @param user The address that has been created a position manager for
     * @param positionManager The address of the new account position manager
     */
    event PositionManagerCreated(address indexed user, address indexed positionManager);

    /**
     * @notice Constructor
     * @param lendingManagement The address of the lending management contract
     */
    constructor(address lendingManagement) {
        _setLendingManagement(lendingManagement);
    }

    /**
     * @notice Creates a new account position manager for the given user
     * @param onBehalf The address of the user to create the position manager for
     * @return The address of the new account position manager
     */
    function createAccountPositionManager(address onBehalf) external returns (address) {
        // Check if the user already has a position manager
        address positionManager = _getAccountPositionManager(onBehalf);
        require(positionManager == address(0), AlreadyHasPositionManager(onBehalf, positionManager));

        // The position manager is created using BeaconProxy pattern to save gas costs, and assigned to the user
        // The beacon address is the lendingManagement contract
        // When creating beacon proxy, we also set the lendingManagement contract
        bytes memory data =
            abi.encodeWithSelector(BaseOptimexLending.setLendingManagement.selector, address(lendingManagement));
        positionManager = address(new BeaconProxy{salt: bytes32(uint256(uint160(onBehalf)))}(address(lendingManagement), data));
        _setAccountPositionManager(onBehalf, positionManager);

        emit PositionManagerCreated(onBehalf, positionManager);
        return positionManager;
    }
}
