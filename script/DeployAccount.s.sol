// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {AbstaractionAccount} from "../src/Account.sol";
import {EntryPoint} from "account-abstraction/core/EntryPoint.sol";

contract DeployAccount is Script {
    address constant BURNER_WALLET = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function run() public returns (AbstaractionAccount, EntryPoint) {
        vm.startBroadcast(BURNER_WALLET);

        EntryPoint entryPoint = new EntryPoint();

        AbstaractionAccount account = new AbstaractionAccount(
            address(entryPoint)
        );

        account.transferOwnership(msg.sender);

        vm.stopBroadcast();

        return (account, entryPoint);
    }
}
