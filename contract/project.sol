// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract NFTArtMarketplace {
    struct NFT {
        uint256 tokenId;
        address payable creator;
        uint256 price;
        bool forSale;
    }

    uint256 private _tokenIds;
    mapping(uint256 => NFT) public nftCollection;
    mapping(uint256 => address) private _owners;

    event NFTMinted(uint256 tokenId, address creator, string tokenURI);
    event NFTListed(uint256 tokenId, uint256 price);
    event NFTSold(uint256 tokenId, address buyer);

    function mintNFT(string memory tokenURI, uint256 price) external {
        require(price > 0, "Price must be greater than zero");

        _tokenIds++;
        uint256 newTokenId = _tokenIds;

        nftCollection[newTokenId] = NFT(newTokenId, payable(msg.sender), price, true);
        _owners[newTokenId] = msg.sender;

        emit NFTMinted(newTokenId, msg.sender, tokenURI);
    }

    function buyNFT(uint256 tokenId) external payable {
        NFT storage nft = nftCollection[tokenId];
        require(nft.forSale, "NFT is not for sale");
        require(msg.value >= nft.price, "Insufficient funds sent");

        nft.creator.transfer(msg.value);
        _owners[tokenId] = msg.sender;
        nft.forSale = false;

        emit NFTSold(tokenId, msg.sender);
    }

    function listNFT(uint256 tokenId, uint256 price) external {
        require(_owners[tokenId] == msg.sender, "You are not the owner");
        require(price > 0, "Price must be greater than zero");

        nftCollection[tokenId].price = price;
        nftCollection[tokenId].forSale = true;

        emit NFTListed(tokenId, price);
    }
}
