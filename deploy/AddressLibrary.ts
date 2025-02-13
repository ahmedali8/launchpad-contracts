import assert from "assert";
import { type DeployFunction } from "hardhat-deploy/types";

const libraryName = "AddressLibrary";

const deploy: DeployFunction = async (hre) => {
  const { getNamedAccounts, deployments } = hre;

  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();

  assert(deployer, "Missing named deployer account");

  log(`Deployer: ${deployer}`);

  const { address } = await deploy(libraryName, {
    from: deployer,
    args: [],
    log: true,
  });

  log(`Deployed library: ${libraryName}, network: ${hre.network.name}, address: ${address}`);
};

deploy.tags = [libraryName];

export default deploy;
