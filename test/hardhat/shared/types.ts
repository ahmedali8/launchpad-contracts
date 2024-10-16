import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

export interface Signers {
  deployer: SignerWithAddress;
  alice: SignerWithAddress;
  bob: SignerWithAddress;
  moreSigners: SignerWithAddress[];
}
