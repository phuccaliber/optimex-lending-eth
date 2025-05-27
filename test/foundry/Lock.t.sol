// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../../contracts/Lock.sol";

contract LockTest is Test {
    Lock lock;
    uint256 unlockTime;
    uint256 lockedAmount;
    address payable owner;
    address payable otherAccount;

    function setUp() public {
        uint256 ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
        uint256 ONE_GWEI = 1_000_000_000;

        lockedAmount = ONE_GWEI;
        unlockTime = block.timestamp + ONE_YEAR_IN_SECS;

        owner = payable(makeAddr("owner"));
        otherAccount = payable(address(0x1));

        vm.deal(owner, 10 ether);
        vm.prank(owner);
        lock = new Lock{value: lockedAmount}(unlockTime);
    }

    function testUnlockTime() public view {
        assertEq(lock.unlockTime(), unlockTime);
    }

    function testOwner() public view {
        assertEq(lock.owner(), owner);
    }

    function testReceiveAndStoreFunds() public view {
        assertEq(address(lock).balance, lockedAmount);
    }

    function testDeployWithPastUnlockTime() public {
        vm.expectRevert("Unlock time should be in the future");
        new Lock{value: 1}(block.timestamp);
    }

    function testWithdrawTooSoon() public {
        vm.prank(owner);
        vm.expectRevert("You can't withdraw yet");
        lock.withdraw();
    }

    function testWithdrawNotOwner() public {
        vm.warp(unlockTime);
        vm.prank(otherAccount);
        vm.expectRevert("You aren't the owner");
        lock.withdraw();
    }

    function testWithdrawSuccess() public {
        vm.warp(unlockTime);
        uint256 preBalance = owner.balance;
        vm.prank(owner);
        lock.withdraw();
        assertEq(owner.balance, preBalance + lockedAmount);
        assertEq(address(lock).balance, 0);
    }
}
