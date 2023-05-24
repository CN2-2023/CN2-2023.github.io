// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/draft-ERC721Votes.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyToken is ERC721, Pausable, Ownable, EIP712, ERC721Votes {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    // Name of the token and its symbol
    string private _name = "MyFinalToken";
    string private _symbol = "MFT";

    // number of pre-minted tokens
    uint256 public constant MAX_TOKEN_CIRCULATION = 2;

    // Value of each token to be sold in eth
    uint256 public VALUE_PER_TOKEN = 0.001 ether;

    // Fee amount to be paid to the owner on each sale (10% of the sale price)
    uint256 public FEE_AMOUNT = 10;

    // Keep track of the token balances of each address
    mapping(address => uint256) private _tokenBalances;

    // Mapping to store prices of tokens put on sale
    mapping(uint256 => uint256) public tokenPrices;

    // Mapping to store approved buyers for each token
    mapping(uint256 => address) public tokenBuyers;

    // Contract web page or IPFS file
    string private _lawContract;

    // Digital Twin file url or IPFS file
    string private _digitalTwin;


    constructor(string memory lawContract, string memory digitalTwin) ERC721(_name, _symbol) EIP712(_name, "1") {
        // set the base URI
        _lawContract = lawContract;
        _digitalTwin = digitalTwin;
    }

    // Getter function to return the _lawContract
    function getlawContract() public view returns (string memory) {
        return _lawContract;
    }

    // Setter function to change the _lawContract. Only callable by the owner.
    function setlawContract(string memory newLawContract) public onlyOwner {
        _lawContract = newLawContract;
    }

    // Getter function to return the contractWebPage
    function getDigitalTwin() public view returns (string memory) {
        return _digitalTwin;
    }

    // Setter function to change the contractWebPage. Only callable by the owner.
    function setDigitalTwin(string memory newDigitalTwin) public onlyOwner {
        _digitalTwin = newDigitalTwin;
    }

   

    function buyToken() external payable {
        // check if the payment is sufficient
        require(msg.value >= VALUE_PER_TOKEN, "Insufficient payment");
        
        // check if the token supply has reached the maximum
        require(_tokenIdCounter.current() <= MAX_TOKEN_CIRCULATION, "Token supply has reached the maximum");

        // check if the buyer has already bought a token
        require(_tokenBalances[msg.sender] == 0, "You have already bought a token");


        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);

        // Transfer the payment to the owner
        payable(owner()).transfer(msg.value);

        // Update the token balance of the buyer
        _tokenBalances[msg.sender] += 1;
    }




    function sellToken(uint256 tokenId, uint256 salePrice, address buyer) external {
        // check that the caller of the function is the owner of the token
        require(msg.sender == ownerOf(tokenId), "Caller is not the owner of the token");

        // check that the salePrice is at least the VALUE_PER_TOKEN
        require(salePrice >= VALUE_PER_TOKEN, "Sale price is less than the minimum value per token");

        // check if the token is already on sale
        require(tokenPrices[tokenId] == 0, "Token is already on sale");

        // check if the buyer has already bought a token
        require(_tokenBalances[buyer] == 0, "Buyer has already bought a token");

        // put the token on sale and define the buyer
        tokenPrices[tokenId] = salePrice;
        tokenBuyers[tokenId] = buyer;
    }

    function buyToken_byID(uint256 tokenId) external payable {
        // check that the token is for sale
        require(tokenPrices[tokenId] != 0, "Token is not for sale");

        // check that the msg.sender is allowed to buy the token
        require(msg.sender == tokenBuyers[tokenId], "You are not allowed to buy this token");

        // calculate the fee to be paid to the owner (10% of the sale price)
        uint256 fee = (tokenPrices[tokenId] * FEE_AMOUNT) / 100;

        // check that the value sent with the function is at least the token price
        require(msg.value >= tokenPrices[tokenId] + fee, string(abi.encodePacked("Payment is not enough. Don't forget the fee which is of 10% of the sale price")));
        

        // get seller before transfer
        address seller = ownerOf(tokenId);

        // transfer the token from the seller to the buyer
        _safeTransfer(seller, msg.sender, tokenId, "");

        // remove the token from sale and buyer's approval
        tokenPrices[tokenId] = 0;
        tokenBuyers[tokenId] = address(0);

        // send the remaining funds to the seller
        payable(seller).transfer(msg.value - fee);

        // send the fee to the owner
        payable(owner()).transfer(fee);

        // Update the token balance of the buyer
        _tokenBalances[msg.sender] += 1;
        _tokenBalances[seller] -= 1;
    }

    
    function retrieveToken(address from, uint256 tokenId) public onlyOwner {
        // Ensure the token exists
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");

        // Transfer token back to owner
        _transfer(from, owner(), tokenId);

        // Update the token balance of the owner
        _tokenBalances[from] -= 1;
    }




    // The following functions are overrides required by Solidity.

    function _afterTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Votes)
    {
        super._afterTokenTransfer(from, to, tokenId, batchSize);
    }

        function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

}
