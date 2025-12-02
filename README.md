# Universal NFT Trait Swap Contracts

## Overview

This repository contains the Solidity smart contracts for the Universal NFT Trait Swap Protocol. The protocol is designed to facilitate trustless, atomic swapping of individual NFT traits between two parties using a Wrapper NFT mechanism, ensuring the integrity of the original assets.

## Contracts Deployed

| Contract | Role | Dependency |
| :--- | :--- | :--- |
| `MockGameNFT.sol` | Test Asset | ERC-721 |
| `TraitSwapWrapper.sol` | Wrapper NFT (Modified Metadata) | `TraitSwapEscrow.sol` (Minter) |
| `TraitSwapEscrow.sol` | Core Logic (Atomic Swap) | `TraitSwapWrapper.sol` |

## Prerequisites

* Solidity ^0.8.0
* OpenZeppelin Contracts
* Foundry or Hardhat

## Deployment Instructions

1.  Compile contracts.
2.  Deploy `MockGameNFT.sol`. Mint several tokens for testing.
3.  Deploy `TraitSwapWrapper.sol` (with initial configuration).
4.  Deploy `TraitSwapEscrow.sol` (passing the address of `TraitSwapWrapper.sol`).
5.  Set the `TraitSwapEscrow.sol` address as the **minter** for `TraitSwapWrapper.sol` (crucial step).

## Core Functions in TraitSwapEscrow.sol

* `depositAndOffer`: Locks the original NFT and mints a new Wrapper NFT with the user's offer details.
* `executeSwap`: Performs the atomic trait value swap between two existing Wrapper NFTs.
* `cancelOffer`: Allows the offerer to retrieve their original NFT if the offer is not accepted.
