// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ClimateNFT is ERC721URIStorage, Ownable {
    uint256 public currentTokenId;

    constructor(address initialOwner) ERC721("ClimateNFT", "CNFT") Ownable(initialOwner) {}

    function mintNFT(
        address to,
        string memory tokenURI
    ) external onlyOwner returns (uint256) {
        uint256 newTokenId = currentTokenId;
        _mint(to, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        currentTokenId++;
        return newTokenId;
    }
}
