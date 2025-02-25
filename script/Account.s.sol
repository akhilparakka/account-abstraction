// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "account-abstraction/core/EntryPoint.sol";

contract DeployEntryPoint is Script {
    function run() external {
        vm.startBroadcast();
        EntryPoint entryPoint = new EntryPoint();
        console.log("EntryPoint deployed at:", address(entryPoint));
        vm.stopBroadcast();
    }
}
