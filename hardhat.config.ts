import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-etherscan"
import fs from "fs";

const privJson = JSON.parse(fs.readFileSync("./secrets.json", "utf-8"));

const config: HardhatUserConfig = {
  solidity: "0.8.11",
  networks: {
    rinkeby: {
      url: privJson.infura,
      accounts: [privJson.secret],
    }
  },

  etherscan: {
    apiKey: "JJA35UV497AGQCJVZ4GRR1VTDTXAVJQQQZ"
  }
};

export default config;
