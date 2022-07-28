# Seedify.Fund Launchpad

Seedify.fund IGO Launchpad Smart Contract on Binance Smart Chain (BSC)

## About

- A `non-upgradable`, `ownable`, `pausable` **Seedify IGO Launchpad** smart contract which can be used for letting projects manage their IGO on top of it.
- Payment using tokens:
  - `BUSD`
- The Project token transfer functionality is not considered within the IGO smart contract.
- There are 9 tiers and for each tier these state variables are stored:
  - total amount invested (in BUSD/BNB)
  - max. Cap amount (in BUSD/BNB)
  - total no. of users
  - max. allocation per user
  - min. allocation per user
  - list of whitelisted user
  - bought amount (in BUSD) per user
  - refund amount (in BUSD) per user
- Other than these, the following are the state variables maintained:
  - total BUSD/BNB invested in all tiers
  - total max. cap in BUSD/BNB
  - sale start time
  - sale end time
  - project owner address
  <!-- - project token (ERC20) interface -->
  - BUSD token (ERC20) interface
  - refund amount per user in all tiers

## Usage

### Installation

Install node packages

```console
$ yarn install
```

### Build

Build the smart contracts

```console
$ yarn compile
```

### Contract size

```console
$ yarn contract-size
```

### Test

Run unit tests

```console
$ yarn test
```

### TypeChain

Compile the smart contracts and generate TypeChain artifacts:

```console
$ yarn typechain
```

### Lint Solidity

Lint the Solidity code:

```console
$ yarn lint:sol
```

### Lint TypeScript

Lint the TypeScript code:

```console
$ yarn lint:ts
```

### Coverage

Generate the code coverage report:

```console
$ yarn coverage
```

### Report Gas

See the gas usage per unit test and average gas per method call:

```console
$ REPORT_GAS=true yarn test
```

### Clean

Delete the smart contract artifacts, the coverage reports and the Hardhat cache:

```console
$ yarn clean
```

### Deploy

Environment variables: Create a `.env` file with its values in [.env.example](./.env.example)

**Sequence**:

1. A Project Owner (PO) deploys the IGO Smart Contract for participation of investors into it.
2. The PO whitelists the addresses of investors into different tiers for different allocations (limit) of BUSD as a payment token.
3. The whitelisted investors are allowed to invest BUSD into the deployed IGO SC.
4. The PO launches the Project Token (PT) into CEX/DEX.
5. The PO then sets the listing timestamp into the SC.
6. The investors have 24 hr window for claiming refund of transferred BUSD.
   - if want to claim, then the PI can use `claimRefund` function to get the invested BUSD back. And the corresponding calculated PT shall remain with the PO.
   - if didn't claim within the given time limit of 24 hr, then after the time limit is over, the PO can transfer the calculated PT into the investors' wallet address.

#### localhost

```console
// on terminal-1
$ npx hardhat node

// on terminal-2
$ yarn hardhat run deployment/deploy.ts --network localhost
```

#### ETH Testnet - Rinkeby

- Deploy the contracts

<!-- ```console
$ yarn hardhat deploy:IGOLaunchpad --network rinkeby
``` -->

```console
$ yarn hardhat run deployment/deploy.ts --network rinkeby
```

#### BSC Testnet

- Deploy the contracts

<!-- ```console
$ yarn hardhat deploy:IGOLaunchpad --network bsctestnet
``` -->

```console
$ yarn hardhat run deployment/deploy.ts --network bsctestnet
```

#### ETH Mainnet

- Deploy the contracts

<!-- ```console
$ yarn hardhat deploy:IGOLaunchpad --network ethmainnet
```
 -->

```console
$ yarn hardhat run deployment/deploy.ts --network ethmainnet
```
