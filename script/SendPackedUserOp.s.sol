// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {PackedUserOperation} from "account-abstraction/interfaces/PackedUserOperation.sol";
import {EntryPoint} from "account-abstraction/core/EntryPoint.sol";
import {IEntryPoint} from "account-abstraction/interfaces/IEntryPoint.sol";
import {MessageHashUtils} from "openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

contract SendPackedUserOp is Script {
    using MessageHashUtils for bytes32;
    IEntryPoint public entryPoint;

    // Constructor accepting an existing EntryPoint address
    constructor(address _entryPoint) {
        entryPoint = IEntryPoint(_entryPoint);
    }

    // Deploy a new EntryPoint if needed
    function deployEntryPoint() public returns (EntryPoint) {
        vm.startBroadcast();
        EntryPoint newEntryPoint = new EntryPoint();
        entryPoint = newEntryPoint;
        vm.stopBroadcast();
        return newEntryPoint;
    }

    // Generate a signed UserOperation using a private key
    function generateSignedUserOperation(
        bytes memory callData,
        address sender,
        uint256 privateKey
    ) public view returns (PackedUserOperation memory) {
        // Generate Unsigned Data
        uint256 nonce = vm.getNonce(sender) - 1;
        PackedUserOperation memory userOp = _generateUnsignedUserOperation(
            callData,
            sender,
            nonce
        );

        // Generate Hash
        bytes32 userOpHash = entryPoint.getUserOpHash(userOp);
        bytes32 digest = userOpHash.toEthSignedMessageHash();

        // Sign The data
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        userOp.signature = abi.encodePacked(r, s, v);

        return userOp;
    }

    // Generate a signed UserOperation using a Foundry address
    function generateSignedUserOperation(
        bytes memory callData,
        address sender,
        address signer
    ) public view returns (PackedUserOperation memory) {
        // Generate Unsigned Data
        uint256 nonce = vm.getNonce(sender);
        PackedUserOperation memory userOp = _generateUnsignedUserOperation(
            callData,
            sender,
            nonce
        );

        // Generate Hash
        bytes32 userOpHash = entryPoint.getUserOpHash(userOp);
        bytes32 digest = userOpHash.toEthSignedMessageHash();

        // Sign The data using Foundry's deterministic private key for address
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            uint256(keccak256(abi.encodePacked(signer))),
            digest
        );
        userOp.signature = abi.encodePacked(r, s, v);

        return userOp;
    }

    // Create an unsigned UserOperation
    function _generateUnsignedUserOperation(
        bytes memory callData,
        address sender,
        uint256 nonce
    ) internal pure returns (PackedUserOperation memory) {
        uint128 verifcationGasLimit = 1000000;
        uint128 callGasLimit = 1000000;
        uint128 maxPriorityFeePerGas = 3 gwei;
        uint128 maxFeePerGas = 6 gwei;

        return
            PackedUserOperation({
                sender: sender,
                nonce: nonce,
                initCode: hex"",
                callData: callData,
                accountGasLimits: bytes32(
                    (uint256(verifcationGasLimit) << 128) | callGasLimit
                ),
                preVerificationGas: verifcationGasLimit,
                gasFees: bytes32(
                    (uint256(maxPriorityFeePerGas) << 128) | maxFeePerGas
                ),
                paymasterAndData: hex"",
                signature: hex""
            });
    }
}
