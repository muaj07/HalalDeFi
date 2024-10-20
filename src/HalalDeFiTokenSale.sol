// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./HalalDeFiToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract HalalDeFiTokenSale is ReentrancyGuard {
    HalalDeFiToken public immutable tokenContract;  // Token being sold
    IERC20 public immutable usdtToken;              // USDT token contract
    address public immutable owner;                 // Owner of the sale contract
    address public immutable treasuryWallet;        // Treasury wallet for tax collection
    uint256 public tokensSold;                      // Number of tokens sold
    uint256 public tokenPrice = 10 * (10 ** 6);     // Token price in USDT (0.10 USDT)
    uint256 public increment = 2 * (10 ** 4);       // Price increment (0.002 USDT)
    uint256 public tokensPerIncrement = 1_000_000 * (10 ** 18); // Tokens after which price increments
    uint256 public nextPriceIncrease;               // Threshold for the next price increase
    uint256 public maxTokensForSale = 45_000_000 * (10 ** 18);  // Max tokens available for sale
    bool public saleEnded = false;                  // Has the sale ended?

    event Sell(address indexed _buyer, uint256 _amount);
    event SaleEnded(address indexed owner, uint256 remainingTokens);
    event Refund(address indexed _buyer, uint256 refundAmount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier saleActive() {
        require(!saleEnded, "Token sale has ended");
        _;
    }

    constructor(HalalDeFiToken _tokenContract, IERC20 _usdtToken, address _treasuryWallet) {
        require(_treasuryWallet != address(0), "Invalid treasury wallet address");
        owner = msg.sender;
        tokenContract = _tokenContract;
        usdtToken = _usdtToken;
        treasuryWallet = _treasuryWallet;
        nextPriceIncrease = tokensPerIncrement;
    }

    // Buyers can purchase tokens using USDT
    function buyTokens(uint256 _numberOfTokens, uint256 maxAcceptablePrice) public nonReentrant saleActive {
        require(tokensSold + _numberOfTokens <= maxTokensForSale, "Exceeds maximum tokens for sale");
        require(tokenPrice <= maxAcceptablePrice, "Price increased beyond acceptable threshold");

        uint256 cost = _numberOfTokens * tokenPrice / (10 ** 18);

        // Calculate the tax (1% of the cost)
        uint256 taxAmount = cost * 1 / 100;
        uint256 netCost = cost - taxAmount;

        // Transfer USDT for the tax to the treasury wallet
        require(usdtToken.transferFrom(msg.sender, treasuryWallet, taxAmount), "USDT tax transfer failed");

        // Transfer the remaining USDT to the owner
        require(usdtToken.transferFrom(msg.sender, owner, netCost), "USDT transfer failed");

        // Transfer the tokens to the buyer
        require(tokenContract.transfer(msg.sender, _numberOfTokens), "Token transfer failed");

        tokensSold += _numberOfTokens;

        // Price increment logic
        if (tokensSold >= nextPriceIncrease && tokenPrice < 188 * (10 ** 4)) {
            tokenPrice += increment;
            nextPriceIncrease += tokensPerIncrement;
        }

        emit Sell(msg.sender, _numberOfTokens);
    }

    // End the sale and transfer remaining tokens to the owner
    function endSale() public onlyOwner nonReentrant {
        require(!saleEnded, "Sale already ended");
        saleEnded = true;  // Mark the sale as ended

        uint256 remainingTokens = tokenContract.balanceOf(address(this));
        require(tokenContract.transfer(owner, remainingTokens), "Transfer of remaining tokens failed");

        emit SaleEnded(owner, remainingTokens);
    }
}

