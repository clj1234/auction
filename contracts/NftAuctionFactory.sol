// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8;

import "./utils/MyOwnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "./NftAuction.sol";
import "hardhat/console.sol";

contract NftAuctionFactory is Initializable,MyOwnable, IERC721Receiver ,UUPSUpgradeable{
    uint[] auctionsIds;
    mapping(uint => Auction) private auctions;
    uint private auctionId; // 拍卖自增id
    address private auctionAddress; // 拍卖合约地址   

    struct Auction{
        uint hightestPrice;         // 当前拍卖价格
        address lastBidder;         // 最后拍卖者地址
        address lastTokenAddress;   // 使用的货币地址
        uint startTime;            // 拍卖开始时间
        uint endTime;              // 拍卖结束时间
        address nftAddress;
        uint nftTokenId;
    }

    // constructor() {
    //     _disableInitializers();
    // }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function initialize(address _auctionAddress) public initializer{
        super.initOwner(msg.sender);
        auctionId = 1;
        auctionAddress = _auctionAddress;
    }

    function setAuctionAddress(address _auctionAddress) external onlyOwner{
        require(_auctionAddress != address(0),"_auctionContract is zero address");
        auctionAddress = _auctionAddress;
    }
    
    /**
     * 
     * @param bidTime 竞拍持续时间，单位秒  endTime = startTime + bidTime
     */
    function createAuction(address _nftAddress,uint _nftTokenId,uint _hightestPrice,address tokenAddress,uint bidTime) external onlyOwner{
        IERC721(_nftAddress).safeTransferFrom(msg.sender,address(this),_nftTokenId);
        auctions[auctionId] = Auction({
            hightestPrice: _hightestPrice,
            lastBidder: address(0),
            lastTokenAddress: tokenAddress,
            nftAddress: _nftAddress,
            nftTokenId: _nftTokenId,
            startTime: block.timestamp,
            endTime: block.timestamp + bidTime
        });
        auctionsIds.push(auctionId);
        auctionId++;
    }

    function endAuction(uint _auctionId) external onlyOwner{
        Auction memory auction = auctions[_auctionId];
        require(auction.nftAddress != address(0),"auction not exist");
        // 判断竞拍是否结束
        uint nowSec = block.timestamp;
        require(nowSec >= auction.endTime ,"auction not end");
        // 将nft转给最后竞拍者
        if(auction.lastBidder != address(0)){
            IERC721(auction.nftAddress).safeTransferFrom(address(this),auction.lastBidder,auction.nftTokenId);
        }else{
            // 没有人竞拍，归还给拍卖发起者
            IERC721(auction.nftAddress).safeTransferFrom(address(this),owner(),auction.nftTokenId);
        }
        // delete auctions[_auctionId];
    }

    function getAuctionInfo(uint _auctionId) public view returns(Auction memory){
        console.log("getAuctionInfo =====",_auctionId);
        return auctions[_auctionId];
    }

    function getAllAuctionInfo() external view returns(Auction[] memory){
        Auction[] memory arr = new Auction[](auctionsIds.length);
        for(uint i=0;i<auctionsIds.length;i++){
            arr[i] = auctions[auctionsIds[i]];
        }
        return arr;
    }

    function updateAuctionInfo(uint _auctionId,Auction memory _auction) external{
        require(msg.sender == auctionAddress,"only auction contract can call this function");
        Auction memory auction = auctions[_auctionId];
        // 1. 更新最高价
        auction.hightestPrice = _auction.hightestPrice;
        auction.lastBidder = _auction.lastBidder;
        // 2. 更新最后竞拍者
        auction.lastTokenAddress = _auction.lastTokenAddress;
        auctions[_auctionId] = auction;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}