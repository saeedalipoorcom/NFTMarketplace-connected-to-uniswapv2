const hre = require("hardhat");

async function main() {
  const NFT = await hre.ethers.getContractFactory("NFT");
  const NFTContract = await NFT.deploy();

  await NFTContract.deployed();

  console.log("NFTContract deployed to:", NFTContract.address);

  const NFTMarket = await hre.ethers.getContractFactory("NFTMarket");
  const NFTMarketContract = await NFTMarket.deploy();

  await NFTMarketContract.deployed();

  console.log("NFTMarketContract deployed to:", NFTMarketContract.address);

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
