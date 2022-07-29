import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { utils } from "ethers";

describe("Lock", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshopt in every test.
  async function deployBoxFactoryFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const box = await ethers.getContractFactory("Box");
    const boxInstance = await box.deploy();

    const BoxFactory = await ethers.getContractFactory("BeaconFactory");

    const boxFactory = await BoxFactory.deploy(boxInstance.address);

    const boxv2 = await ethers.getContractFactory("BoxV2");

    return { boxInstance, boxFactory, box, boxv2, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Can deploy new box", async function () {
      const { boxFactory, box, boxv2, boxInstance } = await loadFixture(
        deployBoxFactoryFixture
      );

      const value = 123456789;

      // var args = {
      //   value: 1234,
      // };
      // var callData = box.interface.encodeFunctionData("initialise", [value]);

      //const tx = await boxFactory.createProxy(callData);

      const tx = await boxFactory.createProxyAbi(value);
      const res = await tx.wait();

      const event = res.events?.filter((x) => {
        return x.event == "ProxyDeployed";
      });

      if (event && event[0].args) {
        const address = event[0].args[0];

        const instance = box.attach(address);

        await expect(await instance.retrieve()).to.equal(value);

        const boxV2Instance = await boxv2.deploy();
        await expect(await boxV2Instance.getVersion()).to.equal(2);

        await boxFactory.upgradeTo(boxV2Instance.address);
        const instancev2 = boxv2.attach(address);

        await expect(await instancev2.retrieve()).to.equal(value);
        await expect(await instancev2.getVersion()).to.equal(2);
      }
    });
  });
});
