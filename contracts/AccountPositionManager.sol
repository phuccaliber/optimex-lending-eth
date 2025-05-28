// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./BaseOptimexLending.sol";
import "./interfaces/IAccountPositionManager.sol";

contract AccountPositionManager is IAccountPositionManager, BaseOptimexLending {
    address public owner;

    function initialize(address initialLendingManagement, address initialOwner) external {
        _setLendingManagement(initialLendingManagement);
        owner = initialOwner;
    }
}
