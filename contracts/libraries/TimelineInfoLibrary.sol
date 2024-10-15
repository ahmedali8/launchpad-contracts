// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import { TProjectAllocationManager } from "../types/TProjectAllocationManager.sol";
import { Errors } from "./Errors.sol";

/// @title TimelineInfoLibrary
/// @notice Library to manage the validation and operations on TimelineInfo struct.
/// @dev Provides utilities to validate project timeline conditions like start and end times.
library TimelineInfoLibrary {
    /// @notice Checks if the start time is in the future and end time is after start time.
    /// @param timeline The TimelineInfo struct to validate.
    function checkTimeline(TProjectAllocationManager.TimelineInfo memory timeline) internal view {
        uint40 _blockTimestamp = uint40(block.timestamp);

        // Check: Ensure the project start time is in the future.
        if (timeline.startTime <= _blockTimestamp) {
            revert Errors.LaunchpadV3_TimelineInfo_InvalidStartTime(_blockTimestamp, timeline.startTime);
        }

        // Check: Ensure the project end time is greater than the start time.
        if (timeline.endTime <= timeline.startTime) {
            revert Errors.LaunchpadV3_TimelineInfo_InvalidEndTime(timeline.startTime, timeline.endTime);
        }
    }
}
