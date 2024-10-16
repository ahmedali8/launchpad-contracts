import { ethers } from "hardhat";
import type { Libraries } from "hardhat/types";

import type {
  AddressLibrary,
  AddressLibrary__factory,
  Errors,
  Errors__factory,
  Escrow,
  Escrow__factory,
} from "../../../typechain-types";
import { getSigners } from "../utils/getSigners";

export async function deployAddressLibrary() {
  const { deployer } = await getSigners();
  const AddressLibraryFactory: AddressLibrary__factory = (await ethers.getContractFactory(
    "AddressLibrary",
    deployer
  )) as AddressLibrary__factory;
  const addressLibrary: AddressLibrary = await AddressLibraryFactory.deploy();
  return { addressLibrary };
}

export async function deployErrors() {
  const { deployer } = await getSigners();
  const ErrorsFactory: Errors__factory = (await ethers.getContractFactory("Errors")) as Errors__factory;
  const errors: Errors = await ErrorsFactory.connect(deployer).deploy();
  return { errors };
}

export async function escrowFixture() {
  const { deployer } = await getSigners();

  const { addressLibrary } = await deployAddressLibrary();
  const { errors } = await deployErrors();

  const escrowLibDependencies: Libraries = {
    "contracts/libraries/AddressLibrary.sol:AddressLibrary": addressLibrary.address,
    "contracts/libraries/Errors.sol:Errors": errors.address,
  };
  const EscrowFactory: Escrow__factory = (await ethers.getContractFactory("Escrow", {
    libraries: escrowLibDependencies,
    signer: deployer,
  })) as Escrow__factory;
  const escrow: Escrow = await EscrowFactory.deploy();

  return { escrow, addressLibrary, errors };
}
