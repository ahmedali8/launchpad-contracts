import { formatUnits, parseUnits } from "@ethersproject/units";
import type { BigNumber, BigNumberish } from "ethers";

import { USDC_DECIMALS } from "../constants";

export function parseUsdc(value: string): BigNumber {
  return parseUnits(value, USDC_DECIMALS);
}

export function formatUsdc(value: BigNumberish): string {
  return formatUnits(value, USDC_DECIMALS);
}
