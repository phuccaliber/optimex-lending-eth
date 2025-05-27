// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./interfaces/ILendingManagement.sol";

contract BaseOptimexLending {
    ILendingManagement public lendingManagement;

    error LendingManagementAlreadyInitialized(address lendingManagement);

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
}
