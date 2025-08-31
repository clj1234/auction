const { ethers, deployments } = require("hardhat")
const { expect } = require("chai")

    describe("Test NftAuction", function () {
        before(async function(){
            await initializer();
        })
        it("Should create and execute auction properly", async function () {
            await main();
        })
    })

    async function initializer(){
        const [signer] = await ethers.getSigners();
        await deployments.fixture(["MyNftDeploy","NftAuctionFactoryDeploy","NftAuctionDeploy"],{deployer:signer.address});
        // console.log("nftAuctionFactoryProxy.address =====",nftAuctionFactoryProxy.address);
        const nftAuctionProxy = await deployments.get("nftAuctionProxy");
        console.log("nftAuctionProxy.address =====",nftAuctionProxy.address);
        // 设置拍卖工厂合约地址
        const nftAuctionFactoryProxy = await deployments.get("nftAuctionFactoryProxy");
        const nftAuctionFactory = await ethers.getContractFactory("NftAuctionFactory");
        const nftAuctionFactoryContract = await nftAuctionFactory.attach(nftAuctionFactoryProxy.address).connect(signer);
        await nftAuctionFactoryContract.setAuctionAddress(nftAuctionProxy.address);

        await ethers.getContractFactory("NftAuction");
        const nftAuction = await ethers.getContractFactory("NftAuction");
        const nftAuctionContract = await nftAuction.attach(nftAuctionProxy.address).connect(signer);
        await nftAuctionContract.setAuctionFactory(nftAuctionFactoryProxy.address);

        console.log("set auctionFactory address success");
    }

    async function main(){
        
        const [signer, buyer,nftOwner] = await ethers.getSigners();
        console.log("signer.address =====",signer.address);
        const myNftProxy = await deployments.get("myNftProxy");
        const nftAuctionProxy = await deployments.get("nftAuctionProxy");
        const nftAuctionFactoryProxy = await deployments.get("nftAuctionFactoryProxy");
        const nftAuction = await ethers.getContractFactory("NftAuction");
        const nftAuctionFactory = await ethers.getContractFactory("NftAuctionFactory");
        // nftAuctionFactory合约连接用户
        const nftAuctionFactoryContract = await nftAuctionFactory.attach(nftAuctionFactoryProxy.address).connect(signer);
        // auction合约连接不同的用户
        const signerNftAuctionContract = await nftAuction.attach(nftAuctionProxy.address).connect(signer);
        const buyerNftAuctionContract = await nftAuction.attach(nftAuctionProxy.address).connect(buyer);
        // nft合约连接用户
        const myNftFactory = await ethers.getContractFactory("MyNft");
        const signerMyNftContract = await myNftFactory.attach(myNftProxy.address).connect(signer);
        // 合约铸造nft
        await signerMyNftContract.mint(signer.address);
        // 授权nft给拍卖工厂合约
        await signerMyNftContract.setApprovalForAll(nftAuctionFactoryProxy.address, true);
        
        console.log("mint nft success");
        const tokenId = 1;
        // 创建拍卖
        console.log("myNftProxy=====Address =====",myNftProxy.address);

        await nftAuctionFactoryContract.createAuction(myNftProxy.address,tokenId,300,ethers.ZeroAddress,1);
        // 出价
        let price = ethers.parseEther("0.01");
        await buyerNftAuctionContract.bid(1,ethers.ZeroAddress,price,{ value: price });
        // 等待拍卖结束
        await new Promise((resolve) => setTimeout(resolve, 2*1000));
        // 结束拍卖
        await nftAuctionFactoryContract.endAuction(1);
        // 查询拍卖信息
        const auctionInfo = await nftAuctionFactoryContract.getAuctionInfo(1);
        console.log("auctionInfo =====",auctionInfo);
        // 查询nft归属
        const ownerOfNft = await signerMyNftContract.ownerOf(tokenId);
        // console.log("ownerOfNft =====",ownerOfNft);
        // console.log("buyer.address =====",buyer.address);
        expect(ownerOfNft).to.equal(buyer.address);
    }