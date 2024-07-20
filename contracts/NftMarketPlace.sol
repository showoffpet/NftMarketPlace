// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

error NftMarketPlace_PriceCannotBeZero();
error NftMarketPlace_NftNotApprovedByNftMarketPlace();
error NftMarketPlace_NotOwner();
error NftMarketPlace_NotListed();

contract NftMarketPlace {
    //list an NFT
    //Buy NFT
    //Update NFT item
    //Cancel an NFT Sale

    //properties that an NFT should have? - price, tokenId, address
    struct Listing {
        uint256 price;
        address seller;
    }

    //Mapping of listing => address ==> tokenId ==> Listing
    mapping(address => mapping(uint256 => Listing)) private s_listings;

    mapping(address => uint256) private s_proceeds; // how we check the amount associated with a seller

    function listItem(
        uint256 price,
        address nftAddress,
        uint256 tokenId
    ) external isOwner(nftAddress, tokenId, msg.sender) {
        if (price <= 0) {
            revert NftMarketPlace_PriceCannotBeZero();
        }
        ERC721URIStorage nft = ERC721URIStorage(nftAddress);
        if (nft.getApproved(tokenId) != address(this)) {
            revert NftMarketPlace_NftNotApprovedByNftMarketPlace();
        }
        s_listings[nftAddress][tokenId] = Listing(price, msg.sender);
    }

    function updateNft(
        //it must already been listed.
        uint256 newPrice,
        address nftAddress,
        uint256 tokenId
    )
        external
        isListed(nftAddress, tokenId)
        isOwner(nftAddress, tokenId, msg.sender)
    {
        if (newPrice <= 0) {
            revert NftMarketPlace_PriceCannotBeZero();
        }
        // s_listings[nftAddress][tokenId] = Listing(newPrice, msg.sender);
        //OR
        s_listings[nftAddress][tokenId].price = newPrice;
    }

    function removeListing(
        address nftAddress,
        uint256 tokenId
    )
        external
        isListed(nftAddress, tokenId)
        isOwner(nftAddress, tokenId, msg.sender)
    {
        delete s_listings[nftAddress][tokenId];
    }

    modifier isListed(address nftAddress, uint256 tokenId) {
        Listing memory listed = s_listings[nftAddress][tokenId];
        if (listed.price <= 0) {
            revert NftMarketPlace_NotListed();
        }
        _;
    }

    modifier isOwner(
        address nftAddress,
        uint256 tokenId,
        address spender
    ) {
        ERC721URIStorage nft = ERC721URIStorage(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (owner != spender) {
            revert NftMarketPlace_NotOwner();
        }
        _;
    }
}
