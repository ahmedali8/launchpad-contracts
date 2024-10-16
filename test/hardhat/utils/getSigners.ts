import { ethers } from "hardhat";

import type { Signers } from "../shared/types";

export async function getSigners(): Promise<Signers> {
  const [deployer, alice, bob, ...moreSigners] = await ethers.getSigners();
  return { deployer, alice, bob, moreSigners };
}
