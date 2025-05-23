// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./interfaces/ILendingManagement.sol";

contract BaseOptimexLending {
    ILendingManagement public lendingManagement;

    constructor(address initialLendingManagement) {
        lendingManagement = ILendingManagement(initialLendingManagement);
    }

    function setLendingManagement(address newLendingManagement) external {
        lendingManagement = ILendingManagement(newLendingManagement);
    }

    function _getAccountPositionManager(address onBehalf) internal view returns (address) {
        return lendingManagement.accountPositionManagerAddresses(onBehalf);
    }

    function _setAccountPositionManager(address onBehalf, address accountPositionManager) internal {
        lendingManagement.setAccountPositionManager(onBehalf, accountPositionManager);
    }
}
