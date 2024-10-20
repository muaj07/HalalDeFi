// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";  // For reentrancy protection

contract HalalDeFiToken is ERC20, ReentrancyGuard {
    // Owner of the contract, set during deployment (immutable for gas efficiency)
    address public immutable owner;

    // Treasury wallet where tax will be collected (immutable for gas efficiency)
    address public immutable treasuryWallet;

    // Tax percentage (e.g., 1% tax on all transfers, except for excluded accounts)
    uint256 public taxPercent;

    // Mapping to track addresses that are excluded from tax (e.g., owner, treasury)
    mapping(address => bool) private _isExcludedFromFee;

    // Event emitted when the owner renounces ownership
    event OwnershipRenounced(address indexed previousOwner);

    // Event emitted when tax percentage is updated
    event TaxPercentageUpdated(uint256 newTaxPercent);

    // Event emitted when an address is excluded/included from the fee
    event ExcludeFromFee(address indexed account, bool isExcluded);

    constructor(uint256 initialSupply, address _treasuryWallet, uint256 _taxPercent) ERC20("Halal DeFi Token", "HDF") {
        require(_treasuryWallet != address(0), "Invalid treasury wallet address");
        require(_taxPercent <= 100, "Tax percentage cannot exceed 100");

        _mint(msg.sender, initialSupply);
        owner = msg.sender;
        treasuryWallet = _treasuryWallet;
        taxPercent = _taxPercent;

        _isExcludedFromFee[owner] = true;
        _isExcludedFromFee[treasuryWallet] = true;
    }

    // Custom transfer function to handle tax deduction
    function transfer(address recipient, uint256 amount) public override nonReentrant returns (bool) {
        uint256 taxAmount = calculateTax(msg.sender, recipient, amount);
        uint256 netAmount = amount - taxAmount;

        require(netAmount <= amount, "Tax amount exceeds transfer amount");

        if (taxAmount > 0) {
            super.transfer(treasuryWallet, taxAmount);
        }
        return super.transfer(recipient, netAmount);
    }

    // Custom transferFrom function to handle tax deduction
    function transferFrom(address sender, address recipient, uint256 amount) public override nonReentrant returns (bool) {
        uint256 taxAmount = calculateTax(sender, recipient, amount);
        uint256 netAmount = amount - taxAmount;

        require(netAmount <= amount, "Tax amount exceeds transfer amount");

        if (taxAmount > 0) {
            super.transferFrom(sender, treasuryWallet, taxAmount);
        }
        return super.transferFrom(sender, recipient, netAmount);
    }

    // Internal function to calculate the tax
    function calculateTax(address sender, address recipient, uint256 amount) internal view returns (uint256) {
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            return 0;
        }
        return (amount * taxPercent) / 100;
    }

    // Allows the owner to set the tax percentage (must be between 0 and 100)
    function setTaxPercent(uint256 _taxPercent) external onlyOwner {
        require(_taxPercent <= 100, "Tax percentage cannot exceed 100");
        taxPercent = _taxPercent;
        emit TaxPercentageUpdated(_taxPercent);
    }

    // Allows the owner to exclude/include accounts from tax
    function setExcludeFromFee(address account, bool isExcluded) external onlyOwner {
        _isExcludedFromFee[account] = isExcluded;
        emit ExcludeFromFee(account, isExcluded);
    }

    // Allows the owner to renounce ownership (irreversible)
    function renounceOwnership() external onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
}

