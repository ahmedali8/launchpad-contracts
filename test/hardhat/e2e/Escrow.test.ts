import { parseUnits } from "@ethersproject/units";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { assert, expect } from "chai";
import { ethers } from "hardhat";

import type { AddressLibrary, Escrow, USDCMock, VaultMock, VaultMockVariableRatio } from "../../../typechain-types";
import { OptStatus } from "../constants";
import { Errors } from "../shared/errors";
import { deployVaultMock, setupEscrowE2ETest } from "../shared/fixtures";
import { parseUsdc } from "../utils";
import { getSigners } from "../utils/getSigners";
import { mintAndApproveUSDC } from "../utils/mintAndApproveUSDC";

export default function testEscrow() {
  // Signers
  let deployer: SignerWithAddress;
  let alice: SignerWithAddress;
  let bob: SignerWithAddress;

  // Contracts
  let escrow: Escrow;
  let usdc: USDCMock;
  let vault: VaultMockVariableRatio;

  // Libraries
  let addressLibrary: AddressLibrary;

  beforeEach(async function () {
    // Setup accounts
    const signers = await getSigners();
    deployer = signers.deployer;
    alice = signers.alice;
    bob = signers.bob;

    // Load the contracts
    const contracts = await loadFixture(setupEscrowE2ETest);
    escrow = contracts.escrow;
    usdc = contracts.usdc;
    vault = contracts.vault;
    addressLibrary = contracts.addressLibrary;
  });

  // // initial ration should be 1e18
  // it("should assert the initial ratio is 1e18", async function () {
  //   expect(await vault.getRatio()).to.equal(parseUnits("1"));
  // });

  it("should handle deposits with a custom USDC to DynUSDC ratio", async function () {
    // Set the conversion rate to 2 DynUSDC per 1 USDC
    await vault.setRatioPerUnderlying(parseUnits("2", 18)); // 2e18

    const depositAmount = parseUsdc("100");
    await mintAndApproveUSDC(usdc, alice, escrow.address, depositAmount);

    // When Alice deposits 100 USDC, the DynUSDC she should receive based on the conversion rate (2:1) is 200 DynUSDC
    await escrow.connect(alice).deposit(depositAmount);

    // Assert balances
    const aliceUserInfo = await escrow.userInfo(alice.address);
    expect(aliceUserInfo.usdcBalance).to.equal(depositAmount);
    expect(aliceUserInfo.dynUSDCBalance).to.equal(0);

    await escrow.connect(alice).optIn();

    const expectedDynUSDC = parseUnits("200"); // 100 USDC * 2 (conversion rate) = 200 DynUSDC
    expect(await vault.balanceOf(escrow.address)).to.equal(expectedDynUSDC);
    expect((await escrow.userInfo(alice.address)).dynUSDCBalance).to.equal(expectedDynUSDC);
  });

  // it("should allow withdrawal under a custom conversion ratio", async function () {
  //   // Set the conversion rate to 0.5 DynUSDC per 1 USDC
  //   await vault.setRatioPerUnderlying(parseUnits("5", 17)); // 0.5e18

  //   const depositAmount = parseUsdc("200");
  //   await mintAndApproveUSDC(usdc, alice, escrow.address, depositAmount);

  //   await escrow.connect(alice).deposit(depositAmount);

  //   await escrow.connect(alice).optIn();

  //   // Alice should receive 100 DynUSDC
  //   const expectedReceivedDynUSDC = parseUnits("100");
  //   expect(await vault.balanceOf(escrow.address)).to.equal(expectedReceivedDynUSDC);

  //   // The conversion ratio changes after alice opted-in //

  //   // Set the conversion rate to 0.4 DynUSDC per 1 USDC
  //   await vault.setRatioPerUnderlying(parseUnits("4", 17)); // 0.4e18

  //   // Now, Alice has 100 DynUSDC. Given the 0.4 conversion rate, she should receive 250 USDC
  //   // Actually,
  //   const expectedDynUSDC = parseUnits("250");

  //   // Where will the additional 50 usdc come from?
  //   // Thats a yield from the vault, so for testing purposes we will mint 50 usdc to the vault
  //   await usdc.mint(vault.address, parseUsdc("50"));

  //   await escrow.connect(alice).withdraw(depositAmount);

  //   // // After withdrawal, DynUSDC balance should be zero, and Alice should receive back her equivalent USDC
  //   // expect(await usdc.balanceOf(alice.address)).to.equal(expectedDynUSDC);

  //   // const aliceUserInfo = await escrow.userInfo(alice.address);
  //   // expect(aliceUserInfo.dynUSDCBalance).to.equal(0);
  //   // expect(aliceUserInfo.usdcBalance).to.equal(0);
  // });
}
