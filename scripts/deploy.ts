import { ethers } from "hardhat";

async function main() {

  const Hulki = await ethers.getContractFactory("Hulki");
  const hulki = await Hulki.deploy();

  await hulki.deployed();

  console.log("deployed")
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
