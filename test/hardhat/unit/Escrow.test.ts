import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { assert, expect } from "chai";
import { ethers } from "hardhat";

import type { AddressLibrary, Escrow, USDCMock, VaultMock } from "../../../typechain-types";
import { OptStatus } from "../constants";
import { Errors } from "../shared/errors";
import { deployVaultMock, setupEscrowTest } from "../shared/fixtures";
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
    await mintAndApproveUSDC(usdc, alice, escrow.address, depositAmount);
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
    await mintAndApproveUSDC(usdc, alice, escrow.address, depositAmount);
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
    await mintAndApproveUSDC(usdc, alice, escrow.address, depositAmount);
    await escrow.connect(alice).deposit(depositAmount);

    await expect(escrow.connect(alice).optOut()).to.be.revertedWithCustomError(
      escrow,
      Errors.LaunchpadV3_UserNotOptedIn
    );
  });

  it("should revert when opting out with zero DynUSDC balance when opted in", async function () {
    const depositAmount = parseUsdc("100");
    await mintAndApproveUSDC(usdc, alice, escrow.address, depositAmount);
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

  /// Happy Paths (Expected Behavior) ///

  it("should allow a user to deposit USDC", async function () {
    const depositAmount = parseUsdc("100");
    await mintAndApproveUSDC(usdc, alice, escrow.address, depositAmount);
    await expect(escrow.connect(alice).deposit(depositAmount))
      .to.emit(escrow, "Deposit")
      .withArgs(alice.address, depositAmount);

    expect(await usdc.balanceOf(escrow.address)).to.equal(depositAmount);
    const aliceUserInfo = await escrow.userInfo(alice.address);
    expect(aliceUserInfo.usdcBalance).to.equal(depositAmount);
    expect(aliceUserInfo.dynUSDCBalance).to.equal(0);
    expect(aliceUserInfo.optStatus).to.equal(OptStatus.OptOut);
  });

  it("should allow a user to withdraw USDC when opted out by default", async function () {
    const depositAmount = parseUsdc("100");
    await mintAndApproveUSDC(usdc, alice, escrow.address, depositAmount);
    await escrow.connect(alice).deposit(depositAmount);

    await expect(escrow.connect(alice).withdraw(depositAmount))
      .to.emit(escrow, "Withdraw")
      .withArgs(alice.address, depositAmount);

    const aliceUserInfo = await escrow.userInfo(alice.address);
    expect(aliceUserInfo.usdcBalance).to.equal(0);
    expect(aliceUserInfo.dynUSDCBalance).to.equal(0);
    expect(aliceUserInfo.optStatus).to.equal(OptStatus.OptOut);
  });

  it("should allow a user to withdraw USDC when opted in", async function () {
    const depositAmount = parseUsdc("100");
    await mintAndApproveUSDC(usdc, alice, escrow.address, depositAmount);
    await escrow.connect(alice).deposit(depositAmount);

    const aliceUserInfoAfterDeposit = await escrow.userInfo(alice.address);
    expect(aliceUserInfoAfterDeposit.usdcBalance).to.equal(depositAmount);
    expect(aliceUserInfoAfterDeposit.dynUSDCBalance).to.equal(0);
    expect(aliceUserInfoAfterDeposit.optStatus).to.equal(OptStatus.OptOut);

    await escrow.connect(alice).optIn(); // The current ration is 1:1

    const aliceUserInfoAfterOptIn = await escrow.userInfo(alice.address);
    expect(aliceUserInfoAfterOptIn.usdcBalance).to.equal(0);
    expect(aliceUserInfoAfterOptIn.dynUSDCBalance).to.equal(depositAmount);
    expect(aliceUserInfoAfterOptIn.optStatus).to.equal(OptStatus.OptIn);

    await expect(escrow.connect(alice).withdraw(depositAmount))
      .to.emit(escrow, "Withdraw")
      .withArgs(alice.address, depositAmount);

    const aliceUserInfoAfterWithdraw = await escrow.userInfo(alice.address);
    expect(aliceUserInfoAfterWithdraw.usdcBalance).to.equal(0);
    expect(aliceUserInfoAfterWithdraw.dynUSDCBalance).to.equal(0);
    expect(aliceUserInfoAfterWithdraw.optStatus).to.equal(OptStatus.OptOut);
  });

  it("should allow a user to opt in to Dynavault", async function () {
    const depositAmount = parseUsdc("100");
    await mintAndApproveUSDC(usdc, alice, escrow.address, depositAmount);
    await escrow.connect(alice).deposit(depositAmount);

    const expectedUSDCBalance = 0;
    const expectedDynUSDCBalance = depositAmount;
    await expect(escrow.connect(alice).optIn())
      .to.emit(escrow, "OptIn")
      .withArgs(alice.address, expectedUSDCBalance, expectedDynUSDCBalance);
  });

  it("should allow a user to opt out of Dynavault", async function () {
    const depositAmount = parseUsdc("100");
    await mintAndApproveUSDC(usdc, alice, escrow.address, depositAmount);
    await escrow.connect(alice).deposit(depositAmount);
    await escrow.connect(alice).optIn();

    const expectedUSDCBalance = depositAmount;
    const expectedDynUSDCBalance = 0;
    await expect(escrow.connect(alice).optOut())
      .to.emit(escrow, "OptOut")
      .withArgs(alice.address, expectedDynUSDCBalance, expectedUSDCBalance);
  });

  it("should allow the admin to update the vault", async function () {
    const { vaultMock: newVault } = await deployVaultMock(usdc.address);

    await expect(escrow.connect(deployer).setVault(newVault.address))
      .to.emit(escrow, "VaultUpdated")
      .withArgs(vault.address, newVault.address);
  });

  it("should handle multiple deposits and withdrawals for multiple users", async function () {
    const depositAmount1 = parseUsdc("100");
    const depositAmount2 = parseUsdc("200");
    const totalDepositAmount = depositAmount1.add(depositAmount2);

    // Alice deposits and opted-out by default
    await mintAndApproveUSDC(usdc, alice, escrow.address, depositAmount1);
    await escrow.connect(alice).deposit(depositAmount1);

    // Bob deposits and opted-in
    await mintAndApproveUSDC(usdc, bob, escrow.address, depositAmount2);
    await escrow.connect(bob).deposit(depositAmount2);

    expect(await usdc.balanceOf(escrow.address)).to.equal(totalDepositAmount);

    // Bob opts-in
    await escrow.connect(bob).optIn();

    // Check balances
    const aliceUserInfo = await escrow.userInfo(alice.address);
    expect(aliceUserInfo.usdcBalance).to.equal(depositAmount1);
    expect(aliceUserInfo.dynUSDCBalance).to.equal(0);
    expect(aliceUserInfo.optStatus).to.equal(OptStatus.OptOut);

    const bobUserInfo = await escrow.userInfo(bob.address);
    expect(bobUserInfo.usdcBalance).to.equal(0);
    expect(bobUserInfo.dynUSDCBalance).to.equal(depositAmount2);
    expect(bobUserInfo.optStatus).to.equal(OptStatus.OptIn);

    expect(await usdc.balanceOf(escrow.address)).to.equal(depositAmount1);
    expect(await vault.balanceOf(escrow.address)).to.equal(depositAmount2);

    // Withdraws
    await expect(escrow.connect(alice).withdraw(depositAmount1))
      .to.emit(escrow, "Withdraw")
      .withArgs(alice.address, depositAmount1);

    await expect(escrow.connect(bob).withdraw(depositAmount2))
      .to.emit(escrow, "Withdraw")
      .withArgs(bob.address, depositAmount2);
  });

  it("should ensure balances are updated correctly after multiple interactions", async function () {
    // Note: Here the ratio between USDC and DynUSDC is 1:1
    // TODO: Add more tests for different ratios

    const depositAmount = parseUsdc("100");
    await mintAndApproveUSDC(usdc, alice, escrow.address, depositAmount);
    await escrow.connect(alice).deposit(depositAmount);

    await escrow.connect(alice).optIn();
    await escrow.connect(alice).optOut();

    // Check balances after multiple opt-in and opt-out cycles
    const userBalance = await escrow.userInfo(alice.address);
    expect(userBalance.usdcBalance).to.equal(depositAmount);
  });
}
