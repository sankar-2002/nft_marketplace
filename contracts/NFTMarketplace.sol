//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//ERC_721 is a standard used to build NFT Tokens as here each token will be unique and have it's own value

import "hardhat/console.sol";

contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    uint256 listingPrice = 0.025 ether; //the amount owner has to spend to list the nft in the marketPlace

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

    event MarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    //here it says that the owner is the one who deploys the contract(we get from from msg.sender)
    //setting the owner....

    constructor() ERC721("Metaverse Tokens", "METT") {
        owner = payable(msg.sender);
    }

    function updateListingPrice(uint _listingPrice) public payable {
        require(
            owner == msg.sender,
            "Only marketplace Owner can update the listing price"
        ); //making sure you are the owner

        listingPrice = _listingPrice; //updating the listing price...
    }

    //view means it does not handle any logic it just returns some value

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    function createToken(
        string memory tokenURI,
        uint256 price
    ) public payable returns (uint) {
        _tokenIds.increment(); //incrementing token ids
        uint256 newTokenId = _tokenIds.current();
        _mint(msg.sender, newTokenId); //minting using newtokenId
        _setTokenURI(newTokenId, tokenURI); //setting tokenURI

        createMarketItem(newTokenId, price); //listing the token in our marketPlace

        return newTokenId;
    }

    function createMarketItem(uint256 tokenId, uint256 price) private {
        //condition checks....before creating marketItem

        require(price > 0, "Price must be at least 1");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing Price"
        );

        //creating market Item...

        idToMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender), //current address (seller)
            payable(address(this)), //(owner)currently 0 as we are listing in marketPlace
            price,
            false
        );

        //transfering ownership (joh buy karega usko ownership transfer)....

        _transfer(msg.sender, address(this), tokenId);

        //as we r already listening in the event now we'll emit that event
        emit MarketItemCreated(
            tokenId,
            msg.sender,
            address(this),
            price,
            false
        );
    }

    function resellToken(uint256 tokenId, uint256 price) public payable {
        require(
            idToMarketItem[tokenId].owner == msg.sender,
            "Only item owner can perform this operation"
        );
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );

        // changing the status of the item as we r going to resell
        idToMarketItem[tokenId].sold = false;
        idToMarketItem[tokenId].price = price;
        idToMarketItem[tokenId].seller = payable(msg.sender);
        idToMarketItem[tokenId].owner = payable(address(this));

        _itemsSold.decrement();

        _transfer(msg.sender, address(this), tokenId); //transfering ownership....
    }

    //selling token using nftMarketPlace

    function createMarketSale(uint256 tokenId) public payable {
        uint price = idToMarketItem[tokenId].price;

        require(
            msg.value == price,
            "Please submit the asking price in order to complete the purchase"
        );

        idToMarketItem[tokenId].owner = payable(msg.sender); // setting owner
        idToMarketItem[tokenId].sold = true;
        idToMarketItem[tokenId].seller = payable(address(0)); //here seller is nftmarketPlace it belongs to nftMarketPlace (address is zero)

        _itemsSold.increment();

        _transfer(address(this), msg.sender, tokenId);

        payable(owner).transfer(listingPrice); //owner get's the listing price we declared above
        payable(idToMarketItem[tokenId].seller).transfer(msg.value); //transferring the price of nft from buyer to seller
    }

    //fetchMarketItems gives all the unsold items in the marketPlace....

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint itemCount = _tokenIds.current();
        uint unsoldItemCount = _tokenIds.current() - _itemsSold.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount); //creating an array named items of type marketItem

        for (uint i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(this)) {
                //checking whether owner is a marketPlace
                uint currentId = i + 1;

                MarketItem storage currentItem = idToMarketItem[currentId];

                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        } //counting how many this user(owner) has

        MarketItem[] memory items = new MarketItem[](itemCount);

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint currentId = i + 1;

                MarketItem storage currentItem = idToMarketItem[currentId];

                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchItemsListed() public view returns (MarketItem[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        } //counting how many this user(owner) has

        MarketItem[] memory items = new MarketItem[](itemCount);

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                uint currentId = i + 1;

                MarketItem storage currentItem = idToMarketItem[currentId];

                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }
}
