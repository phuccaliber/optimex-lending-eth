// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../lib/openzeppelin-contracts/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "../lib/openzeppelin-contracts/contracts/proxy/beacon/BeaconProxy.sol";

contract AccountPositionManagerFactory is UpgradeableBeacon {
    mapping(address => address) public positionManagerAddresses;

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

    constructor(address implementation, address authorized) UpgradeableBeacon(implementation, authorized) {}

    /**
     * @notice Creates a new account position manager for the given user
     * @param onBehalf The address of the user to create the position manager for
     * @return The address of the new account position manager
     */
    function createAccountPositionManager(address onBehalf) external returns (address) {
        address positionManager = positionManagerAddresses[onBehalf];
        require(positionManager == address(0), AlreadyHasPositionManager(onBehalf, positionManager));
        positionManager = address(new BeaconProxy(address(this), ""));
        positionManagerAddresses[onBehalf] = positionManager;
        emit PositionManagerCreated(onBehalf, positionManager);
        return positionManager;
    }
}
