// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface ILendingManagement {
    function accountPositionManagerAddresses(address onBehalf) external view returns (address);
    function setAccountPositionManager(address onBehalf, address accountPositionManager) external;
    function setPositionManagerFactory(address newPositionManagerFactory) external;
}
