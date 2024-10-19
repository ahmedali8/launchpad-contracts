// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

// types
import { TEscrow } from "../types/TEscrow.sol";

/// @title IEscrow
/// @notice Interface for the Escrow contract.
interface IEscrow {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Event emitted when a user deposits USDC.
    /// @param user The address of the user who deposited USDC.
    /// @param amount The amount of USDC deposited by the user.
    /// @param optStatus The opt-in status of the user for the deposit.
    event Deposited(address indexed user, uint256 amount, TEscrow.OptStatus optStatus);

    /// @notice Event emitted when a user withdraws USDC.
    /// @param user The address of the user who withdrew USDC.
    /// @param amount The amount of USDC withdrawn by the user.
    event Withdrawn(address indexed user, uint256 amount);

    /// @notice Event emitted when the ProjectAllocationManager takes funds from a user.
    /// @param user The address of the user whose funds were taken.
    /// @param amount The amount of funds taken from the user.
    event FundsTaken(address indexed user, uint256 amount);

    /// @notice Event emitted when the ProjectAllocationManager refunds funds to a user.
    /// @param user The address of the user who was refunded.
    /// @param amount The amount of funds refunded to the user.
    event FundsRefunded(address indexed user, uint256 amount);

    /// @notice Event emitted when the vault address is updated.
    /// @param prevVault The address of the prev vault.
    /// @param newVault The address of the new vault.
    event VaultUpdated(address prevVault, address newVault);

    /*//////////////////////////////////////////////////////////////
                         NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Initializes the Escrow contract by setting the USDC and vault addresses.
    /// @dev Can only be called once. It checks if the contract has already been initialized.
    /// @dev Reverts if:
    /// - the contract is already initialized.
    /// - the provided addresses are zero addresses.
    /// @param usdcAddress The address of the USDC token.
    /// @param vaultAddress The address of the Dynavault (yield-bearing vault).
    function initializer(address usdcAddress, address vaultAddress) external;

    /// @notice Allows users to deposit USDC into the escrow contract with an option to opt-in or opt-out.
    /// @dev The deposited amount is added to the user's balance based on their opt-in status.
    /// @dev Reverts if:
    /// - the deposit amount is zero.
    /// - the USDC is not approved to this contract.
    /// @param amount The amount of USDC to deposit.
    /// @param optStatus The opt-in status (OptIn or OptOut) for the deposit.
    function deposit(uint256 amount, TEscrow.OptStatus optStatus) external;

    /// @notice Allows users to withdraw their USDC or DynUSDC converted back to USDC based on their opt-in status.
    /// @dev If the user is opted-in, their DynUSDC is first redeemed for USDC.
    /// @dev Reverts if:
    /// - the user has insufficient balance to withdraw.
    function withdraw() external;

    /*//////////////////////////////////////////////////////////////
                     NON-CONSTANT ONLY-PAM FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Allows the ProjectAllocationManager to take the user's funds based on their current opt-in status.
    /// @dev Only the ProjectAllocationManager contract can call this function.
    /// @param user The address of the user whose funds are being taken.
    /// @param amount The amount of funds to take from the user.
    function takeFundsFromUser(address user, uint256 amount) external;

    /// @notice Allows the ProjectAllocationManager to refund funds back to the user based on their current opt-in
    /// status.
    /// @dev Only the ProjectAllocationManager contract can call this function.
    /// @param user The address of the user to refund.
    /// @param amount The amount of funds to refund to the user.
    function refundFundsToUser(address user, uint256 amount) external;
}
