// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {PackedUserOperation} from "account-abstraction/interfaces/PackedUserOperation.sol";
import {EntryPoint} from "account-abstraction/core/EntryPoint.sol";
import {IEntryPoint} from "account-abstraction/interfaces/IEntryPoint.sol";
import {MessageHashUtils} from "openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

contract SendPackedUserOp is Script {
    using MessageHashUtils for bytes32;
    EntryPoint public entryPoint;

    function run() public {
        vm.startBroadcast();
        entryPoint = new EntryPoint();
        vm.stopBroadcast();
    }

    function generateSignedUserOperation(
        bytes memory callData,
        address sender
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

        // Sign The data
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(sender, digest);
        userOp.signature = abi.encodePacked(r, s, v);

        return userOp;
    }

    function _generateUnsignedUserOperation(
        bytes memory callData,
        address sender,
        uint256 nonce
    ) internal pure returns (PackedUserOperation memory) {
        uint128 verifcationGasLimit = 16777216;
        uint128 callGasLimit = verifcationGasLimit;
        uint128 maxPriorityFeePerGas = 256;
        uint128 maxFeePerGas = maxPriorityFeePerGas;

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
// address sender;
// uint256 nonce;
// bytes initCode;
// bytes callData;
// bytes32 accountGasLimits;
// uint256 preVerificationGas;
// bytes32 gasFees;
// bytes paymasterAndData;
// bytes signature;
