## 项目结构

​	

```
auction/
├── 
│── contracts/		`合约`
│── test/			`单元测试`
│── deploy/			`部署脚本`
│── deployments/	`部署合约的信息`
│── .env			`配置文件`

	
```





## 项目启动

```
npx hardhat deploy --tags MyNftDeploy --network localhost
npx hardhat deploy --tags NftAuctionDeploy --network localhost
==================================================================
修改./.env    auctionAddressConfig =  nftAuction的代理地址
==================================================================
npx hardhat deploy --tags NftAuctionFactoryDeploy --network localhost
```



## 单元测试

```
npx hardhat test .\test\TestAuction.js
```



## sopolia合约地址

```
NftAuctionFactory: "proxyAddress":"0x629999Af074A257c29a94f526939eC5ad6D249d1","implAddress":"0xE5AB9BC8fECB7393F8505ac5B4c18A28bC77092D"
```

```
NftAuction: "proxyAddress":"0x47E18c34Bfb33463F820322C9B300A8d5Fe9FA35","implAddress":"0xafE8D598D2F167880a4cD00E718eA709931Ef9B1"
```

```
MyNft: "proxyAddress":"0x26D19bC155b986e9D2abD5a4E0860BdF00A75080","implAddress":"0x9dcBb53DB7695e6DcA05189Ff4DAB97a728c8E8b"
```

