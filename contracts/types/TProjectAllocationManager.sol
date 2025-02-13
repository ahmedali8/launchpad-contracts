// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

library TProjectAllocationManager {
    /// @notice Enum for a user's opt-in status to Dynavault
    /// @dev Uses 1 byte
    enum OptStatus {
        OptOut, // 0 - User is opted out of Dynavault (does not earn yield)
        OptIn // 1 - User is opted in to Dynavault (earns yield on deposits)

    }

    /// @notice Enum for transaction types (claim or resolve)
    /// @dev Uses 1 byte
    enum TransactionType {
        Claim, // Indicates a claim transaction
        Resolve // Indicates a resolution transaction (reverting state)

    }

    /// @notice Struct for tracking individual claims on each chain for a user
    /// @dev Packed into 3 storage slots (32 bytes each)
    /// @param amount Amount of tokens the user has claimed on this chain (32 bytes).
    /// @param claimGUID GUID for tracking the specific claim for this chain (32 bytes).
    /// @param timestamp Timestamp when the claim was made (5 bytes).
    /// @param isProcessed Whether the claim has been processed (1 byte). TODO: maybe remove?
    /// @param txType Transaction type (Claim or Resolve) (1 byte).
    struct ChainClaim {
        uint256 amount;
        bytes32 claimGUID;
        uint40 timestamp;
        bool isProcessed;
        TransactionType txType;
    }

    /// @notice User's deposit and cross-chain claim information
    /// @dev Packed into 3 storage slots, mappings take separate storage
    /// @param usdcBalance The user's balance of USDC (32 bytes).
    /// @param dynUSDCBalance The user's balance of DynUSDC (32 bytes).
    /// @param optStatus Opt-in status for Dynavault yield generation (1 byte).
    struct UserInfo {
        uint256 usdcBalance;
        uint256 dynUSDCBalance;
        OptStatus optStatus;
    }

    /// @notice Vesting schedule details for the project
    /// @dev Packed into 1 storage slot (32 bytes)
    /// @param vestingStartTime Timestamp when vesting begins, typically at the Token Generation Event (TGE) (5 bytes).
    /// @param vestingCliffEndTime Timestamp when the vesting cliff period ends, and some tokens become unlocked (5
    /// bytes).
    /// @param vestingEndTime Timestamp when the vesting period and token emissions fully end (5 bytes).
    /// @param isVestingAccruingDuringCliff Whether tokens accrue during the cliff period (1 byte).
    struct VestingSchedule {
        uint40 vestingStartTime;
        uint40 vestingCliffEndTime;
        uint40 vestingEndTime;
        bool isVestingAccruingDuringCliff;
    }

    /// @notice Information about deposits, claims, and refunds for a project
    /// @dev Packed into 7 storage slots (32 bytes each)
    /// @param totalDepositedAmount Total amount of USDC deposited by all users for the project (32 bytes).
    /// @param totalTokenAllocation Total number of tokens allocated to all users in the project (32 bytes).
    /// @param totalTokensClaimed Total number of tokens claimed by users (32 bytes).
    /// @param totalRefundedAmount Total amount refunded to users who requested refunds (32 bytes).
    /// @param minimumDepositAmount Minimum amount of USDC a user must deposit to participate (32 bytes).
    /// @param maximumDepositAmount Maximum amount of USDC a user is allowed to deposit (32 bytes).
    /// @param depositCapAmount Maximum total deposits allowed for the project (32 bytes).
    struct DepositInfo {
        uint256 totalDepositedAmount;
        uint256 totalTokenAllocation;
        uint256 totalTokensClaimed;
        uint256 totalRefundedAmount;
        uint256 minimumDepositAmount;
        uint256 maximumDepositAmount;
        uint256 depositCapAmount;
    }

    /// @notice Timelines and deadlines related to the project
    /// @dev Packed into 1 storage slot (32 bytes)
    /// @param startTime The timestamp when the project officially begins (5 bytes).
    /// @param endTime The timestamp when the project ends (5 bytes).
    /// @param refundDeadline Deadline for requesting refunds (5 bytes).
    struct TimelineInfo {
        uint40 startTime;
        uint40 endTime;
        uint40 refundDeadline;
    }

    /// @notice Pricing and token unlock details for the project
    /// @dev Packed into 2 storage slots (32 bytes each)
    /// @param tokenPriceInUSDC The price per token in USDC for the project (32 bytes).
    /// @param initialUnlockPercentage The percentage of tokens unlocked at TGE, expressed in basis points (0.01%) (32
    /// bytes).
    struct PricingInfo {
        uint256 tokenPriceInUSDC;
        uint256 initialUnlockPercentage;
    }

    /// @notice Core project information and user claims
    /// @dev Multiple storage slots, packed where possible. 12 slots.
    /// @param dstTokenAddress The token address on the destination chain (20 bytes).
    /// @param dstEid LayerZero Endpoint ID of the destination chain. (4 bytes).
    /// @param depositInfo Grouped deposit and allocation information (7 storage slots).
    /// @param vestingSchedule Vesting schedule for the project (1 storage slot).
    /// @param timelineInfo Timeline details for the project (1 storage slot).
    /// @param pricingInfo Pricing and token unlock details for the project (2 storage slots).
    struct Project {
        address dstTokenAddress;
        uint32 dstEid;
        DepositInfo depositInfo;
        VestingSchedule vestingSchedule;
        TimelineInfo timelineInfo;
        PricingInfo pricingInfo;
    }
}
