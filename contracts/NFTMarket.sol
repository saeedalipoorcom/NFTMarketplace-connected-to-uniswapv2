//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
}

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private itemID;
    Counters.Counter private itemSold;

    address payable public immutable marketOwner;
    uint256 private immutable listingFee = 10000000000000000000;

    address private DappToken = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant UNISWAP_V2_ROUTER =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

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
    ) external {
        require(IERC20(DappToken).balanceOf(msg.sender) >= listingFee);
        IERC20(DappToken).transferFrom(msg.sender, address(this), listingFee);

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

    function addLiqForDappToken() private {
        // swap 50% of address this balance od dapp token
        uint256 DappForSwap = IERC20(DappToken).balanceOf(address(this)) / 2;

        address[] memory path;
        path[0] = DappToken;
        path[1] = WETH;

        // make swap dai to weth
        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
            DappForSwap,
            1,
            path,
            address(this),
            block.timestamp
        );

        // // approve DappToken to UNISWAP_V2_ROUTER
        // IERC20(DappToken).approve(
        //     UNISWAP_V2_ROUTER,
        //     IERC20(DappToken).balanceOf(address(this))
        // );
        // // approve WETH to UNISWAP_V2_ROUTER
        // IERC20(WETH).approve(
        //     UNISWAP_V2_ROUTER,
        //     IERC20(WETH).balanceOf(address(this))
        // );

        // add liq
        // IUniswapV2Router(UNISWAP_V2_ROUTER).addLiquidity(
        //     DappToken,
        //     WETH,
        //     IERC20(DappToken).balanceOf(address(this)),
        //     IERC20(WETH).balanceOf(address(this)),
        //     1,
        //     1,
        //     address(this),
        //     block.timestamp
        // );
    }
}
