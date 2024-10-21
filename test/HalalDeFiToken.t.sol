// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";                 // Import Foundry's standard test library
import "../src/HalalDeFiToken.sol";          // Import the HalalDeFiToken contract to test

// Test contract for the HalalDeFiToken contract
contract HalalDeFiTokenTest is Test {
    HalalDeFiToken token;                    // Declare an instance of HalalDeFiToken
    address treasuryWallet = address(0x123); // Sample treasury wallet address
    uint256 initialSupply = 1000 * (10 ** 18); // Initial supply of 1000 tokens
    uint256 taxPercent = 1;                  // 1% tax for the test

    // setUp() is called before every test case to initialize the test environment
    function setUp() public {
        // Deploy the HalalDeFiToken contract with:
        // - an initial supply of 1000 tokens
        // - treasury wallet as treasuryWallet
        // - tax percentage set to 1
        token = new HalalDeFiToken(initialSupply, treasuryWallet, taxPercent);
    }

    // Test to check if the initial total supply of the token is correctly set after deployment
    // The function is marked as 'view' since it does not modify the blockchain state
    function testInitialSupply() public view {
        // Assert that the total supply of the deployed token matches the initial supply of 1000 tokens
        // 'assertEq' is a function from the Foundry test library that checks if two values are equal
        assertEq(token.totalSupply(), initialSupply);  // 1000 tokens with 18 decimals
    }

    // Test to check if the treasury wallet is correctly set
    function testTreasuryWallet() public view {
        // Assert that the treasury wallet address set in the contract matches the one provided during deployment
        assertEq(token.treasuryWallet(), treasuryWallet);
    }

    // Test to check if the tax percentage is correctly set
    function testTaxPercentage() public view {
        // Assert that the tax percentage set in the contract matches the one provided during deployment
        assertEq(token.taxPercent(), taxPercent);
    }

    // Test to check that the owner is excluded from paying tax
    function testOwnerExcludedFromFee() public view {
        // Assert that the owner is excluded from tax
        assertEq(token.isExcludedFromFee(address(this)), true);
    }

    // Test the basic transfer functionality
    function testBasicTransfer() public {
        // Transfer 100 tokens to another address and check if the balance is updated accordingly
        address recipient = address(0x456);
        token.transfer(recipient, 100 * (10 ** 18));

        // The recipient should receive 100 tokens, minus the tax if applicable
        assertEq(token.balanceOf(recipient), 100 * (10 ** 18));
    }
}

