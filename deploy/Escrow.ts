import assert from "assert";
import { type DeployFunction } from "hardhat-deploy/types";

const libraryName = "Escrow";

const deploy: DeployFunction = async (hre) => {
  const { getNamedAccounts, deployments } = hre;

  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();

  assert(deployer, "Missing named deployer account");

  log(`Deployer: ${deployer}`);

  // Get the deployed libraries' addresses
  const AddressLibrary = await deployments.get("AddressLibrary");
  const Errors = await deployments.get("Errors");

  const { address } = await deploy(libraryName, {
    from: deployer,
    args: [],
    log: true,
    libraries: {
      AddressLibrary: AddressLibrary.address,
      Errors: Errors.address,
    },
  });

  log(`Deployed library: ${libraryName}, network: ${hre.network.name}, address: ${address}`);
};

deploy.tags = [libraryName];
deploy.dependencies = ["AddressLibrary", "Errors"];

export default deploy;
