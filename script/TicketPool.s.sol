//SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script} from "forge-std/Script.sol";
import {TicketPool} from "../src/TicketPool.sol";

contract TicketPoolScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        new TicketPool();
        vm.stopBroadcast();
    }
}
