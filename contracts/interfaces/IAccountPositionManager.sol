// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "lib/metamorpho-v1.1/lib/morpho-blue/src/interfaces/IMorpho.sol";

interface IAccountPositionManager {
    function initialize(address initialLendingManagement, address initialOwner) external;
    function supplyCollateral(MarketParams memory marketParams, bytes memory data) external;
}
