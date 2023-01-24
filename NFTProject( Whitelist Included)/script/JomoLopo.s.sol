//SPDX-License-Identifier
pragma solidity ^0.8.0;
import "forge-std/Script.sol";
import "../src/JomoLopoNFT.sol";

contract JomoLopoScript is Script
{
    function run() external{
        
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerKey);
        JomoLopoNft Nft = new JomoLopoNft("https://JomoLopoNft.com/");
        vm.stopBroadcast();
        
    }
}