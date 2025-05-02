// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract BasicNFT is ERC721URIStorage {
    uint256 public tokenIdCounter;

    constructor() ERC721("BasicNFT", "BNFT") {}

    function mintNFT(string memory _tokenURI) external returns (uint256) {
        uint256 newTokenId = tokenIdCounter;
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        tokenIdCounter++;
        return newTokenId;
    }
}
