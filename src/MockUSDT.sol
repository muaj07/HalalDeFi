// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDT is ERC20 {
    constructor() ERC20("Mock USDT", "USDT") {
        // Initial supply can be set if needed, but in tests, you'll mint as required
    }

    // Add a mint function to allocate tokens for testing
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
