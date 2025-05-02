// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTStaking {
    IERC721 public nft;
    IERC20 public rewardToken;

    mapping(address => uint256[]) public stakedNFTs;
    mapping(uint256 => address) public ownerOfNFT;

    constructor(address _nft, address _rewardToken) {
        nft = IERC721(_nft);
        rewardToken = IERC20(_rewardToken);
    }

    function stake(uint256 _tokenId) external {
        nft.transferFrom(msg.sender, address(this), _tokenId);
        stakedNFTs[msg.sender].push(_tokenId);
        ownerOfNFT[_tokenId] = msg.sender;
    }

    function unstake(uint256 _tokenId) external {
        require(ownerOfNFT[_tokenId] == msg.sender, "Not owner");
        nft.transferFrom(address(this), msg.sender, _tokenId);
        ownerOfNFT[_tokenId] = address(0);
    }

    function claimReward(uint256 _amount) external {
        rewardToken.transfer(msg.sender, _amount); // بدون حساب زمان یا سود واقعی!
    }
}
