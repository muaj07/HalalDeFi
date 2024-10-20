
# `HalalDeFiToken` and `HalalDeFiTokenSale` Contracts

## Overview

This repository contains two solidity smart contracts: `HalalDeFiToken` and `HalalDeFiTokenSale`. These contracts implement a token sale mechanism for an ERC20 token (`HalalDeFiToken`), where users can purchase tokens using a stablecoin such as `USDT`. the sale contract (`HalalDeFiTokenSale`) handles pricing, sales management, and token distribution. The contracts have been designed to include tax mechanisms on token transfers, ownership control, and a sale logic that adjusts token price incrementally as more tokens are sold.

## Contracts Overview

1. **HalalDeFiToken.sol**  
   `HalalDeFiToken` is an ERC20-compliant token with additional features, such as:
   - a tax system that deducts a small percentage from transfers.
   - an exclusion mechanism that allows certain addresses (like the owner and treasury) to be exempted from tax.
   - ownership control, allowing the owner to renounce ownership or modify the tax rate.

2. **HalalDeFiTokenSale.sol**  
   `HalalDeFiTokenSale` is a token sale contract that allows users to purchase `HalalDeFiToken` tokens using `USDT`. The sale contract manages the price of the tokens and adjusts the price as more tokens are sold. it also handles the distribution of funds (`USDT`) and tax collection.


## HalalDeFiToken.sol: contract details

### Constructor

```solidity
constructor(uint256 initialSupply, address _treasuryWallet, uint256 _taxPercent)
```
- `initialSupply`: the total initial supply of the tokens.
- `_treasuryWallet`: the wallet where collected taxes will be transferred.
- `_taxPercent`: the initial tax percentage that will be deducted on token transfers (e.g., `1%` represented as 1).
  
The constructor mints the initial supply of tokens to the deployer and sets the owner and treasury wallet. the tax percentage is also initialized during deployment.

### Functions

#### BuyTokens
```solidity
function buyTokens(uint256 _numberOfTokens, uint256 maxAcceptablePrice) public saleActive nonReentrant
```
- `_numberOfTokens`: the number of tokens the user wants to purchase.
- `maxAcceptablePrice`: the maximum price the buyer is willing to pay per token.
  
This function allows users to purchase tokens using `USDT`. the function checks whether the current token price is within the buyer's acceptable price limit, calculates the total cost, and deducts a `1% tax`. the `USDT` is then transferred to the treasury and owner.

#### Steps:

- Ensure the number of tokens sold + requested tokens doesn’t exceed maxTokensForSale.
- Check if the current token price is within the buyer's `maxAcceptablePrice`.
- Calculate the total cost and tax (1%).
- Transfer `USDT` to the treasury wallet for tax, and the rest to the owner.
- Transfer the purchased tokens to the buyer.
- Update the number of tokens sold.
- Increment the price if the threshold is met.

#### End Sale
```solidity
function endSale() public onlyOwner nonReentrant
```
This function allows the owner to end the token sale. it transfers any remaining tokens in the sale contract back to the owner and marks the sale as ended.

#### Steps:

- Ensure the sale hasn't already ended.
- Transfer remaining tokens from the sale contract to the owner.
- Mark the sale as ended by setting saleEnded to true.

### Modifiers

- `onlyOwner`: Restricts access to functions to only the owner (such as endSale).
- `saleActive`: Ensures the sale is still active.
- `nonReentrant`: Prevents reentrancy attacks, ensuring functions cannot be called multiple times in the same transaction.

## Contract Interaction Flow

### Deployment:

1. first, the `HalalDeFiToken` contract is deployed with an initial supply and a treasury wallet.
2. then, the `HalalDeFiTokenSale` contract is deployed with the `HalalDeFiToken` contract address, the `USDT` contract address, and a treasury wallet.

### Token Sale:

- users call `buyTokens` to purchase `HalalDeFiToken` using `USDT`.
- the price per token is adjusted based on the number of tokens sold.
- taxes are deducted and transferred to the treasury wallet during each purchase.

### Ending the Sale:

- the owner can call `endSale` to close the sale and retrieve unsold tokens.


## Events

### HalalDeFiToken

- `OwnershipRenounced(address previousOwner)`: emitted when the contract ownership is renounced.
- `TaxPercentageUpdated(uint256 newTaxPercent)`: emitted when the tax percentage is updated.
- `ExcludeFromFee(address account, bool isExcluded)`: emitted when an account is excluded or included in tax fees.

### HalalDeFiTokenSale

- `Sell(address indexed _buyer, uint256 _amount)`: emitted when tokens are sold.
- `SaleEnded(address indexed owner, uint256 remainingTokens)`: emitted when the sale is ended.
- `Refund(address indexed _buyer, uint256 refundAmount)`: emitted when a refund is processed.
  

## Testing and Deployment

### Testnet Deployment

To deploy and test the contracts on the Ethereum Testnet (such as `goerli`), follow the steps outlined in the testnet deployment guide. this includes setting up `Metamask`, obtaining testnet `ETH` and `USDT`, deploying via Remix, and interacting with the contracts.

### Unit Tests

You should create unit tests for the following scenarios:

- token transfer with/without tax.
- token purchase with varying prices and tax deductions.
- handling price increments as more tokens are sold.
- ending the sale and verifying token transfers.


## License

These contracts are licensed under the MIT license.

