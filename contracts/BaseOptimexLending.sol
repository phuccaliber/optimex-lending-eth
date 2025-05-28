// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./interfaces/ILendingManagement.sol";

contract BaseOptimexLending {
    ILendingManagement public lendingManagement;

    error LendingManagementAlreadyInitialized(address lendingManagement);
    error NotMPC(address sender);

    modifier onlyMPC() {
        if (!lendingManagement.isMPC(msg.sender)) revert NotMPC(msg.sender);
        _;
    }

    function setLendingManagement(address newLendingManagement) external {
        _setLendingManagement(newLendingManagement);
    }

    function _setLendingManagement(address newLendingManagement) internal {
        if (address(lendingManagement) != address(0)) {
            revert LendingManagementAlreadyInitialized(newLendingManagement);
        }
        lendingManagement = ILendingManagement(newLendingManagement);
    }

    function _getAccountPositionManager(address onBehalf) internal view returns (address) {
        return lendingManagement.accountPositionManagerAddresses(onBehalf);
    }

    function _setAccountPositionManager(address onBehalf, address accountPositionManager) internal {
        lendingManagement.setAccountPositionManager(onBehalf, accountPositionManager);
    }

    function _getMORPHO() internal view returns (address) {
        return lendingManagement.MORPHO();
    }
}
