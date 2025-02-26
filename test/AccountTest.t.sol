// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {AbstaractionAccount} from "../src/Account.sol";
import {ERC20Mock} from "openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {EntryPoint} from "account-abstraction/core/EntryPoint.sol";
import {IEntryPoint} from "account-abstraction/interfaces/IEntryPoint.sol";
import {PackedUserOperation} from "account-abstraction/interfaces/PackedUserOperation.sol";
import {ECDSA} from "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";
import {SendPackedUserOp} from "../script/SendPackedUserOp.s.sol";

contract AbstactionAccountTest is Test {
    using MessageHashUtils for bytes32;

    uint256 constant AMOUNT = 1e18;

    address payable owner;
    uint256 ownerPrivateKey;
    address randomUser;

    AbstaractionAccount account;
    ERC20Mock usdc;
    EntryPoint entryPoint;
    SendPackedUserOp sendPackedUserOp;

    function setUp() public {
        address ownerAddr;
        (ownerAddr, ownerPrivateKey) = makeAddrAndKey("owner");
        owner = payable(ownerAddr);
        randomUser = makeAddr("randomuser");

        vm.deal(owner, 10 ether);

        entryPoint = new EntryPoint();
        sendPackedUserOp = new SendPackedUserOp(address(entryPoint));

        vm.startPrank(owner);
        account = new AbstaractionAccount(address(entryPoint));
        vm.stopPrank();

        usdc = new ERC20Mock();
        vm.deal(address(account), 1 ether);
    }

    function testOwnerCanExecuteCommands() public {
        // Arrange
        assertEq(usdc.balanceOf(address(account)), 0);
        bytes memory functionData = abi.encodeWithSelector(
            ERC20Mock.mint.selector,
            address(account),
            AMOUNT
        );

        // Act
        vm.prank(owner);
        account.execute(address(usdc), 0, functionData);

        // Assert
        assertEq(usdc.balanceOf(address(account)), AMOUNT);
    }

    function testNonOwnerCannotExecuteCommands() public {
        assertEq(usdc.balanceOf(address(account)), 0);
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
        account.execute(address(usdc), 0, functionData);
    }

    function testValidateSignature() public view {
        // Arrange
        bytes memory executeCalldata = abi.encodeWithSelector(
            AbstaractionAccount.execute.selector,
            address(usdc),
            0,
            abi.encodeWithSelector(
                ERC20Mock.mint.selector,
                address(account),
                AMOUNT
            )
        );

        PackedUserOperation memory userOp = sendPackedUserOp
            .generateSignedUserOperation(
                executeCalldata,
                address(account),
                ownerPrivateKey
            );
        bytes32 userOperationHash = entryPoint.getUserOpHash(userOp);

        // ACT
        address actualSigner = ECDSA.recover(
            userOperationHash.toEthSignedMessageHash(),
            userOp.signature
        );

        // Assert
        assertEq(actualSigner, owner);
        assertEq(actualSigner, account.owner());
    }

    function testValidationOfUserOps() public {
        // Arrange
        bytes memory executeCalldata = abi.encodeWithSelector(
            AbstaractionAccount.execute.selector,
            address(usdc),
            0,
            abi.encodeWithSelector(
                ERC20Mock.mint.selector,
                address(account),
                AMOUNT
            )
        );

        PackedUserOperation memory userOp = sendPackedUserOp
            .generateSignedUserOperation(
                executeCalldata,
                address(account),
                ownerPrivateKey
            );
        bytes32 userOperationHash = entryPoint.getUserOpHash(userOp);
        uint256 missingAccountFund = 1e18;

        // ACT
        vm.prank(address(entryPoint));
        uint256 validationData = account.validateUserOp(
            userOp,
            userOperationHash,
            missingAccountFund
        );

        assertEq(validationData, 0);
    }

    function testEntryPointCanExecuteCommands() public {
        // Arrange
        bytes memory executeCalldata = abi.encodeWithSelector(
            AbstaractionAccount.execute.selector,
            address(usdc),
            0,
            abi.encodeWithSelector(
                ERC20Mock.mint.selector,
                address(account),
                AMOUNT
            )
        );
        PackedUserOperation memory userOp = sendPackedUserOp
            .generateSignedUserOperation(
                executeCalldata,
                address(account),
                ownerPrivateKey
            );
        PackedUserOperation[] memory ops = new PackedUserOperation[](1);
        ops[0] = userOp;

        // Act
        vm.deal(address(account), 1e18);

        vm.prank(randomUser);
        entryPoint.handleOps(ops, payable(randomUser));

        // Assert
        assertEq(usdc.balanceOf(address(account)), AMOUNT);
    }
}
