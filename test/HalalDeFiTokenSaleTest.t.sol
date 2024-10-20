// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";                    // Foundry's standard test library for testing contracts
import "../src/HalalDeFiToken.sol";             // The token being sold in the token sale
import "../src/HalalDeFiTokenSale.sol";         // The token sale contract under test
import "../src/MockUSDT.sol";                   // A mock implementation of the USDT (ERC20) token for testing purposes

// The main test contract for the HalalDeFiTokenSale contract
contract HalalDeFiTokenSaleTest is Test {
    HalalDeFiToken halalToken;                  // Instance of the HalalDeFiToken being sold
    HalalDeFiTokenSale tokenSale;               // Instance of the HalalDeFiTokenSale contract
    MockUSDT usdtToken;                         // Mock instance of USDT (an ERC20 token used to buy HalalDeFiToken)
    address owner;                              // Owner of the contract (msg.sender in tests)
    address treasuryWallet = address(0x123);    // Treasury wallet address for receiving tax/fees

    // The setUp() function is executed before each test. It initializes contracts and states required for testing.
    function setUp() public {
        owner = msg.sender;                     // Set the test owner as the current transaction sender

        // Deploy a mock USDT token (ERC20 with mint functionality for testing)
        usdtToken = new MockUSDT();

        // Mint 1 million USDT (USDT typically has 6 decimals) for the test owner
        usdtToken.mint(owner, 1000000 * (10 ** 6));

        // Deploy HalalDeFiToken with a total supply of 45 million tokens (with 18 decimals)
        halalToken = new HalalDeFiToken(45_000_000 * (10 ** 18), owner);

        // Deploy the token sale contract using the deployed token contract, USDT, and treasury wallet address
        tokenSale = new HalalDeFiTokenSale(halalToken, usdtToken, treasuryWallet);
    }

    // Test to ensure the initial conditions of the token sale contract are correctly set
    function testInitialSaleConditions() public view {
        // Verify the initial token price is correctly set to 0.10 USDT (USDT has 6 decimals)
        assertEq(tokenSale.tokenPrice(), 10 * (10 ** 6));

        // Verify that no tokens have been sold yet
        assertEq(tokenSale.tokensSold(), 0);
    }

    // Test to simulate buying tokens using USDT and ensure the contract behaves as expected
    function testBuyTokens() public {
        // First, the buyer (msg.sender) approves the token sale contract to spend their USDT tokens
        usdtToken.approve(address(tokenSale), 1000 * (10 ** 6));  // Approve 1000 USDT

        // Call the buyTokens function to purchase 100 HalalDeFiTokens with an upper price limit of 0.12 USDT per token
        // The function ensures that the token price doesn't exceed the buyer's acceptable price (0.12 USDT)
        tokenSale.buyTokens(100 * (10 ** 18), 12 * (10 ** 6));

        // After buying, verify that 100 tokens have been sold
        assertEq(tokenSale.tokensSold(), 100 * (10 ** 18));

        // Verify that the buyer (msg.sender) has received 100 HalalDeFiTokens in their balance
        assertEq(halalToken.balanceOf(owner), 100 * (10 ** 18));
    }

    // Test to simulate ending the token sale by the contract owner
    function testEndSale() public {
        // Call the endSale function to end the token sale
        tokenSale.endSale();

        // Verify that the saleEnded flag is set to true, indicating the sale has ended
        assertEq(tokenSale.saleEnded(), true);
    }
}

