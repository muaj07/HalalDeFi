// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";                 // Import Foundry's standard test library
import "../src/HalalDeFiToken.sol";          // Import the HalalDeFiToken contract to test

// Test contract for the HalalDeFiToken contract
contract HalalDeFiTokenTest is Test {
    HalalDeFiToken token;                    // Declare an instance of HalalDeFiToken

    // setUp() is called before every test case to initialize the test environment
    function setUp() public {
        // Deploy the HalalDeFiToken contract with an initial supply of 1000 tokens (18 decimals)
        // and set the owner of the contract as the current contract (address(this))
        token = new HalalDeFiToken(1000 * (10 ** 18), address(this));
    }

    // Test to check if the initial total supply of the token is correctly set after deployment
    // The function is marked as 'view' since it does not modify the blockchain state
    function testInitialSupply() public view {
        // Assert that the total supply of the deployed token matches the initial supply of 1000 tokens
        // 'assertEq' is a function from the Foundry test library that checks if two values are equal
        assertEq(token.totalSupply(), 1000 * (10 ** 18));  // 1000 tokens with 18 decimals
    }
}


