// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {AbstaractionAccount} from "../src/Account.sol";

contract DeployAccount is Script {
    address constant ENTRYPOINT_ADDRESS =
        0x0000000071727De22E5E9d8BAf0edAc6f37da032;
    address constant BURNER_WALLET = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function run() public {}

    function deployAccount() public returns (AbstaractionAccount) {
        vm.startBroadcast(BURNER_WALLET);
        AbstaractionAccount account = new AbstaractionAccount(
            ENTRYPOINT_ADDRESS
        );
        account.transferOwnership(msg.sender);
        vm.stopBroadcast();

        return account;
    }
}
