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
    uint256 initialSupply = 45_000_000 * (10 ** 18);  // Initial supply of HalalDeFiTokens
    uint256 tokenPrice = 10 * (10 ** 6);        // Initial token price (0.10 USDT)

    // The setUp() function is executed before each test. It initializes contracts and states required for testing.
    function setUp() public {
        owner = msg.sender;                     // Set the test owner as the current transaction sender

        // Deploy a mock USDT token (ERC20 with mint functionality for testing)
        usdtToken = new MockUSDT();

        // Mint 1 million USDT (USDT typically has 6 decimals) for the test owner
        usdtToken.mint(owner, 1000000 * (10 ** 6));

        // Deploy HalalDeFiToken with a total supply of 45 million tokens (with 18 decimals)
        halalToken = new HalalDeFiToken(initialSupply, treasuryWallet, 1); // 1% tax

        // Deploy the token sale contract using the deployed token contract, USDT, and treasury wallet address
        tokenSale = new HalalDeFiTokenSale(halalToken, usdtToken, treasuryWallet);
    }

    // Test to ensure the initial conditions of the token sale contract are correctly set
    function testInitialSaleConditions() public view {
        // Verify the initial token price is correctly set to 0.10 USDT (USDT has 6 decimals)
        assertEq(tokenSale.tokenPrice(), tokenPrice);

        // Verify that no tokens have been sold yet
        assertEq(tokenSale.tokensSold(), 0);

        // Verify the maxTokensForSale is set to 45 million tokens
        assertEq(tokenSale.maxTokensForSale(), 45_000_000 * (10 ** 18));

        // Verify the sale has not ended
        assertEq(tokenSale.saleEnded(), false);
    }

    // Test to simulate buying tokens using USDT and ensure the contract behaves as expected
    function testBuyTokens() public {
        uint256 usdtAmount = 1000 * (10 ** 6);  // 1000 USDT
        uint256 tokenAmount = 100 * (10 ** 18); // 100 HalalDeFiTokens

        // Approve USDT spending by the token sale contract for the buyer
        usdtToken.approve(address(tokenSale), usdtAmount);

        // Buyer buys 100 HalalDeFiTokens with an upper price limit of 0.12 USDT per token
        tokenSale.buyTokens(tokenAmount, 12 * (10 ** 6));

        // Verify that 100 tokens have been sold
        assertEq(tokenSale.tokensSold(), tokenAmount);

        // Verify that the buyer has received 100 HalalDeFiTokens
        assertEq(halalToken.balanceOf(owner), tokenAmount);

        // Verify that the treasury wallet received 1% tax from the USDT (10 USDT)
        assertEq(usdtToken.balanceOf(treasuryWallet), (usdtAmount * 1 / 100));  // 1% tax

        // Verify that the remaining 990 USDT went to the owner
        assertEq(usdtToken.balanceOf(owner), 990 * (10 ** 6));
    }

    // Test to simulate ending the token sale by the contract owner
    function testEndSale() public {
        // Call the endSale function to end the token sale
        tokenSale.endSale();

        // Verify that the saleEnded flag is set to true, indicating the sale has ended
        assertEq(tokenSale.saleEnded(), true);

        // Verify that all remaining tokens are transferred to the owner
        uint256 remainingTokens = halalToken.balanceOf(address(tokenSale));
        assertEq(remainingTokens, 0); // All tokens should be transferred to the owner
        assertEq(halalToken.balanceOf(owner), initialSupply);  // All tokens should be with the owner
    }

    // Test to ensure non-owners cannot end the sale
    function testOnlyOwnerCanEndSale() public {
        // Simulate another user trying to end the sale
        vm.prank(address(0x456)); // Change the caller to a non-owner

        // Expect the call to fail with a revert
        vm.expectRevert("Only owner can call this function");
        tokenSale.endSale();
    }

    // Test for failure if buyer doesn't approve USDT tokens before buying
    function testBuyWithoutApprovalShouldFail() public {
        uint256 tokenAmount = 100 * (10 ** 18); // 100 HalalDeFiTokens

        // No USDT approval given here

        // Expect the call to revert due to lack of USDT approval
        vm.expectRevert();
        tokenSale.buyTokens(tokenAmount, 12 * (10 ** 6));
    }
}


