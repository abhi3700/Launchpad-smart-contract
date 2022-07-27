import { ethers } from "hardhat";
import { Contract, ContractFactory /* , BigNumber */ } from "ethers";
import { config as dotenvConfig } from "dotenv";
import { resolve } from "path";
// dotenvConfig({ path: resolve(__dirname, "./.env") });

async function main(): Promise<void> {
  // ==============================================================================
  // We get the SeedifyFund BUSD contract to deploy
  const seedifyFundBUSDFactory: ContractFactory =
    await ethers.getContractFactory("SeedifyFundBUSD");
  const seedifyFundBUSDContract: Contract =
    await seedifyFundBUSDFactory.deploy();
  // TODO: parse arguments
  await seedifyFundBUSDContract.deployed();
  console.log(
    "Seedify Fund SC for BUSD Token deployed to: ",
    seedifyFundBUSDContract.address
  );
  console.log(
    `The transaction that was sent to the network to deploy the Seedify Fund SC BUSD: ${seedifyFundBUSDContract.deployTransaction.hash}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then()
  .catch((error: Error) => {
    console.error(error);
    throw new Error("Exit: 1");
  });
