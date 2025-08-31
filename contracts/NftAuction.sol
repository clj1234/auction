// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "./NftAuctionFactory.sol";
import "hardhat/console.sol";
import {Client} from "@chainlink/contracts-ccip/contracts/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/contracts/applications/CCIPReceiver.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./utils/MyCCIPReceiver.sol";
contract NftAuction is Initializable,OwnableUpgradeable ,UUPSUpgradeable{
    uint[] auctionsIds;
    mapping(address => AggregatorV3Interface) public priceFeeds; // 货币价格预言机   tokenAddress => (ETH > ? USD   USDC > ? USD)
    bool private usePriceFeed; // 是否使用价格预言机 
    address private auctionFactory; // 拍卖工厂地址   

    

    event Bid(address indexed bidder,uint auctionId,address tokenAddress,uint amount);

    // constructor() {
    //     _disableInitializers();
    // }


    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {

    }

    function initialize(bool _usePriceFeed) public initializer{
        usePriceFeed = _usePriceFeed;
        // ETH/USD
        priceFeeds[address(0)] = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        // USDC/USD
        priceFeeds[0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48] = AggregatorV3Interface(0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6);
        super.__Ownable_init(msg.sender);
    }

    function setAuctionFactory(address _auctionFactory) external onlyOwner{
        require(_auctionFactory != address(0),"_auctionFactory is zero address");
        auctionFactory = _auctionFactory;
    }

     /**
     * Returns the latest answer.
     */
    function getChainlinkDataFeedLatestAnswer(address tokenAddress) public view returns (int) {
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = priceFeeds[tokenAddress].latestRoundData();
        return answer;
    }

    function bid(uint _auctionId,address tokenAddress,uint amount) external payable{
        NftAuctionFactory.Auction memory auction = NftAuctionFactory(auctionFactory).getAuctionInfo(_auctionId);
        // 判断竞拍是否结束
        uint nowSec = block.timestamp;
        require(nowSec <= auction.endTime && nowSec >= auction.startTime ,"auction is end or not start");
        // 不是ERC20代币
        if(address(0) == tokenAddress){
            require(msg.value == amount,"msg.value must == amount");
        }else{
            // ERC20代币
            IERC20(tokenAddress).transferFrom(msg.sender,address(this),amount);
        }
        uint price = amount;
        uint hp = auction.hightestPrice;
        // 转换为美金
        if(usePriceFeed){
            price *= uint(getChainlinkDataFeedLatestAnswer(tokenAddress));
            hp *= uint(getChainlinkDataFeedLatestAnswer(auction.lastTokenAddress));
        }
        require(price > hp,"amount must > hightestPrice");
        // 不是第一次竞拍
        if(auction.lastBidder != address(0)){
            // ETH代币
            if(auction.lastTokenAddress == address(0)){
                // 退还上一个竞拍者的金额
                payable(auction.lastBidder).transfer(auction.hightestPrice);
            }else{
                // ERC20代币
                IERC20(tokenAddress).transfer(auction.lastBidder,auction.hightestPrice);
            }
        }
        auction.hightestPrice = amount;
        auction.lastBidder = msg.sender;
        auction.lastTokenAddress = tokenAddress;
        emit Bid(msg.sender,_auctionId,tokenAddress,amount);
        // 更新拍卖信息
        NftAuctionFactory(auctionFactory).updateAuctionInfo(_auctionId,auction);
    } 

    /**
     * 接收来自源链的Token
     */
    // function _ccipReceive(
    //     Client.Any2EVMMessage memory message
    // ) internal override {
    //     // 解析消息
    //     address sender = abi.decode(message.sender, (address));
    //     uint64 sourceChainSelector = message.sourceChainSelector;
        
    //     // 处理接收到的Token
    //     for (uint256 i = 0; i < message.destTokenAmounts.length; i++) {
    //         Client.EVMTokenAmount memory tokenAmount = message.destTokenAmounts[i];
            
    //         // 将Token转给消息发送者指定的接收者
    //         IERC20(tokenAmount.token).safeTransfer(
    //             abi.decode(message.receiver, (address)),
    //             tokenAmount.amount
    //         );
            
    //     }
    // }


    event MessageReceived(
        bytes32 indexed messageId, // The unique ID of the message.
        uint64 indexed sourceChainSelector, // The chain selector of the source chain.
        address sender, // The address of the sender from the source chain.
        string text // The text that was received.
    );

    // bytes32 private s_lastReceivedMessageId; // Store the last received messageId.
    // string private s_lastReceivedText; // Store the last received text.
    // function _ccipReceive(
    //     Client.Any2EVMMessage memory any2EvmMessage
    // ) internal override {
    //     s_lastReceivedMessageId = any2EvmMessage.messageId; // fetch the messageId
    //     s_lastReceivedText = abi.decode(any2EvmMessage.data, (string)); // abi-decoding of the sent text

    //     emit MessageReceived(
    //         any2EvmMessage.messageId,
    //         any2EvmMessage.sourceChainSelector, // fetch the source chain identifier (aka selector)
    //         abi.decode(any2EvmMessage.sender, (address)), // abi-decoding of the sender address,
    //         abi.decode(any2EvmMessage.data, (string))
    //     );
    // }

}