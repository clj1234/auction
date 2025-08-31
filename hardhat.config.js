require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("@openzeppelin/hardhat-upgrades")

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  saveDeployments: true,
  // skipDeploy: true,
  networks: {
  },
  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
    },
    signer: {
      default: 0,
    },
    buyer: {
      default: 1,
    },
  },
  // paths:{
  //   sources: "./contracts",
  // }
};
