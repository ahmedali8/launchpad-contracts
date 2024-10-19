// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

// types
import { TProjectAllocationManager } from "../types/TProjectAllocationManager.sol";

/// @title IProjectAllocationManager
/// @notice Interface for the ProjectAllocationManager contract.
interface IProjectAllocationManager {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Event emitted when a user deposits USDC or DynUSDC.
    /// @param user The address of the user.
    /// @param amount The amount deposited.
    event Deposited(address indexed user, uint256 amount);

    /// @notice Event emitted when a user requests a refund.
    /// @param user The address of the user.
    /// @param amount The refunded amount.
    event Refunded(address indexed user, uint256 amount);

    /// @notice Event emitted when a user claims tokens.
    /// @param user The address of the user.
    /// @param amount The amount of tokens claimed.
    /// @param destinationAddress The address on the destination network.
    event Claimed(address indexed user, uint256 amount, address destinationAddress);

    /// @notice Event emitted when the project is initialized.
    /// @param project The project information.
    event Initialized(TProjectAllocationManager.Project project);

    /// @notice Event emitted when the vesting schedule is updated.
    /// @param vestingSchedule The struct defining the vesting schedule.
    event VestingScheduleUpdated(TProjectAllocationManager.VestingSchedule vestingSchedule);

    /// @notice Event emitted when the refund period is updated.
    /// @param refundPeriod The struct defining the refund period.
    event RefundPeriodUpdated(TProjectAllocationManager.RefundPeriod refundPeriod);

    /// @notice Event emitted when tokens are collected from the contract.
    /// @param to Receiver of the tokens.
    /// @param amount The amount of tokens collected.
    event DepositsCollected(address indexed to, uint256 amount);

    /// @notice Event emitted when the whitelist signer is set.
    /// @param signer The address of the new whitelist signer.
    event SignerSet(address indexed signer);

    /// @notice Event emitted when native tokens are recovered.
    /// @param amount The amount of native tokens recovered.
    event GasRecovered(uint256 amount);

    /// @notice Event emitted when any tokens accidentally sent to the contract are recovered.
    /// @param token The address of the token recovered.
    /// @param amount The amount of tokens recovered.
    event TokensRecovered(address indexed token, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                         NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Allows users to deposit USDC in the project to get tokens.
    /// @dev This calls the Escrow contract's `takeFundsFromUser` function to take the user's funds.
    /// - If the user has opted-in that means they have DynUSDC, so the contract will take DynUSDC and convert it to
    /// USDC
    /// because the price of tokens is in USDC.
    /// - If the user has opted-out that means they have USDC, so the contract will take USDC.
    /// @param amount The amount of USDC to deposit.
    /// @param salt The salt used to sign the message.
    /// @param signature The signature of the message.
    function deposit(uint256 amount, string calldata salt, bytes calldata signature) external;

    /// @notice Allows users to request a refund.
    /// @dev If users no longer wish to participate in a project, they can request a refund before the token sale
    /// concludes.
    function refund() external;

    /// @notice Allows the user to request reimbursement.
    /// @dev More funds were deposited so the excess amount is calculated based on the user’s allocation.
    function reimbursement() external;

    /// @notice Allows users to claim their allocated tokens.
    function claim() external;

    /*//////////////////////////////////////////////////////////////
                   NON-CONSTANT ONLY-ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Initializes the project.
    /// @dev This function sets up all the project details.
    /// @dev Only the admin can call this function.
    /// @dev It can only be called once.
    /// @param project The struct containing the initial project details.
    function initializer(TProjectAllocationManager.Project calldata project) external;

    /// @notice Configures the vesting parameters.
    /// @dev Only the admin can call this function.
    /// @param vestingSchedule The struct defining the vesting schedule.
    function setVestingSchedule(TProjectAllocationManager.VestingSchedule calldata vestingSchedule) external;

    /// @notice Configures the refund period.
    /// @dev Only the admin can call this function.
    /// @param refundPeriod The struct defining the refund period.
    function setRefundPeriod(TProjectAllocationManager.RefundPeriod calldata refundPeriod) external;

    /// @notice Withdraw tokens from the contract.
    /// @dev Only the admin can call this function.
    /// @param to Receiver of the tokens.
    function collectDeposits(address to) external;

    /// @notice Sets the whitelist signer.
    /// @dev Only the admin can call this function.
    function setSigner(address signer) external;

    /// @notice Recover native tokens.
    /// @dev Only the admin can call this function.
    function recoverGas() external;

    /// @notice Recover any tokens accidentally sent to the contract excluding properly deposited or bought tokens.
    /// @dev Only the admin can call this function.
    function recoverAnyTokens(address token) external;
}
