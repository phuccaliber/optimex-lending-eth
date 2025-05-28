// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface ILendingManagement {
    function accountPositionManagerAddresses(address onBehalf) external view returns (address);
    function setAccountPositionManager(address onBehalf, address accountPositionManager) external;
    function setPositionManagerFactory(address newPositionManagerFactory) external;
    function MORPHO() external view returns (address);
    function isMPC(address mpc) external view returns (bool);
}
