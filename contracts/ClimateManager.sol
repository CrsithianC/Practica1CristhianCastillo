// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./ClimateCoin.sol";
import "./ClimateNFT.sol";

contract ClimateManager is Ownable {
    ClimateCoin public climateCoin;
    ClimateNFT public climateNFT;
    uint256 public feePercentage;

    event NFTMinted(uint256 indexed tokenId, string projectName, string projectURL, address indexed developerAddress);
    event NFTExchanged(address indexed nftAddress, uint256 indexed nftId, address indexed sender, uint256 ccAmount, uint256 feeAmount);
    event CCBurn(uint256 ccAmount, uint256 indexed nftId);
    event FeePercentageUpdated(uint256 oldFeePercentage, uint256 newFeePercentage);

    constructor(address _initialOwner, address _climateCoin, address _climateNFT) Ownable(_initialOwner) {
        climateCoin = ClimateCoin(_climateCoin);
        climateNFT = ClimateNFT(_climateNFT);
    }

    function setFeePercentage(uint256 newFeePercentage) external onlyOwner {
        require(newFeePercentage <= 100, "El porcentaje del Fee no puede pasarse del 100");
        uint256 oldFeePercentage = feePercentage;
        feePercentage = newFeePercentage;
        emit FeePercentageUpdated(oldFeePercentage, newFeePercentage);
    }

    function mintNFT(
        string memory projectName,
        string memory projectURL,
        address developerAddress
    ) external onlyOwner {
        require(bytes(projectName).length > 0, "El nombre del projecto no puede esar vacio");
        require(bytes(projectURL).length > 0, "La URL del projecto no puede estar vacia");
        require(developerAddress != address(0), "Direccion invalida");

        string memory tokenURI = string(abi.encodePacked(projectName, " ", projectURL));
        uint256 tokenId = climateNFT.mintNFT(developerAddress, tokenURI);
        emit NFTMinted(tokenId, projectName, projectURL, developerAddress);
    }

    function exchangeNFTForCC(address nftAddress, uint256 nftId) external {
        require(feePercentage > 0, "El porcentaje del Fee esta vacio");
        require(IERC721(nftAddress).ownerOf(nftId) == msg.sender, "No eres el dueno del NFT");

        IERC721(nftAddress).transferFrom(msg.sender, address(this), nftId);

        uint256 ccAmount = 100;
        uint256 feeAmount = (ccAmount * feePercentage) / 100;
        uint256 finalAmount = ccAmount - feeAmount;

        require(finalAmount > 0, "La cantidad debe de ser mayor que 0");

        climateCoin.transfer(msg.sender, finalAmount);

        climateCoin.transfer(owner(), feeAmount);

        emit NFTExchanged(nftAddress, nftId, msg.sender, finalAmount, feeAmount);
    }

    function burnCCAndNFT(uint256 ccAmount, address nftAddress, uint256 nftId) external {
        require(ccAmount > 0, "Cantidad de ClimateCoins invalida");
        require(IERC721(nftAddress).ownerOf(nftId) == msg.sender, "No eres el dueno del NFT");

        climateCoin.burn(msg.sender, ccAmount);

        IERC721(nftAddress).transferFrom(msg.sender, address(0), nftId);

        emit CCBurn(ccAmount, nftId);
    }
}
