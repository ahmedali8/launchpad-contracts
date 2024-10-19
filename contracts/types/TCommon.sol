// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

/// @title TCommon
/// @notice Library to manage common types.
library TCommon {
    /// @notice Enum representing whether the user has opted into a yield-bearing vault (Dynavault).
    /// @dev Tracks the opt-in status for yield accumulation.
    /// - OptOut: User holds USDC and does not earn yield.
    /// - OptIn:  User's USDC is converted to DynUSDC, and they earn yield.
    enum OptStatus {
        OptOut,
        OptIn
    }
}
