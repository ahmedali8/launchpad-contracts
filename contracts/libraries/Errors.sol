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

    /// @notice Error when the user receives insufficient DynUSDC amount after deposit to vault.
    error LaunchpadV3_Escrow_InsufficientDynUSDCAmountReceived();
}
