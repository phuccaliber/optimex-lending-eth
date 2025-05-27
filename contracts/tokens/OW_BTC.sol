// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title OW_BTC
 * @dev ERC20 token that can only be owned by whitelisted addresses, managed by operators
 * Token has 8 decimals to match BTC's decimal places
 */
contract OW_BTC is ERC20, Ownable {
    mapping(address => bool) public whitelist;
    mapping(address => bool) public operators;

    event AddressWhitelisted(address indexed account, address indexed operator);
    event AddressRemovedFromWhitelist(address indexed account, address indexed operator);
    event AddressesWhitelisted(address[] accounts, address indexed operator);
    event AddressesRemovedFromWhitelist(address[] accounts, address indexed operator);
    event OperatorAdded(address indexed operator);
    event OperatorRemoved(address indexed operator);

    error NotOperator();
    error ZeroAddress();
    error AlreadyOperator(address operator);
    error NotAnOperator(address operator);
    error EmptyAccountsArray();
    error AlreadyWhitelisted(address account);
    error NotWhitelisted(address account);
    error SenderNotWhitelisted(address sender);
    error RecipientNotWhitelisted(address recipient);

    constructor(address initialOwner) ERC20("Optimex Wrapped Bitcoin", "OW_BTC") Ownable(initialOwner) {}

    /**
     * @dev Returns the number of decimals used for token
     * Overrides the default 18 decimals to match BTC's 8 decimals
     */
    function decimals() public pure override returns (uint8) {
        return 8;
    }

    modifier onlyOperator() {
        if (!operators[msg.sender]) revert NotOperator();
        _;
    }

    /**
     * @dev Adds an operator
     * @param operator Address to be added as operator
     */
    function addOperator(address operator) external onlyOwner {
        if (operator == address(0)) revert ZeroAddress();
        if (operators[operator]) revert AlreadyOperator(operator);
        operators[operator] = true;
        emit OperatorAdded(operator);
    }

    /**
     * @dev Removes an operator
     * @param operator Address to be removed from operators
     */
    function removeOperator(address operator) external onlyOwner {
        if (!operators[operator]) revert NotAnOperator(operator);
        operators[operator] = false;
        emit OperatorRemoved(operator);
    }

    /**
     * @dev Adds multiple addresses to the whitelist
     * @param accounts Array of addresses to be whitelisted
     */
    function addToWhitelistBatch(address[] calldata accounts) external onlyOperator {
        if (accounts.length == 0) revert EmptyAccountsArray();

        for (uint256 i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            if (account == address(0)) revert ZeroAddress();
            if (whitelist[account]) revert AlreadyWhitelisted(account);
            whitelist[account] = true;
        }

        emit AddressesWhitelisted(accounts, msg.sender);
    }

    /**
     * @dev Removes multiple addresses from the whitelist
     * @param accounts Array of addresses to be removed from whitelist
     */
    function removeFromWhitelistBatch(address[] calldata accounts) external onlyOperator {
        if (accounts.length == 0) revert EmptyAccountsArray();

        for (uint256 i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            if (!whitelist[account]) revert NotWhitelisted(account);
            whitelist[account] = false;
        }

        emit AddressesRemovedFromWhitelist(accounts, msg.sender);
    }

    /**
     * @dev Checks if an address is whitelisted
     * @param account Address to check
     * @return bool Whether the address is whitelisted
     */
    function isWhitelisted(address account) public view returns (bool) {
        return whitelist[account];
    }

    /**
     * @dev Checks if an address is an operator
     * @param account Address to check
     * @return bool Whether the address is an operator
     */
    function isOperator(address account) public view returns (bool) {
        return operators[account];
    }

    /**
     * @dev Override of _update to add whitelist check
     */
    function _update(address from, address to, uint256 amount) internal virtual override {
        if (from != address(0)) {
            // Skip whitelist check for minting
            if (!isWhitelisted(from)) revert SenderNotWhitelisted(from);
        }
        if (to != address(0)) {
            // Skip whitelist check for burning
            if (!isWhitelisted(to)) revert RecipientNotWhitelisted(to);
        }
        super._update(from, to, amount);
    }

    /**
     * @dev Mints tokens to a whitelisted address
     * @param to Address to mint tokens to
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) external onlyOwner {
        if (!isWhitelisted(to)) revert RecipientNotWhitelisted(to);
        _mint(to, amount);
    }

    /**
     * @dev Allows users to burn their own tokens
     * @param amount Amount of tokens to burn
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    /**
     * @dev Allows users to burn tokens from another account with approval
     * @param account Address to burn tokens from
     * @param amount Amount of tokens to burn
     */
    function burnFrom(address account, uint256 amount) external {
        _spendAllowance(account, msg.sender, amount);
        _burn(account, amount);
    }
}
