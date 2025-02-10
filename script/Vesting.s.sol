//SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script} from "forge-std/Script.sol";
import {DIAMVesting} from "../src/Vesting.sol";

contract VestingScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        new DIAMVesting(address(0x468570093c50632bcD87BDc918DF0D63A4B3bF3B));
        vm.stopBroadcast();
    }
}
