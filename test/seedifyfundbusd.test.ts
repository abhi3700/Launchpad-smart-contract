import { ethers } from "hardhat";
import chai from "chai";
import {
  BigNumber,
  Contract /* , Signer */ /* , Wallet */,
  ContractFactory,
} from "ethers";
import { /* deployContract, */ solidity } from "ethereum-waffle";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import {
  // MAX_UINT256,
  // TIME,
  ZERO_ADDRESS,
  // asyncForEach,
  // deployContractWithLibraries,
  // getCurrentBlockTimestamp,
  // getUserTokenBalance,
  // getUserTokenBalances,
  // setNextTimestamp,
  // setTimestamp,
} from "./testUtils";

import {
  days,
  weeks,
  months,
  parseWithDecimals,
  formatWithDecimals,
} from "./helper";

chai.use(solidity);
const { expect } = chai;

export function SeedifyFundBUSD(): void {
  describe("IGO Launchpad Unit Test", () => {
    let stablecoinAddress: string;
    // let signers: Array<Signer>;
    let owner: SignerWithAddress,
      owner2: SignerWithAddress,
      alice: SignerWithAddress,
      bob: SignerWithAddress,
      charlie: SignerWithAddress,
      den: SignerWithAddress;
    let stablecoinContract: Contract, seedifyFundBUSDContract: Contract;

    beforeEach(async () => {
      // get signers
      [owner, owner2, alice, bob, charlie, den] = await ethers.getSigners();

      // ---------------------------------------------------
      // deploy stablecoin contract
      const StablecoinContractFactory: ContractFactory =
        await ethers.getContractFactory("Token");
      stablecoinContract = await StablecoinContractFactory.deploy(
        "Binance USD",
        "BUSD"
      );
      await stablecoinContract.deployed();
      // stablecoinAddress = stablecoinContract.address;
      // console.log(`ERC20 Token contract address: ${stablecoinContract.address}`);

      // expect(stablecoinAddress).to.not.eq(0);

      // console.log(`ERC20 Token SC owner: ${await stablecoinContract.owner()}`);

      // Mint some tokens (1000 BUSD) to each of addresses
      // await stablecoinContract.mint(
      //   alice.address,
      //   BigNumber.from(String(1000e18))
      // );
      // await stablecoinContract.mint(
      //   bob.address,
      //   BigNumber.from(String(1000e18))
      // );
      // await stablecoinContract.mint(
      //   charlie.address,
      //   BigNumber.from(String(1000e18))
      // );

      const addresses = [alice, bob, charlie];
      for (let i = 0; i < addresses.length; i++) {
        await stablecoinContract.mint(
          addresses[i],
          BigNumber.from(String(1000e18))
        );
      }

      // verify balance of each address
      for (let i = 0; i < addresses.length; i++) {
        expect(await stablecoinContract.balanceOf(addresses[i].address)).to.eq(
          BigNumber.from(String(1e19))
        );
      }

      // Shortened to this 🔝
      // await expect(await stablecoinContract.balanceOf(addr1.address)).to.eq(
      //   BigNumber.from(String(1e19))
      // );
      // expect(await stablecoinContract.balanceOf(addr2.address)).to.eq(
      //   BigNumber.from(String(1e19))
      // );
      // expect(await stablecoinContract.balanceOf(addr3.address)).to.eq(
      //   BigNumber.from(String(1e19))
      // );

      //#########################################################################/
      // deploy stablecoin contract
      const SeedifyFundBUSDContractFactory: ContractFactory =
        await ethers.getContractFactory("SeedifyFundBUSD");
      seedifyFundBUSDContract = await SeedifyFundBUSDContractFactory
        .deploy
        // TODO: set params
        ();
      await seedifyFundBUSDContract.deployed();
    });

    describe("Ownable", async () => {
      it("Should have the correct owner", async () => {
        expect(await seedifyFundBUSDContract.owner()).to.equal(owner.address);
      });

      it("Owner is able to transfer ownership", async () => {
        await expect(seedifyFundBUSDContract.transferOwnership(owner2.address))
          .to.emit(seedifyFundBUSDContract, "OwnershipTransferred")
          .withArgs(owner.address, owner2.address);
      });
    });

    describe("Pausable", async () => {
      it("Owner is able to pause when NOT paused", async () => {
        await expect(seedifyFundBUSDContract.pause())
          .to.emit(seedifyFundBUSDContract, "Paused")
          .withArgs(owner.address);
      });

      it("Owner is able to unpause when already paused", async () => {
        seedifyFundBUSDContract.pause();

        await expect(seedifyFundBUSDContract.unpause())
          .to.emit(seedifyFundBUSDContract, "Unpaused")
          .withArgs(owner.address);
      });

      it("Owner is NOT able to pause when already paused", async () => {
        seedifyFundBUSDContract.pause();

        await expect(seedifyFundBUSDContract.pause()).to.be.revertedWith(
          "Pausable: paused"
        );
      });

      it("Owner is NOT able to unpause when already unpaused", async () => {
        seedifyFundBUSDContract.pause();

        seedifyFundBUSDContract.unpause();

        await expect(seedifyFundBUSDContract.unpause()).to.be.revertedWith(
          "Pausable: not paused"
        );
      });
    });

    // TODO: write all tests for contract
    describe("Whitelist users for multiple tiers", async () => {});
    // TODO: write all tests for contract
    describe("View whitelisted users for multiple tiers", async () => {});
    // TODO: write all tests for contract
    describe("Set listing timestamp", async () => {});
    // TODO: write all tests for contract
    describe("Buy Project Token with BUSD", async () => {});
    // TODO: write all tests for contract
    describe("Claim Refund of BUSD", async () => {});
  });
}
