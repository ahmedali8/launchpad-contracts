// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import { ERC4626 } from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import { IERC20, ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import "hardhat/console.sol";

contract VaultMockVariableRatio is ERC4626 {
    using Math for uint256;

    // The ratio used for conversion (scaled to handle decimals properly)
    uint256 private _ratioPerUnderlying;

    uint256 private constant _PRECISION = 1e18;

    constructor(
        address underlying,
        uint256 ratioPerUnderlying
    )
        ERC20("VaultMockVariableRatio", "VaultMockVR")
        ERC4626(IERC20(underlying))
    {
        _ratioPerUnderlying = ratioPerUnderlying;
    }

    function setRatioPerUnderlying(uint256 newRatioPerUnderlying) external {
        _ratioPerUnderlying = newRatioPerUnderlying;
    }

    function getRatioPerUnderlying() external view returns (uint256) {
        return _ratioPerUnderlying;
    }

    /// OVERRIDES ///

    function _decimalsOffset() internal view override returns (uint8) {
        // DynUSDC(shares): 18 decimals
        // USDC(asset): 6 decimals
        return 12;
    }

    function _convertToShares(uint256 assets, Math.Rounding rounding) internal view override returns (uint256) {
        return assets * _ratioPerUnderlying / _PRECISION;

        // return super._convertToShares(assets, rounding).mulDiv(_ratioPerUnderlying, _PRECISION);
    }

    function _convertToAssets(uint256 shares, Math.Rounding rounding) internal view override returns (uint256) {
        return shares * _PRECISION / _ratioPerUnderlying;
        /*

         */
        // console.log("_convertToAssets", super._convertToAssets(shares, rounding));
        // return super._convertToAssets(shares, rounding).mulDiv(_PRECISION, _ratioPerUnderlying);
    }
}
