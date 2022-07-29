import { HardhatEthersHelpers } from "@nomiclabs/hardhat-ethers/types";
import { ethers as hEthers } from "hardhat";
import { BigNumber } from "ethers";

export function getTimestamp(date: Date) {
  return Math.floor(date.getTime() / 1000);
}

export async function travelTime(ethers: HardhatEthersHelpers, time: number) {
  await ethers.provider.send("evm_increaseTime", [time]);
  await ethers.provider.send("evm_mine", []);
}

export async function resetBlockTimestamp(ethers: HardhatEthersHelpers) {
  const blockNumber = ethers.provider.getBlockNumber();
  const block = await ethers.provider.getBlock(blockNumber);
  const currentTimestamp = Math.floor(new Date().getTime() / 1000);
  const secondsDiff = currentTimestamp - block.timestamp;
  await ethers.provider.send("evm_increaseTime", [secondsDiff]);
  await ethers.provider.send("evm_mine", []);
}

export function parseWithDecimals(amount: number) {
  return hEthers.utils.parseUnits(Math.floor(amount).toString(), 18);
}

export function formatWithDecimals(amount: BigNumber) {
  return hEthers.utils.formatUnits(amount, 18);
}

export function days(numDays: number) {
  return 60 * 60 * 24 * numDays;
}

export function weeks(numWeeks: number) {
  return days(7 * numWeeks);
}

export function months(numMonths: number) {
  return days(30 * numMonths);
}

export const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
