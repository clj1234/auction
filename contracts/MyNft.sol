// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "hardhat/console.sol";
contract MyNft is ERC721Upgradeable{
    address private admin;
    uint private tokenId; // 自增代币ID
    // constructor() ERC721("",""){
    // }
    
    function initialize(string memory name,string memory symbol) public initializer{
        __ERC721_init(name,symbol);
        tokenId = 1;
        admin = msg.sender;
        console.log("init=======",admin);
    }

    function mint(address to) external returns (uint){
        uint currentId = tokenId;
        _mint(to, tokenId);
        tokenId++ ;
        return currentId;
    }

    function testUpgrade() public virtual pure returns(string memory){
        return "upgrade success  V1";
    }
}