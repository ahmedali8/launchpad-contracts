// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

/// @title TEscrow
/// @notice Library to manage the user struct for the Escrow contract.
library TEscrow {
    /// @notice Enum representing whether the user has opted into a yield-bearing vault (Dynavault).
    /// @dev Tracks the opt-in status for yield accumulation.
    /// - OptOut: User holds USDC and does not earn yield.
    /// - OptIn:  User's USDC is converted to DynUSDC, and they earn yield.
    enum OptStatus {
        OptOut,
        OptIn
    }

    /// @notice Struct to hold user details for the Escrow contract.
    /// @dev Packed into 3 storage slots
    /// Total size: 65 bytes (rounded up to 96 bytes due to storage slot alignment).
    /// @param usdcBalance The balance of USDC held by the user in the Escrow contract. (32 bytes)
    /// @param dynUSDCBalance The balance of DynUSDC held by the user if they opted into yield earning. (32 bytes)
    /// @param optStatus The current opt-in status of the user, whether they are opted in or out. (1 byte)
    struct UserInfo {
        uint256 usdcBalance;
        uint256 dynUSDCBalance;
        OptStatus optStatus;
    }
}
