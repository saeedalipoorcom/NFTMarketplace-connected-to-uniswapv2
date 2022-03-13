const { expect } = require("chai");
const { ethers } = require("hardhat");

const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:7545");

const DAIABI = require("../mint-Token/dai-abi.json");
const daiAddress = "0x6b175474e89094c44da98b954eedeac495271d0f";

describe("", async () => {
  it("create NFT and list it for sale", async () => {
    const [owner] = await ethers.getSigners();

    const DAIContractWithProvider = new ethers.Contract(
      daiAddress,
      DAIABI,
      provider
    );
    const DAIContractWithSigner = new ethers.Contract(
      daiAddress,
      DAIABI,
      owner
    );

    console.log(
      ethers.utils
        .formatEther(await DAIContractWithProvider.balanceOf(owner.address))
        .toString()
    );

    const NFT = await ethers.getContractFactory("NFT");
    const NFTContract = await NFT.deploy();
    await NFTContract.deployed();

    const NFTMarket = await ethers.getContractFactory("NFTMarket");
    const NFTMarketContract = await NFTMarket.deploy();
    await NFTMarketContract.deployed();

    console.log(
      ethers.utils
        .formatEther(
          await DAIContractWithProvider.balanceOf(NFTMarketContract.address)
        )
        .toString()
    );

    // create nft item
    await NFTContract.mintNewNNFT("google");

    // check owner balance after create nft
    const ownerBalance = await NFTContract.balanceOf(owner.address);
    expect(ownerBalance.toString()).to.equal("1");

    // set approve for all to transfer from caller to market
    await NFTContract.setApprovalForAll(NFTMarketContract.address, true);

    await DAIContractWithSigner.approve(
      NFTMarketContract.address,
      ethers.utils.parseEther("10")
    );

    // now create item sale
    await NFTMarketContract.createSaleItem(
      1,
      ethers.utils.parseEther("1"),
      NFTContract.address
    );

    console.log(
      ethers.utils
        .formatEther(await DAIContractWithProvider.balanceOf(owner.address))
        .toString()
    );

    console.log(
      ethers.utils
        .formatEther(
          await DAIContractWithProvider.balanceOf(NFTMarketContract.address)
        )
        .toString()
    );

    // test seller of created item to be owner address
    const NFTItem = await NFTMarketContract.idToNFT(1);
    expect(NFTItem._itemSeller).to.equal(owner.address);

    // test price of created item to be 1 ether
    expect(NFTItem._itemPrice).to.equal(ethers.utils.parseEther("1"));

    // check item sol for created item should be false
    expect(NFTItem._itemSold).to.equal(false);

    // await NFTMarketContract.connect(investor1).buyNFTItem(
    //   NFTItem._itemID,
    //   NFTContract.address,
    //   {
    //     value: ethers.utils.parseEther("1"),
    //   }
    // );

    // // again get sold item
    // const soldNFTItem = await NFTMarketContract.idToNFT(1);

    // // check owner address
    // expect(soldNFTItem._itemOwner).to.equal(investor1.address);

    // // check sold field
    // expect(soldNFTItem._itemSold).to.equal(true);
  });
});
