// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8;
import "./MyNft.sol";
contract MyNftV2 is MyNft{
    function version() public pure returns(string memory){
        return "v2.0";
    }

    function testUpgrade() public override pure returns (string memory){
        return "upgrade success  V2";
    }
    
}