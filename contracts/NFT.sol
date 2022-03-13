//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private tokenID;

    constructor() ERC721("DappToken", "DAPP") {}

    function mintNewNNFT(string memory _NFTURI) external returns (uint256) {
        tokenID.increment();
        uint256 newTokenID = tokenID.current();

        _safeMint(msg.sender, newTokenID);
        _setTokenURI(newTokenID, _NFTURI);

        return newTokenID;
    }
}
