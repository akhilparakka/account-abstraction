// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {TicketPool} from "../src/TicketPool.sol";
import {MockNft} from "../src/mocks/MockNft.sol";
import {TicketPool_PriceMustBeAboveZero} from "../src/TicketPool.sol";

contract TicketPoolTest is Test {
    TicketPool public ticketPool;
    MockNft public mockNft;
    address public owner;
    address public buyer;

    function setUp() public {
        ticketPool = new TicketPool();
        mockNft = new MockNft();
        owner = address(1);
        buyer = address(2);
    }

    function testListWithZeroPrice() public {
        vm.startPrank(owner);
        mockNft.mintNft();
        vm.stopPrank();

        uint256 tokenId = mockNft.getTokenCounter() - 1;

        vm.startPrank(owner);
        mockNft.approve(address(ticketPool), tokenId);
        vm.stopPrank();

        vm.startPrank(owner);
        vm.expectRevert(
            abi.encodeWithSelector(TicketPool_PriceMustBeAboveZero.selector)
        );
        ticketPool.listitem(address(mockNft), tokenId, 0);
        vm.stopPrank();
    }
}
