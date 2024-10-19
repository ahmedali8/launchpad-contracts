import { parseUnits } from "@ethersproject/units";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import type { Libraries } from "hardhat/types";

import type {
  AddressLibrary,
  AddressLibrary__factory,
  Errors,
  Errors__factory,
  Escrow,
  Escrow__factory,
  USDCMock,
  USDCMock__factory,
  VaultMock,
  VaultMockVariableRatio,
  VaultMockVariableRatio__factory,
  VaultMock__factory,
} from "../../../typechain-types";
import { getSigners } from "../utils/getSigners";

/// LIBRARIES ///

export async function deployAddressLibrary() {
  const { deployer } = await getSigners();
  const AddressLibraryFactory: AddressLibrary__factory = (await ethers.getContractFactory(
    "AddressLibrary",
    deployer
  )) as AddressLibrary__factory;
  const addressLibrary: AddressLibrary = await AddressLibraryFactory.deploy();
  await addressLibrary.deployed();
  return { addressLibrary };
}

export async function deployErrors() {
  const { deployer } = await getSigners();
  const ErrorsFactory: Errors__factory = (await ethers.getContractFactory("Errors")) as Errors__factory;
  const errors: Errors = await ErrorsFactory.connect(deployer).deploy();
  await errors.deployed();
  return { errors };
}

/// MOCKS ///

export async function deployUSDCMock() {
  const { deployer } = await getSigners();
  const USDCMockFactory: USDCMock__factory = (await ethers.getContractFactory("USDCMock")) as USDCMock__factory;
  const usdcMock: USDCMock = await USDCMockFactory.connect(deployer).deploy();
  await usdcMock.deployed();
  return { usdcMock };
}

export async function deployVaultMock(usdcAddress: string) {
  const { deployer } = await getSigners();
  const VaultMockFactory: VaultMock__factory = (await ethers.getContractFactory("VaultMock")) as VaultMock__factory;
  const vaultMock: VaultMock = await VaultMockFactory.connect(deployer).deploy(usdcAddress);
  await vaultMock.deployed();
  return { vaultMock };
}

export async function deployVaultMockVariableRatio(usdcAddress: string, ratio: BigNumber) {
  const { deployer } = await getSigners();
  const VaultMockVariableRatioFactory: VaultMockVariableRatio__factory = (await ethers.getContractFactory(
    "VaultMockVariableRatio"
  )) as VaultMockVariableRatio__factory;
  const vaultMockVariableRatio: VaultMockVariableRatio = await VaultMockVariableRatioFactory.connect(deployer).deploy(
    usdcAddress,
    ratio
  );
  await vaultMockVariableRatio.deployed();
  return { vaultMockVariableRatio };
}

/// CONTRACTS ///

export async function deployEscrow() {
  const { deployer } = await getSigners();

  const { addressLibrary } = await deployAddressLibrary();

  const escrowLibDependencies: Libraries = {
    "contracts/libraries/AddressLibrary.sol:AddressLibrary": addressLibrary.address,
  };
  const EscrowFactory: Escrow__factory = (await ethers.getContractFactory("Escrow", {
    libraries: escrowLibDependencies,
    signer: deployer,
  })) as Escrow__factory;
  const escrow: Escrow = await EscrowFactory.deploy();
  await escrow.deployed();

  return { escrow, addressLibrary };
}

/// TEST SETUPS ///

// ESCROW TESTS //

export async function setupEscrowUnitTest() {
  // Deploy mocks
  const { usdcMock } = await deployUSDCMock();
  const { vaultMock } = await deployVaultMock(usdcMock.address);

  // Deploy escrow
  const { escrow, addressLibrary } = await deployEscrow();

  // Initialize the escrow contract
  await escrow.initializer(usdcMock.address, vaultMock.address);

  return {
    usdcMock,
    vaultMock,
    escrow,
    addressLibrary,
  };
}

export async function setupEscrowE2ETest() {
  const initialRatio = parseUnits("1"); // 1e18

  // Deploy mocks
  const { usdcMock: usdc } = await deployUSDCMock();
  const { vaultMockVariableRatio: vault } = await deployVaultMockVariableRatio(usdc.address, initialRatio);

  // Deploy escrow
  const { escrow, addressLibrary } = await deployEscrow();

  // Initialize the escrow contract
  await escrow.initializer(usdc.address, vault.address);

  return {
    usdc,
    vault,
    escrow,
    addressLibrary,
  };
}
