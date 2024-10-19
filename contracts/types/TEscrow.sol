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

    /// @notice Struct to hold user details.
    ///
    /// @dev Packed into 2 storage slots
    /// @param balance The balance held by the user in the Escrow contract.
    /// Represents USDC if opted-out or DynUSDC if opted-in. (32 bytes)
    /// @param optStatus The current opt-in status of the user, whether they are opted in or out. (1 byte)
    struct UserInfo {
        uint256 balance;
        OptStatus optStatus;
    }
}
