// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

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
    /// @dev The struct is byte-packed to optimize storage.
    /// Each `uint256` variable occupies 32 bytes, and `OptStatus` occupies 1 byte.
    /// The total size of this struct is 129 bytes, rounded up to 160 bytes due to Solidity's 32-byte storage slot
    /// alignment.
    ///
    /// @dev Packed into 5 storage slots (129 bytes)
    /// @param usdcBalance The balance of USDC held by the user in the Escrow contract. (32 bytes)
    /// @param dynUSDCBalance The balance of DynUSDC held by the user if they opted into yield earning. (32 bytes)
    /// @param yieldBalance The accumulated yield earned by the user through Dynavault. (32 bytes)
    /// @param conversionRatio The ratio used to convert USDC to DynUSDC, in basis points (e.g., 1 USDC = 1.02 DynUSDC).
    /// (32 bytes)
    /// @param optStatus The current opt-in status of the user, whether they are opted in or out. (1 byte)
    ///
    /// @dev Total size: 129 bytes (rounded up to 160 bytes due to storage slot alignment).
    struct UserInfo {
        uint256 usdcBalance;
        uint256 dynUSDCBalance;
        uint256 yieldBalance;
        uint256 conversionRatio;
        OptStatus optStatus;
    }
}
