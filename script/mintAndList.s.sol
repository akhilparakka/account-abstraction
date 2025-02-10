//SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script} from "forge-std/Script.sol";
import {TicketPool} from "../src/TicketPool.sol";
import {MockNft} from "../src/mocks/MockNft.sol";
import {console} from "forge-std/console.sol";

contract MintAndList is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address nftMarketplaceAddress = address(
            0x4f5ce484202e50E7c98EDD69706400925bEfE233
        ); // Replace with the actual address
        address mockNftAddress = address(
            0x13a3f83145cE29cB768C03438A8EEda8a70790A2
        ); // Replace with the actual address

        TicketPool ticketPool = TicketPool(nftMarketplaceAddress);
        MockNft mockNft = MockNft(mockNftAddress);

        console.log("Minting NFT...");
        mockNft.mintNft();
        uint256 tokenId = mockNft.getTokenCounter() - 1; // Get the correct token ID

        console.log("Approving NFT...");
        mockNft.approve(nftMarketplaceAddress, tokenId);

        console.log("Listing NFT...");
        ticketPool.listitem(mockNftAddress, tokenId, 0.1 ether);

        console.log("NFT Listed!");
    }
}
