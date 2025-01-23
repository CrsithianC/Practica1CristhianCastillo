// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ClimateCoin is ERC20, Ownable {
    constructor(uint256 initialSupply) ERC20("ClimateCoin", "CC") {
        _mint(msg.sender, initialSupply);
    }
}

contract ClimateNFT is ERC721, Ownable {
    uint256 public currentTokenId;
    mapping(uint256=>string) public claimedTokens;

    constructor() ERC721("ClimateNFT", "CNFT") {}

    function mintNFT(
        address to,
        string memory tokenURI
    ) external onlyOwner returns (uint256) {
        uint256 newTokenId = currentTokenId;
        _mint(to, newTokenId);
        ClimateCoin.claimedTokens[newTokenId].tokenURI = tokenURI;
        climateCoin.claimedTokens[newTokenId];
        currentTokenId++;
        return newTokenId;
    }
}

contract ClimateManager is Ownable {
    ClimateCoin public climateCoin;
    uint256 public feePercentage;

    event NFTMinted(uint256 indexed tokenId, string projectName, string projectURL, address indexed developerAddress);
    event NFTExchanged(address indexed nftAddress, uint256 indexed nftId, address indexed sender, uint256 ccAmount, uint256 feeAmount);
    event CCBurn(uint256 ccAmount, uint256 indexed nftId);
    event FeePercentageUpdated(uint256 oldFeePercentage, uint256 newFeePercentage);

    constructor(uint256 initialSupply) {
        climateCoin = new ClimateCoin(initialSupply);
    }

    function mintNFT(
        uint256 credits,
        string memory projectName,
        string memory projectURL,
        address developerAddress
    ) external onlyOwner {
        require(credits > 0, "Credits must be greater than zero");
        require(bytes(projectName).length > 0, "Project name cannot be empty");
        require(bytes(projectURL).length > 0, "Project URL cannot be empty");
        require(developerAddress != address(0), "Invalid developer address");

        ClimateNFT nftContract = new ClimateNFT();
        string memory tokenURI = string(abi.encodePacked(projectName, " ", projectURL));
        uint256 tokenId = nftContract.mintNFT(developerAddress, tokenURI);
        emit NFTMinted(tokenId, projectName, projectURL, developerAddress);
    }

    function setFeePercentage(uint256 newFeePercentage) external onlyOwner {
        require(newFeePercentage <= 100, "Fee percentage cannot exceed 100");
        uint256 oldFeePercentage = feePercentage;
        feePercentage = newFeePercentage;
        emit FeePercentageUpdated(oldFeePercentage, newFeePercentage);
    }

    function exchangeNFTForCC(address nftAddress, uint256 nftId) external {
        require(feePercentage > 0, "Fee percentage not set");
        require(nftAddress != address(0), "Invalid NFT address");
        require(IERC721(nftAddress).ownerOf(nftId) == msg.sender, "Sender does not own the NFT");

        // Transfer NFT to contract
        IERC721(nftAddress).transferFrom(msg.sender, address(this), nftId);

        // Calculate fees
        uint256 ccAmount = 100; // Placeholder for actual calculation logic
        uint256 feeAmount = (ccAmount * feePercentage) / 100;
        uint256 finalAmount = ccAmount - feeAmount;

        require(finalAmount > 0, "Final amount must be greater than zero");

        // Transfer ClimateCoins to sender
        climateCoin.transfer(msg.sender, finalAmount);

        // Transfer fees to contract owner
        climateCoin.transfer(owner(), feeAmount);

        emit NFTExchanged(nftAddress, nftId, msg.sender, finalAmount, feeAmount);
    }

    function burnCCAndNFT(uint256 ccAmount, address nftAddress, uint256 nftId) external {
        require(ccAmount > 0, "Invalid ClimateCoin amount");
        require(nftAddress != address(0), "Invalid NFT address");
        require(IERC721(nftAddress).ownerOf(nftId) == msg.sender, "Sender does not own the NFT");

        // Burn ClimateCoins from sender
        climateCoin.transferFrom(msg.sender, address(0), ccAmount);

        // Burn NFT by transferring to zero address
        IERC721(nftAddress).transferFrom(msg.sender, address(0), nftId);

        emit CCBurn(ccAmount, nftId);
    }
}
