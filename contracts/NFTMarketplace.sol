//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//ERC_721 is a standard used to build NFT Tokens as here each token will be unique and have it's own value

import "hardhat/console.sol";

contract NFTMarketPlace is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    uint256 listingPrice = 0.025 ether;  //the amount which will be deposited to owners's account on uploading nft

    address payable owner;

    mapping(uint256 => MarketItem) private idToMarketItem;


    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    } 

    //the event which will be triggered on creating market Items....

    event MarketItemCreated (
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    //here it says that the owner is the one who deploys the contract(we get from from msg.sender)
    
    constructor() {
        owner = payable(msg.sender);
    }
}