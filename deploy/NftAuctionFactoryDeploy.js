const {ethers ,upgrades} = require('hardhat');
const fs = require("fs");
const path = require("path");
require('dotenv').config({path: path.resolve(__dirname, '../.env')});

module.exports = async ({getNamedAccounts, deployments}) => {
  const {save} = deployments;
  const {deployer} = await getNamedAccounts();
  console.log("NftAuctionFactory====deployer =====",deployer);
  const nftAuctionFactory = await ethers.getContractFactory('NftAuctionFactory');
  // console.log("NftAuctionFactory====usePriceFeed =====",process.env.usePriceFeed);
  const nftAuctionFactoryProxy = await upgrades.deployProxy(
    nftAuctionFactory,
    [process.env.auctionAddressConfig],  // initializer args
    {initializer: 'initialize',deployer}
  );
  await nftAuctionFactoryProxy.waitForDeployment();
  console.log("代理合约地址--NftAuctionFactory--：",await nftAuctionFactoryProxy.getAddress());
  
  const proxyAddress = await nftAuctionFactoryProxy.getAddress();
  const implAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);
  const storePath = path.resolve(__dirname, "./.cache/nftAuctionFactoryProxy.json");
  const jsonStr = JSON.stringify({
      proxyAddress,
      implAddress,
      abi: nftAuctionFactory.interface.format("json"),
    });
    console.log("jsonStr =====",jsonStr);
  fs.writeFileSync(storePath,
      jsonStr,"utf-8");
    await save("nftAuctionFactoryProxy", {
    abi: nftAuctionFactory.interface.format("json"),
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
module.exports.tags = ['NftAuctionFactoryDeploy'];