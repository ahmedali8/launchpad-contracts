// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

library TTokenDistributor {
    /// @notice Struct to store information related to the token distribution for each project.
    /// @dev This struct is byte-packed to save storage space.
    /// - tokenAddress (20 bytes): The token address on the destination chain.
    /// - totalAllocated, totalClaimed, totalTokens (32 bytes each): Stores total allocated, claimed, and available
    /// tokens for distribution.
    /// - lzEid (4 bytes): LayerZero endpoint ID for cross-chain communication with the destination chain.
    /// @dev Total size: 120 bytes, rounded to 160 bytes due to storage slot alignment.
    struct ProjectTokenInfo {
        /// @notice Token address for the project on the destination chain.
        /// @dev This is the token that will be distributed to users.
        address tokenAddress;
        /// @notice Total tokens allocated for the project.
        /// @dev This represents the total amount of tokens designated for distribution within the project.
        uint256 totalAllocated;
        /// @notice Total tokens claimed by users so far.
        /// @dev Tracks the total number of tokens that users have already claimed from the project.
        uint256 totalClaimed;
        /// @notice Total tokens available for distribution.
        /// @dev This represents the total number of tokens available for claim within the project.
        uint256 totalTokens;
        /// @notice LayerZero endpoint ID for cross-chain communication.
        /// @dev Used to identify the destination chain for cross-chain messages.
        uint32 lzEid;
    }
}
