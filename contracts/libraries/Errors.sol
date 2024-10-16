// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

/// @title Errors
/// @notice Library to manage error messages for the LaunchpadV3 contracts.
library Errors {
    /*//////////////////////////////////////////////////////////////
                                GENERICS
    //////////////////////////////////////////////////////////////*/

    /// @notice Error when the user has already opted in.
    error LaunchpadV3_UserAlreadyOptedIn();

    /// @notice Error when the user has not opted in.
    error LaunchpadV3_UserNotOptedIn();

    /*//////////////////////////////////////////////////////////////
                            ADDRESS LIBRARY 
    //////////////////////////////////////////////////////////////*/

    /// @notice Error when the address is zero address.
    error LaunchpadV3_AddressLibrary_InvalidAddress();

    /*//////////////////////////////////////////////////////////////
                            ESCROW CONTRACT
    //////////////////////////////////////////////////////////////*/

    /// @notice Error when the escrow contract is already initialized.
    error LaunchpadV3_Escrow_AlreadyInitialized();

    /// @notice Error when the amount is 0.
    error LaunchpadV3_Escrow_InvalidAmount();

    /// @notice Error when the user has insufficient USDC balance.
    error LaunchpadV3_Escrow_InsufficientUSDCBalance();

    /// @notice Error when the user has insufficient DynUSDC balance.
    error LaunchpadV3_Escrow_InsufficientDynUSDCBalance();

    /// @notice Error when the user cannot withdraw.
    error LaunchpadV3_Escrow_UserCannotWithdraw();

    // TODO: following will be updated with the design change

    /// @notice TimelineInfo Struct: Error for when the project start time is not in the future.
    /// @param currentTimestamp The current block timestamp.
    /// @param startTime The project start time.
    error LaunchpadV3_TimelineInfo_InvalidStartTime(uint40 currentTimestamp, uint40 startTime);

    /// @notice TimelineInfo Struct: Error for when the project end time is not after the start time.
    /// @param startTime The project start time.
    /// @param endTime The project end time.
    error LaunchpadV3_TimelineInfo_InvalidEndTime(uint40 startTime, uint40 endTime);

    /// @notice Thrown when the start time of vesting is greater than or equal to the cliff end time.
    /// @param vestingStartTime The timestamp when vesting starts.
    /// @param vestingCliffEndTime The timestamp when the cliff period ends.
    error LaunchpadV3_VestingSchedule_InvalidCliffTime(uint40 vestingStartTime, uint40 vestingCliffEndTime);

    /// @notice Thrown when the cliff end time is greater than the vesting end time.
    /// @param vestingCliffEndTime The timestamp when the cliff period ends.
    /// @param vestingEndTime The timestamp when vesting ends.
    error LaunchpadV3_VestingSchedule_InvalidEndTime(uint40 vestingCliffEndTime, uint40 vestingEndTime);
}
