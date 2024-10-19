// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

// types
import { TCommon } from "./TCommon.sol";

/// @title TProjectAllocationManager
/// @notice Library to manage the project struct for the ProjectAllocationManager contract.
library TProjectAllocationManager {
    /// @notice User's information.
    /// @dev Packed into 5 storage slots.
    /// @param balance The user's balance of USDC or DynUSDC (32 bytes).
    /// @param allocation The user's token allocation (32 bytes).
    /// @param usdcRefunded The amount of USDC refunded to the user (32 bytes).
    /// @param claimedTokens The number of tokens claimed by the user (32 bytes).
    /// @param optStatus Opt-in status for Dynavault yield generation (1 byte).
    struct UserInfo {
        uint256 balance;
        uint256 allocation;
        uint256 usdcRefunded;
        uint256 claimedTokens;
        TCommon.OptStatus optStatus;
    }

    /// @notice Vesting schedule details for the project.
    /// @dev Packed into 2 storage slots.
    /// @param vestingStartTime Timestamp when vesting begins, typically at the Token Generation Event (TGE) (5 bytes).
    /// @param vestingCliffEndTime Timestamp when the vesting cliff period ends, and tokens become unlocked (5 bytes).
    /// @param vestingEndTime Timestamp when the vesting period and token emissions fully end (5 bytes).
    /// @param isVestingAccruingDuringCliff Whether tokens accrue during the cliff period (1 byte).
    /// @param initialUnlockPercentage Percentage of tokens unlocked at TGE, in basis points (0.01%) (32 bytes).
    struct VestingSchedule {
        uint40 vestingStartTime;
        uint40 vestingCliffEndTime;
        uint40 vestingEndTime;
        bool isVestingAccruingDuringCliff;
        uint256 initialUnlockPercentage;
    }

    /// @notice Refund period details for the project.
    /// @param refundStartTime The timestamp when users can start requesting refunds (5 bytes).
    /// @param refundEndTime The timestamp when the refund period ends (5 bytes).
    struct RefundPeriod {
        uint40 startTime;
        uint40 endTime;
    }

    /// @notice Information related to deposits.
    /// @dev Packed into 9 storage slots.
    /// @param startTime The timestamp when the project deposits begin (5 bytes).
    /// @param endTime The timestamp when the project deposits ends (5 bytes).
    /// @param tokenPriceInUSDC Price of the token in USDC (32 bytes).
    /// @param totalDepositedAmount Total amount of USDC deposited by all users for the project (32 bytes).
    /// @param totalTokenAllocation Total number of tokens allocated to all users in the project (32 bytes).
    /// @param totalTokensClaimed Total number of tokens claimed by users (32 bytes).
    /// @param totalRefundedAmount Total amount refunded to users who requested refunds (32 bytes).
    /// @param minimumDepositAmount Minimum amount of USDC a user must deposit to participate (32 bytes).
    /// @param maximumDepositAmount Maximum amount of USDC a user is allowed to deposit (32 bytes).
    /// @param depositCapAmount Maximum total deposits allowed for the project (32 bytes).
    struct DepositInfo {
        uint40 startTime;
        uint40 endTime;
        uint256 tokenPriceInUSDC;
        uint256 totalDepositedAmount;
        uint256 totalTokenAllocation;
        uint256 totalTokensClaimed;
        uint256 totalRefundedAmount;
        uint256 minimumDepositAmount;
        uint256 maximumDepositAmount;
        uint256 depositCapAmount;
    }

    /// @notice Core project information and user claims.
    /// @param dstTokenAddress The token address on the destination chain (20 bytes).
    /// @param dstEid LayerZero Endpoint ID of the destination chain. (4 bytes).
    /// @param depositInfo Deposit information (9 storage slots).
    /// @param refundPeriod Refund period for the project (1 storage slot).
    /// @param vestingSchedule Vesting schedule for the project (1 storage slot).
    struct Project {
        address dstTokenAddress;
        uint32 dstEid;
        DepositInfo depositInfo;
        RefundPeriod refundPeriod;
        VestingSchedule vestingSchedule;
    }
}
