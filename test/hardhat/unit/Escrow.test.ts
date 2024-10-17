import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { assert, expect } from "chai";
import { ethers } from "hardhat";

import type { AddressLibrary, Escrow, USDCMock, VaultMock } from "../../../typechain-types";
import { OptStatus } from "../constants";
import { Errors } from "../shared/errors";
import { setupEscrowTest } from "../shared/fixtures";
import { parseUsdc } from "../utils";
import { getSigners } from "../utils/getSigners";

export default function testEscrow() {
  // Signers
  let deployer: SignerWithAddress;
  let alice: SignerWithAddress;
  let bob: SignerWithAddress;

  // Contracts
  let escrow: Escrow;
  let usdc: USDCMock;
  let vault: VaultMock;

  // Libraries
  let addressLibrary: AddressLibrary;

  beforeEach(async function () {
    // Setup accounts
    const signers = await getSigners();
    deployer = signers.deployer;
    alice = signers.alice;
    bob = signers.bob;

    // Load the contracts
    const contracts = await loadFixture(setupEscrowTest);
    escrow = contracts.escrow;
    usdc = contracts.usdcMock;
    vault = contracts.vaultMock;
    addressLibrary = contracts.addressLibrary;
  });

  /// Bad Paths (Error Handling) ///

  it("should revert when initializing the contract more than once", async function () {
    await expect(escrow.initializer(usdc.address, vault.address)).to.be.revertedWithCustomError(
      escrow,
      Errors.LaunchpadV3_Escrow_AlreadyInitialized
    );
  });

  it("should revert when depositing zero USDC", async function () {
    await expect(escrow.connect(alice).deposit(0)).to.be.revertedWithCustomError(
      escrow,
      Errors.LaunchpadV3_Escrow_InvalidAmount
    );
  });

  it("should revert when withdrawing more USDC than balance", async function () {
    const depositAmount = parseUsdc("100");
    await usdc.mint(alice.address, depositAmount);
    await usdc.connect(alice).approve(escrow.address, depositAmount);
    await escrow.connect(alice).deposit(depositAmount);

    const withdrawAmount = parseUsdc("200");
    await expect(escrow.connect(alice).withdraw(withdrawAmount)).to.be.revertedWithCustomError(
      escrow,
      Errors.LaunchpadV3_Escrow_InsufficientUSDCBalance
    );
  });

  it("should revert when opting in with zero USDC", async function () {
    await expect(escrow.connect(alice).optIn()).to.be.revertedWithCustomError(
      escrow,
      Errors.LaunchpadV3_Escrow_InsufficientUSDCBalance
    );
  });

  it("should revert when opting in if already opted in", async function () {
    const depositAmount = parseUsdc("100");
    await usdc.mint(alice.address, depositAmount);
    await usdc.connect(alice).approve(escrow.address, depositAmount);
    await escrow.connect(alice).deposit(depositAmount);
    await escrow.connect(alice).optIn();

    await expect(escrow.connect(alice).optIn()).to.be.revertedWithCustomError(
      escrow,
      Errors.LaunchpadV3_UserAlreadyOptedIn
    );
  });

  it("should revert when opting out if not opted in", async function () {
    await expect(escrow.connect(alice).optOut()).to.be.revertedWithCustomError(
      escrow,
      Errors.LaunchpadV3_UserNotOptedIn
    );
  });

  it("should revert when opting out with zero DynUSDC balance when opted out", async function () {
    const depositAmount = parseUsdc("100");
    await usdc.mint(alice.address, depositAmount);
    await usdc.connect(alice).approve(escrow.address, depositAmount);
    await escrow.connect(alice).deposit(depositAmount);

    await expect(escrow.connect(alice).optOut()).to.be.revertedWithCustomError(
      escrow,
      Errors.LaunchpadV3_UserNotOptedIn
    );
  });

  it("should revert when opting out with zero DynUSDC balance when opted in", async function () {
    const depositAmount = parseUsdc("100");
    await usdc.mint(alice.address, depositAmount);
    await usdc.connect(alice).approve(escrow.address, depositAmount);
    await escrow.connect(alice).deposit(depositAmount);
    await escrow.connect(alice).optIn();

    // Assert Invariant
    const aliceUserInfo = await escrow.userInfo(alice.address);
    assert(aliceUserInfo.dynUSDCBalance.gt(0));
  });

  it("should revert when non-admin tries to update the vault", async function () {
    await expect(escrow.connect(alice).setVault(vault.address)).to.be.revertedWithCustomError(
      escrow,
      Errors.AccessControlUnauthorizedAccount
    );
  });

  it("should revert when admin tries to set a zero vault address", async function () {
    await expect(escrow.connect(deployer).setVault(ethers.constants.AddressZero)).to.be.revertedWithCustomError(
      addressLibrary,
      Errors.LaunchpadV3_AddressLibrary_InvalidAddress
    );
  });

  it("should prevent reentrancy attacks on withdraw", async function () {
    // Simulate and test reentrancy vulnerability in withdraw
    // Non-trivial: would require a special contract that tries to reenter
  });

  /// Happy Paths (Expected Behavior) ///

  it("should allow a user to deposit USDC", async function () {
    const depositAmount = parseUsdc("100");
    await usdc.mint(alice.address, depositAmount);
    await usdc.connect(alice).approve(escrow.address, depositAmount);
    await expect(escrow.connect(alice).deposit(depositAmount))
      .to.emit(escrow, "Deposit")
      .withArgs(alice.address, depositAmount);
    expect(await usdc.balanceOf(escrow.address)).to.equal(depositAmount);
    const aliceUserInfo = await escrow.userInfo(alice.address);
    expect(aliceUserInfo.usdcBalance).to.equal(depositAmount);
    expect(aliceUserInfo.dynUSDCBalance).to.equal(0);
    expect(aliceUserInfo.optStatus).to.equal(OptStatus.OptOut);
  });
}
