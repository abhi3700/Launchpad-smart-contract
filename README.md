# Seedify.Fund Launchpad

Seedify.fund Launchpad Smart Contract on Binance Smart Chain

## About

- Payment using 2 tokens:
  - BNB
  - BUSD
- There are 9 tiers and for each tier these state variables are stored:

  - total amount invested (in BUSD/BNB)
  - max. Cap amount (in BUSD/BNB)
  - total no. of users
  - max. allocation per user
  - min. allocation per user
  - list of whitelisted user
  - bought amount per user

- Other than these, the following are the state variables maintained:
  - total BUSD/BNB invested in all tiers
  - total max. cap in BUSD/BNB
  - sale start time
  - sale end time
  - project owner
  - ERC20 token (BUSD/BNB) interface

## Pre-requisite

- Truffle v5.1.8 (core: 5.1.8)
- Solidity - 0.6.12 (solc-js)
- Node v12.13.1
- NPM v6.12.1
- Web3.js v1.2.1
- Metamask

### Steps For Deployment

All steps are performed in directory Update

- truffle develop

  --IN truffle console

  - compile
  - migrate

  OR in another Terminal

  - truffle compile
  - truffle migrate --reset

## To run the test cases on development mode run

- truffle test

## Using network 'development'.

truffle(develop)> test
Using network 'develop'.

# Compiling your contracts...

> Everything is up to date, there is nothing to compile.

Contract: SeedifyFund
✓ is deployed correctly? (52ms)

Contract: SeedifyFund
✓ is token sale is started? (64ms)

Contract: SeedifyFund
✓ Add and check the address in Whitelist tier One (229ms)

Contract: SeedifyFund
✓ Add and check the address in Whitelist tier two (205ms)

Contract: SeedifyFund
✓ Add and check the address in Whitelist tier three (204ms)

Contract: SeedifyFund
✓ Pay One BNB to Check In WhiteListOne, is first tier payment working correctly? (254ms)

Contract: SeedifyFund
✓ Pay Two BNB to Check In WhiteListTwo, is second tier payment working correctly? (300ms)

Contract: SeedifyFund
✓ Pay Four BNB to Check In WhiteListThree, is third tier payment working correctly? (239ms)

8 passing (2s)
