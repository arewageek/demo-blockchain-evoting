import { expect } from "chai";
import hre from "hardhat";

describe("TEST FOR VOTING CONTRACT", () => {
  beforeEach(async () => {
    let addr1, addr2, addr3, chairman, owner, observer, address;
    [addr1, addr2, addr3, chairman, owner, observer, ...address] =
      await hre.viem.getWalletClients();

    const votingContract = hre.viem.deployContract("Voting");
  });
});
