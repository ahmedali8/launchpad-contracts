import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import type { BigNumber } from "ethers";

import type { USDCMock } from "../../../typechain-types";

export async function mintAndApproveUSDC(token: USDCMock, from: SignerWithAddress, to: string, amount: BigNumber) {
  await token.connect(from).mint(from.address, amount);
  await token.connect(from).approve(to, amount);
}
