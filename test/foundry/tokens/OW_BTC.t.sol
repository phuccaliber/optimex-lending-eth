// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {OW_BTC} from "../../../contracts/tokens/OW_BTC.sol";
import "../../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract OW_BTCTest is Test {
    OW_BTC public token;
    address public owner;
    address public operator;
    address public user1;
    address public user2;

    function setUp() public {
        owner = makeAddr("owner");
        operator = makeAddr("operator");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        vm.startPrank(owner);
        token = new OW_BTC(owner);
        token.addOperator(operator);
        vm.stopPrank();
    }

    function test_InitialState() public view {
        assertEq(token.name(), "Optimex Wrapped Bitcoin");
        assertEq(token.symbol(), "OW_BTC");
        assertEq(token.decimals(), 8);
        assertEq(token.owner(), owner);
        assertTrue(token.isOperator(operator));
    }

    function test_AddOperator() public {
        address newOperator = makeAddr("newOperator");

        vm.prank(owner);
        token.addOperator(newOperator);

        assertTrue(token.isOperator(newOperator));
    }

    function test_AddOperator_RevertIfNotOwner() public {
        address newOperator = makeAddr("newOperator");

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user1));
        token.addOperator(newOperator);
    }

    function test_AddOperator_RevertIfZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(OW_BTC.ZeroAddress.selector));
        token.addOperator(address(0));
    }

    function test_RemoveOperator() public {
        vm.prank(owner);
        token.removeOperator(operator);

        assertFalse(token.isOperator(operator));
    }

    function test_RemoveOperator_RevertIfNotOwner() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user1));
        token.removeOperator(operator);
    }

    function test_RemoveOperator_RevertIfNotAnOperator() public {
        address nonOperator = makeAddr("nonOperator");

        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(OW_BTC.NotAnOperator.selector, nonOperator));
        token.removeOperator(nonOperator);
    }

    function test_AddToWhitelistBatch() public {
        address[] memory accounts = new address[](2);
        accounts[0] = user1;
        accounts[1] = user2;

        vm.prank(operator);
        token.addToWhitelistBatch(accounts);

        assertTrue(token.isWhitelisted(user1));
        assertTrue(token.isWhitelisted(user2));
    }

    function test_AddToWhitelistBatch_RevertIfNotOperator() public {
        address[] memory accounts = new address[](2);
        accounts[0] = user1;
        accounts[1] = user2;

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(OW_BTC.NotOperator.selector));
        token.addToWhitelistBatch(accounts);
    }

    function test_AddToWhitelistBatch_RevertIfEmptyArray() public {
        address[] memory accounts = new address[](0);

        vm.prank(operator);
        vm.expectRevert(abi.encodeWithSelector(OW_BTC.EmptyAccountsArray.selector));
        token.addToWhitelistBatch(accounts);
    }

    function test_AddToWhitelistBatch_RevertIfZeroAddress() public {
        address[] memory accounts = new address[](2);
        accounts[0] = user1;
        accounts[1] = address(0);

        vm.prank(operator);
        vm.expectRevert(abi.encodeWithSelector(OW_BTC.ZeroAddress.selector));
        token.addToWhitelistBatch(accounts);
    }

    function test_AddToWhitelistBatch_RevertIfAlreadyWhitelisted() public {
        address[] memory accounts = new address[](1);
        accounts[0] = user1;

        vm.startPrank(operator);
        token.addToWhitelistBatch(accounts);

        vm.expectRevert(abi.encodeWithSelector(OW_BTC.AlreadyWhitelisted.selector, user1));
        token.addToWhitelistBatch(accounts);
        vm.stopPrank();
    }

    function test_RemoveFromWhitelistBatch() public {
        address[] memory accounts = new address[](2);
        accounts[0] = user1;
        accounts[1] = user2;

        vm.startPrank(operator);
        token.addToWhitelistBatch(accounts);
        token.removeFromWhitelistBatch(accounts);
        vm.stopPrank();

        assertFalse(token.isWhitelisted(user1));
        assertFalse(token.isWhitelisted(user2));
    }

    function test_RemoveFromWhitelistBatch_RevertIfNotOperator() public {
        address[] memory accounts = new address[](2);
        accounts[0] = user1;
        accounts[1] = user2;

        vm.prank(operator);
        token.addToWhitelistBatch(accounts);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(OW_BTC.NotOperator.selector));
        token.removeFromWhitelistBatch(accounts);
    }

    function test_RemoveFromWhitelistBatch_RevertIfEmptyArray() public {
        address[] memory accounts = new address[](0);

        vm.prank(operator);
        vm.expectRevert(abi.encodeWithSelector(OW_BTC.EmptyAccountsArray.selector));
        token.removeFromWhitelistBatch(accounts);
    }

    function test_RemoveFromWhitelistBatch_RevertIfNotWhitelisted() public {
        address[] memory accounts = new address[](1);
        accounts[0] = user1;

        vm.prank(operator);
        vm.expectRevert(abi.encodeWithSelector(OW_BTC.NotWhitelisted.selector, user1));
        token.removeFromWhitelistBatch(accounts);
    }

    function test_Mint() public {
        address[] memory accounts = new address[](1);
        accounts[0] = user1;

        vm.prank(operator);
        token.addToWhitelistBatch(accounts);

        vm.prank(owner);
        token.mint(user1, 100);

        assertEq(token.balanceOf(user1), 100);
    }

    function test_Mint_RevertIfNotWhitelisted() public {
        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(OW_BTC.RecipientNotWhitelisted.selector, user1));
        token.mint(user1, 100);
    }

    function test_Transfer_BetweenWhitelistedAddresses() public {
        address[] memory accounts = new address[](2);
        accounts[0] = user1;
        accounts[1] = user2;

        vm.prank(operator);
        token.addToWhitelistBatch(accounts);

        vm.prank(owner);
        token.mint(user1, 100);

        vm.prank(user1);
        token.transfer(user2, 50);

        assertEq(token.balanceOf(user1), 50);
        assertEq(token.balanceOf(user2), 50);
    }

    function test_Transfer_RevertIfNotWhitelisted() public {
        address[] memory accounts = new address[](1);
        accounts[0] = user1;

        vm.prank(operator);
        token.addToWhitelistBatch(accounts);

        vm.prank(owner);
        token.mint(user1, 100);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(OW_BTC.RecipientNotWhitelisted.selector, user2));
        token.transfer(user2, 50);
    }

    function test_Transfer_RevertIfSenderNotWhitelisted() public {
        address[] memory accounts = new address[](1);
        accounts[0] = user2;

        vm.prank(operator);
        token.addToWhitelistBatch(accounts);

        vm.prank(owner);
        token.mint(user2, 100);

        vm.prank(user2);
        token.approve(user1, 50);

        vm.startPrank(user1); // user1 is not whitelisted
        vm.expectRevert(abi.encodeWithSelector(OW_BTC.RecipientNotWhitelisted.selector, user1));
        token.transferFrom(user2, user1, 50);
        vm.stopPrank();
    }

    function test_Burn() public {
        address[] memory accounts = new address[](1);
        accounts[0] = user1;

        vm.prank(operator);
        token.addToWhitelistBatch(accounts);

        vm.prank(owner);
        token.mint(user1, 100);

        vm.prank(user1);
        token.burn(50);

        assertEq(token.balanceOf(user1), 50);
    }

    function test_BurnFrom() public {
        address[] memory accounts = new address[](2);
        accounts[0] = user1;
        accounts[1] = user2;

        vm.prank(operator);
        token.addToWhitelistBatch(accounts);

        vm.prank(owner);
        token.mint(user1, 100);

        vm.prank(user1);
        token.approve(user2, 50);

        vm.prank(user2);
        token.burnFrom(user1, 50);

        assertEq(token.balanceOf(user1), 50);
    }
}
