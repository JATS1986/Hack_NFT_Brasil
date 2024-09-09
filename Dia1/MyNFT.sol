// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";

contract MyNFT is ERC721, ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter public tokenIdCounter;
 
   // Metadata information for each stage of the NFT on IPFS.
    string[] public MetadataUriList;

    constructor() ERC721("NFT Brasil Bootcamp 2024", "BRBO") {
    }

    function safeMint(address to, string memory metadataUri ) public {
        uint256 tokenId = tokenIdCounter.current();
        tokenIdCounter.increment();
        _safeMint(to, tokenId);
        MetadataUriList.push (metadataUri);
        _setTokenURI(tokenId, metadataUri);
    }

    function updateTokenURI(uint256 tokenId, string memory metadataUri) public {
        _setTokenURI(tokenId, metadataUri);
    }

    function tokenURI(uint256 tokenId)
        public view override(ERC721, ERC721URIStorage) returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    // The following function is an override required by Solidity.
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }
}