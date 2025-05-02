// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MultiSigNFT is
    Initializable,
    ERC721URIStorage,
    ERC721Royalty,
    Ownable,
    UUPSUpgradeable,
    ReentrancyGuard
{
    using Strings for uint256;

    uint256 public tokenCounter;
    uint256 public mintPrice;
    uint256 public maxMintPerWallet;
    string public baseURI;
    address public multisig;

    mapping(address => uint256) public mintsPerWallet;

    event NFTMinted(address indexed recipient, uint256 indexed tokenId);

    constructor() ERC721("NFT", "EXNFT") {
        _disableInitializers();
    }

    modifier onlyMultisig() {
        require(msg.sender == multisig, "Only multisig wallet allowed");
        _;
    }

    function initialize(
        string memory _baseURI,
        uint96 _royaltyFeesInBips,
        uint256 _price,
        uint256 _maxMint,
        address _multisig
    ) external initializer {
        baseURI = _baseURI;
        mintPrice = _price;
        maxMintPerWallet = _maxMint;
        tokenCounter = 0;
        multisig = _multisig;

        _setDefaultRoyalty(msg.sender, _royaltyFeesInBips);
        _transferOwnership(_multisig);
    }

    function mintNFT(string memory tokenURI_, address recipient)external onlyMultisig{
        require(msg.sender == multisig, "Only multisig can mint");
        require(msg.value >= mintPrice, "Insufficient payment");
        require(
            mintsPerWallet[msg.sender] < maxMintPerWallet,
            "Mint limit exceeded"
        );
        require(
            mintsPerWallet[recipient] < maxMintPerWallet,
            "Mint limit exceeded"
        );
        uint256 newItemId = tokenCounter;
        _safeMint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI_);
        mintsPerWallet[recipient]++;
        tokenCounter++;
        emit NFTMinted(recipient, newItemId);
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Royalty)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    receive() external payable {}

    fallback() external payable {}
}
