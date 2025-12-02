// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Contract: MockGameNFT
// Role: A simple, mintable ERC-721 used as the asset to be locked in the Escrow.
contract MockGameNFT is ERC721, Ownable {
    constructor() ERC721("Game Character", "CHAR") {}

    // Function to easily mint test tokens to any address
    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }
}
