## 项目结构

​	

```
auction/
├── 
│── contracts/		`合约`
│── test/			`单元测试`
│── deploy/			`部署脚本`
│── deployments/	`部署合约的信息`

	
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

