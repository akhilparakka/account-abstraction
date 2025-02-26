// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {AbstaractionAccount} from "../src/Account.sol";
import {DeployAccount} from "../script/DeployAccount.s.sol";
import {ERC20Mock} from "openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {SendPackedUserOp, PackedUserOperation, entryPoint} from "../script/SendPackedUserOp.s.sol";
import {ECDSA} from "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

contract AbstactionAccountTest is Test {
    AbstaractionAccount account;
    ERC20Mock usdc;
    uint256 constant AMOUNT = 1e18;
    address randomUser = makeAddr("random-user");
    SendPackedUserOp sendPackedUserOp;

    function setUp() public {
        DeployAccount deployAccount = new DeployAccount();
        account = deployAccount.deployAccount();
        usdc = new ERC20Mock();
        sendPackedUserOp = new SendPackedUserOp();
    }

    function testOwnerCanExecuteCommands() public {
        // Arrange
        assertEq(usdc.balanceOf(address(account)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(
            ERC20Mock.mint.selector,
            address(account),
            AMOUNT
        );

        // Act
        vm.prank(account.owner());
        account.execute(dest, value, functionData);

        // Assert
        assertEq(usdc.balanceOf(address(account)), AMOUNT);
    }

    function testNonOwnerCannotExecuteCommands() public {
        assertEq(usdc.balanceOf(address(account)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(
            ERC20Mock.mint.selector,
            address(account),
            AMOUNT
        );

        vm.prank(randomUser);
        vm.expectRevert(
            AbstaractionAccount
                .AbstaractionAccount__NotFromEntryPointorOwner
                .selector
        );
        account.execute(dest, value, functionData);
    }

    function testRecoverSignedOp() public view {
        // Arrange
        assertEq(usdc.balanceOf(address(account)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(
            ERC20Mock.mint.selector,
            address(account),
            AMOUNT
        );

        bytes memory executeCalldata = abi.encodeWithSelector(
            AbstaractionAccount.execute.selector,
            dest,
            value,
            functionData
        );

        PackedUserOperation memory packedUserOp = sendPackedUserOp
            .generateSignedUserOperation(executeCalldata, account.owner());

        bytes32 userOperationHash = entryPoint.getUserOpHash(packedUserOp);

        //Act
        ECDSA.recover();
        //Assert
    }
}
