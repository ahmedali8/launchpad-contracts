// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

/// @title TTokenDistributor
/// @notice Library to store information related to the token distribution for each project.
library TTokenDistributor {
    /// @notice Struct to store information related to the token distribution for each project.
    /// @dev Packed into 3 storage slots.
    /// @param tokenAddress Token address for the project. (20 bytes)
    /// @param srcEid LayerZero endpoint ID for cross-chain communication. (4 bytes)
    /// @param totalAllocated Total tokens allocated for the project. (32 bytes)
    /// @param totalClaimed Total tokens claimed by users so far. (32 bytes)
    struct ProjectInfo {
        address tokenAddress;
        uint32 srcEid;
        uint256 totalAllocated;
        uint256 totalClaimed;
    }
}
