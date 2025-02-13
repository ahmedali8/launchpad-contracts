// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

// types
import { TCommon } from "./TCommon.sol";

/// @title TEscrow
/// @notice Library to manage the user struct for the Escrow contract.
library TEscrow {
    /// @notice Struct to hold user details.
    ///
    /// @dev Packed into 2 storage slots
    /// @param balance The balance held by the user in the Escrow contract.
    /// Represents USDC if opted-out or DynUSDC if opted-in. (32 bytes)
    /// @param optStatus The current opt-in status of the user, whether they are opted in or out. (1 byte)
    struct UserInfo {
        uint256 balance;
        TCommon.OptStatus optStatus;
    }
}
