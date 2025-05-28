// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import "./BaseOptimexLending.sol";
import "./tokens/OW_BTC.sol";
import "./interfaces/IAccountPositionManager.sol";

contract OptimexBundle is BaseOptimexLending {
    error PositionManagerNotFound();
    OW_BTC public immutable owBtc;
    
    constructor(address _owBtc) {
        owBtc = OW_BTC(_owBtc);
    }

    function supplyCollateral(
        MarketParams memory marketParams,
        uint256 amount,
        address onBehalf,
        bytes memory data
    ) external onlyMPC {
        address positionManager = _getAccountPositionManager(onBehalf);
        if (positionManager == address(0)) revert PositionManagerNotFound();
        // Check if positionManager is whitelisted for owBtc minting
        address[] memory addresses = new address[](1);
        addresses[0] = positionManager;
        if (!owBtc.isWhitelisted(positionManager)) {
            owBtc.addToWhitelistBatch(addresses);
        }
        // Mint OW_BTC to this contract
        owBtc.mint(positionManager, amount);

        // Call supplyCollateral on AccountPositionManager
        IAccountPositionManager(positionManager).supplyCollateral(marketParams, data);
    }
}
