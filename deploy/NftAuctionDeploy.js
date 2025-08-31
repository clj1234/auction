const {ethers ,upgrades} = require('hardhat');
const fs = require("fs");
const path = require("path");
require('dotenv').config({path: path.resolve(__dirname, '../.env')});
const {usePriceFeed} = process.env.usePriceFeed;

module.exports = async ({getNamedAccounts, deployments}) => {
  const {save} = deployments;
  const {deployer} = await getNamedAccounts();
  const nftAuction = await ethers.getContractFactory('NftAuction');
  const nftAuctionProxy = await upgrades.deployProxy(
    nftAuction,
    [usePriceFeed],  // initializer args
    {initializer: 'initialize',deployer}
  );
  await nftAuctionProxy.waitForDeployment();
  console.log("代理合约地址--NftAuction--：",await nftAuctionProxy.getAddress());
  
  const proxyAddress = await nftAuctionProxy.getAddress();
  const implAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);
  const storePath = path.resolve(__dirname, "./.cache/nftAuctionProxy.json");
  const jsonStr = JSON.stringify({
      proxyAddress,
      implAddress,
      abi: nftAuction.interface.format("json"),
    });
    console.log("jsonStr =====",jsonStr);
  fs.writeFileSync(storePath,
      jsonStr,"utf-8");
    await save("nftAuctionProxy", {
    abi: nftAuction.interface.format("json"),
    address: proxyAddress,
    // args: [],
    // log: true,
    })
    // console.log("部署成功-----部署合约地址--NftAuctionDeploy--：",proxyAddress);
    //   await deploy("MyContract", {
    //     from: deployer,
    //     args: ["Hello"],
    //     log: true,
    //   });
};
module.exports.tags = ['NftAuctionDeploy'];