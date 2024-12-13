// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract Chatter {
    event Message(address indexed sender, string message);

    function sendMessage(string calldata message) public {
        emit Message(msg.sender, message);
    }
}
