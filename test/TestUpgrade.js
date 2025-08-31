const {} = require("chai");
const { ethers, upgrades,deployments} = require("hardhat");


describe("myNft Upgrade Test", function () {
    it("Should deploy and upgrade myNft contract", async function () {
        const [user1,user2] = await ethers.getSigners();
        await deployments.fixture(["MyNftDeploy"],{deployer:user1.address});

        const myNftProxy = await deployments.get("myNftProxy");
        const myNftFactory = await ethers.getContractFactory("MyNft");
        
        const myNftInstance = await myNftFactory.attach(myNftProxy.address).connect(user1);
        console.log("myNft =====testUpgrade", await myNftInstance.testUpgrade());
        const myNftV2 = await ethers.getContractFactory("MyNftV2");
        const upgraded = await upgrades.upgradeProxy(myNftProxy.address, myNftV2);
        console.log("myNft =====testUpgrade", await upgraded.testUpgrade());
        console.log("myNft upgraded");
        console.log("NftAuctionV2 address:", upgraded.address);
    })

})