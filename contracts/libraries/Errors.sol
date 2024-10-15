// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

library Errors {
    error LaunchpadV3_UserAlreadyOptedIn();

    error LaunchpadV3_UserNotOptedIn();

    /// @notice Error when the amount is 0.
    error LaunchpadV3_Escrow_InvalidAmount();

    error LaunchpadV3_Escrow_InsufficientUSDCBalance();

    error LaunchpadV3_Escrow_InsufficientDynUSDCBalance();

    error LaunchpadV3_Escrow_UserCannotWithdraw();

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
