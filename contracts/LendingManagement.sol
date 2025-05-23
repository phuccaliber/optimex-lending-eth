// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "./interfaces/ILendingManagement.sol";

contract LendingManagement is UpgradeableBeacon, ILendingManagement {
    mapping(address => address) public accountPositionManagerAddresses;

    address public positionManagerFactory;

    modifier onlyPositionManagerFactory() {
        require(msg.sender == positionManagerFactory, "Only the position manager factory can call this function");
        _;
    }

    constructor(address implementation, address initialOwner) UpgradeableBeacon(implementation, initialOwner) {}

    /**
     * @notice Sets the position manager factory
     * @dev Only the owner can call this function
     * @param newPositionManagerFactory The address of the new position manager factory
     */
    function setPositionManagerFactory(address newPositionManagerFactory) external onlyOwner {
        positionManagerFactory = newPositionManagerFactory;
    }

    /**
     * @notice Sets the account position manager for a given user
     * @dev Only the position manager factory can call this function
     * @param onBehalf The address of the user to set the account position manager for
     * @param accountPositionManager The address of the new account position manager
     */
    function setAccountPositionManager(address onBehalf, address accountPositionManager)
        external
        onlyPositionManagerFactory
    {
        // We keep this function minimal as possible, the logic for checking condition is executed on the factory contract
        accountPositionManagerAddresses[onBehalf] = accountPositionManager;
    }
}
