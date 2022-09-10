import { expect } from "chai";
import { ethers } from "hardhat";

describe("Hulki", () => {
  const deploy = async () => {
    const [owner, user] = await ethers.getSigners();
    const Hulki = await ethers.getContractFactory("Hulki");
    const hulki = await Hulki.deploy();

    await hulki
      .connect(owner)
      .setHulkiInfo(
        "start",
        ".json",
        1
      );

    return { hulki, owner, user };
  };

  describe("happy path", () => {
    it("minting tokens without multipack, round 0", async () => {
      const { hulki, owner, user } = await deploy();
      await hulki.connect(owner).setRound(0);

      hulki
        .connect(user)
        .mint(1, 2, 0, 0, user.address, {
          value: ethers.utils.parseEther("2"),
        });

      let ownerof = await hulki.ownerOf(1);
      expect(ownerof).to.equal(user.address);
    });

    it("minting tokens in last round", async () => {
      const { hulki, owner, user } = await deploy();
      await hulki.connect(owner).setRound(4);

      hulki
        .connect(user)
        .mint(1, 4, 0, 0, user.address, {
          value: ethers.utils.parseEther("4"),
        });

      let ownerof = await hulki.ownerOf(2);
      expect(ownerof).to.equal(user.address);

      let mintedInLastRound = await hulki.getTokenIdsMintedInLastRound();
      console.log(mintedInLastRound);
    });

    it("minting tokens with multipack", async () => {
      const { hulki, owner, user } = await deploy();
      await hulki.connect(owner).setRound(0);

      await hulki
        .connect(user)
        .mint(1, 7, 0, 0, user.address, {
          value: ethers.utils.parseEther("7"),
        });

      let ownerof = await hulki.ownerOf(1801);
      expect(ownerof).to.equal(user.address);
    });

    it("evolution", async () => {
      const { hulki, owner, user } = await deploy();
      await hulki.connect(owner).setRound(0);
      await hulki
        .connect(user)
        .mint(1, 2, 0, 0, user.address, {
          value: ethers.utils.parseEther("2"),
        });

      await hulki.connect(owner).mint(0, 0, 0, 1, user.address);

      let ownerof = await hulki.ownerOf(1801);
      expect(ownerof).to.equal(user.address);
    });

    it("check token URI", async () => {
      const { hulki, owner, user } = await deploy();

      let uri = await hulki.tokenURI(1);
      expect(uri).to.equal("start1.json");
    });
  });
});
