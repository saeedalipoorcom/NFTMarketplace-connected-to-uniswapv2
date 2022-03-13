//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private itemID;
    Counters.Counter private itemSold;

    address payable public immutable marketOwner;
    uint256 private immutable listingFee = 0.1 ether;

    struct NFTItem {
        uint256 _itemID;
        uint256 _tokenID;
        uint256 _itemPrice;
        address payable _itemOwner;
        address payable _itemSeller;
        address _itemContract;
        bool _itemSold;
    }

    mapping(uint256 => NFTItem) public idToNFT;

    constructor() {
        marketOwner = payable(msg.sender);
    }

    function getListingFee() public pure returns (uint256) {
        return listingFee;
    }

    function createSaleItem(
        uint256 _tokenID,
        uint256 _tokenPrice,
        address _NFTContract
    ) external payable {
        require(msg.value == listingFee);
        require(_tokenPrice > 0);

        itemID.increment();
        uint256 newItemID = itemID.current();

        NFTItem storage newNFT = idToNFT[newItemID];

        newNFT._itemID = newItemID;
        newNFT._tokenID = _tokenID;
        newNFT._itemContract = _NFTContract;
        newNFT._itemOwner = payable(address(0));
        newNFT._itemSeller = payable(msg.sender);
        newNFT._itemPrice = _tokenPrice;
        newNFT._itemSold = false;

        IERC721(_NFTContract).transferFrom(msg.sender, address(this), _tokenID);
    }

    function buyNFTItem(uint256 _itemID, address _NFTContract)
        external
        payable
    {
        NFTItem storage matchItem = idToNFT[_itemID];
        uint256 NFTprice = matchItem._itemPrice;
        uint256 NFTtokenID = matchItem._tokenID;

        require(msg.value == NFTprice);

        matchItem._itemSeller.transfer(msg.value);
        IERC721(_NFTContract).transferFrom(
            address(this),
            msg.sender,
            NFTtokenID
        );
        matchItem._itemOwner = payable(msg.sender);
        matchItem._itemSold = true;

        payable(marketOwner).transfer(listingFee);
        itemSold.increment();
    }
}
