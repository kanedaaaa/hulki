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
        "bannerURI",
        "beastURI",
        "warURI",
        "battleURI",
        "valhallaURI",
        200,
        200,
        200,
        200,
        200,
        1
      );

    return { hulki, owner, user };
  };

  describe("happy path", () => {
    it("minting tokens without multipack, round 0", async () => {
        const {hulki, owner, user} = await deploy();
        await hulki.connect(owner).setRound(0);
         
        hulki.connect(user).mint(
            1,
            2,
            0,
            0
        );

        let ownerof = await hulki.ownerOf(1);
        expect(ownerof).to.equal(user.address);
    });

    it("minting tokens in last round", async () => {
        const {hulki, owner, user} = await deploy();
        await hulki.connect(owner).setRound(4);
         
        hulki.connect(user).mint(
            1,
            2,
            0,
            0
        );

        let ownerof = await hulki.ownerOf(1);
        expect(ownerof).to.equal(user.address);

        let mintedInLastRound = await hulki.getTokenIds(4) 
        //console.log(mintedInLastRound); // gotta expect this
    });

    it("minting tokens with multipack", async () => {
        const {hulki, owner, user} = await deploy();
        await hulki.connect(owner).setRound(0);

        await hulki.connect(user).mint(
            1, 
            9,
            0,
            0
        );

        let beast = await hulki.getTokenIds(3);

        console.log(beast)
    })
  });
});
