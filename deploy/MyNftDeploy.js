const {upgrades} = require('hardhat');
const fs = require("fs");
const path = require("path");

module.exports = async ({getNamedAccounts, deployments,deployer}) => {
  const {save} = deployments;
  // const {deployer} = await getNamedAccounts();
  const myNft = await ethers.getContractFactory('MyNft');
  const myNftProxy = await upgrades.deployProxy(
    myNft,
    ['MyNft', 'MNFT'],
    {initializer: 'initialize',
    },
    deployer
  );
  await myNftProxy.waitForDeployment();
  console.log("代理合约地址--MyNft--：",await myNftProxy.getAddress());
  
  const proxyAddress = await myNftProxy.getAddress();
  const implAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);
  const storePath = path.resolve(__dirname, "./.cache/myNftProxy.json");
  const jsonStr = JSON.stringify({
      proxyAddress,
      implAddress,
      abi: myNft.interface.format("json"),
    });
    console.log("jsonStr =====",jsonStr);
  fs.writeFileSync(storePath,
      jsonStr,"utf-8");
    await save("myNftProxy", {
    abi: myNft.interface.format("json"),
    address: proxyAddress,
    // args: [],
    // log: true,
    })
    // console.log("部署成功-----部署合约地址--myNftProxy--：",proxyAddress);
    //   await deploy("MyContract", {
    //     from: deployer,
    //     args: ["Hello"],
    //     log: true,
    //   });
};
module.exports.tags = ['MyNftDeploy'];