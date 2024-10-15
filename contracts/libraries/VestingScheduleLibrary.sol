// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import { TProjectAllocationManager } from "../types/TProjectAllocationManager.sol";
import { Errors } from "./Errors.sol";

/// @title VestingScheduleLibrary
/// @notice Library for operations related to VestingSchedule struct.
/// @dev Provides utilities for calculating and validating vesting schedules.
library VestingScheduleLibrary {
    /// @notice Validates a vesting schedule to ensure the start, cliff, and end times are in the correct order.
    /// @param schedule The vesting schedule to validate.
    function checkVestingSchedule(TProjectAllocationManager.VestingSchedule memory schedule) internal pure {
        // Check: Cliff end time must come after the start time.
        if (schedule.vestingStartTime >= schedule.vestingCliffEndTime) {
            revert Errors.LaunchpadV3_VestingSchedule_InvalidCliffTime(
                schedule.vestingStartTime, schedule.vestingCliffEndTime
            );
        }

        // Check: Vesting end time must come after the cliff period ends.
        if (schedule.vestingCliffEndTime > schedule.vestingEndTime) {
            revert Errors.LaunchpadV3_VestingSchedule_InvalidEndTime(
                schedule.vestingCliffEndTime, schedule.vestingEndTime
            );
        }
    }

    /// @notice Returns boolean whether the cliff period has ended.
    /// @param vesting The vesting schedule to check.
    /// @return bool Whether the cliff has ended.
    function isCliffEnded(TProjectAllocationManager.VestingSchedule memory vesting) internal view returns (bool) {
        return uint40(block.timestamp) >= vesting.vestingCliffEndTime;
    }

    /// @notice Returns boolean whether the entire vesting period has ended.
    /// @param vesting The vesting schedule to check.
    /// @return bool Whether the vesting period is complete.
    function isVestingComplete(TProjectAllocationManager.VestingSchedule memory vesting) internal view returns (bool) {
        return uint40(block.timestamp) >= vesting.vestingEndTime;
    }
}
