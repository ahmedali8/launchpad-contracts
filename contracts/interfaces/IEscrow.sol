// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

interface IEscrow {
    /// @notice Initializes the Escrow contract by setting the USDC and vault addresses.
    /// @dev Can only be called once. It checks if the contract has already been initialized.
    /// @dev Reverts if:
    /// - the contract is already initialized.
    /// - the provided addresses are zero addresses.
    /// @param usdcAddress The address of the USDC token.
    /// @param vaultAddress The address of the Dynavault (yield-bearing vault).
    function initializer(address usdcAddress, address vaultAddress) external;

    /// @notice Allows users to deposit USDC into the escrow contract.
    /// @dev The deposited amount is added to the user's USDC balance.
    /// @dev Reverts if:
    /// - the deposit amount is zero.
    /// @param amount The amount of USDC to deposit.
    function deposit(uint256 amount) external;

    /// @notice Allows users to withdraw their USDC, including converting DynUSDC back to USDC if the user is opted in.
    /// @dev If the user is opted in, their DynUSDC is first redeemed for USDC.
    /// @dev Reverts if:
    /// - the user has insufficient USDC to withdraw.
    /// - the user is opted in and has insufficient DynUSDC to redeem.
    /// @param usdcAmount The amount of USDC to withdraw.
    function withdraw(uint256 usdcAmount) external;

    /// @notice Allows users to opt-in to the Dynavault and convert their USDC to DynUSDC.
    /// @dev Converts the user's USDC balance into DynUSDC using the Dynavault's deposit mechanism.
    /// @dev Reverts if:
    /// - the user has no USDC to convert.
    /// - the user is already opted into Dynavault.
    function optIn() external;

    /// @notice Allows users to opt-out of the Dynavault and convert their DynUSDC back to USDC.
    /// @dev Converts the user's DynUSDC balance back to USDC using the Dynavault's redeem mechanism.
    /// @dev Reverts if:
    /// - the user has no DynUSDC to convert.
    /// - the user is not opted into Dynavault.
    function optOut() external;

    /// @notice Event emitted when a user deposits USDC.
    /// @param user The address of the user who deposited USDC.
    /// @param amount The amount of USDC deposited by the user.
    event Deposit(address indexed user, uint256 amount);

    /// @notice Event emitted when a user withdraws USDC.
    /// @param user The address of the user who withdrew USDC.
    /// @param amount The amount of USDC withdrawn by the user.
    event Withdraw(address indexed user, uint256 amount);

    /// @notice Event emitted when a user opts in to Dynavault.
    /// @param user The address of the user who opted into Dynavault.
    /// @param usdcAmount The amount of USDC that was converted into DynUSDC.
    /// @param dynUSDCAmount The amount of DynUSDC received by the user.
    event OptIn(address indexed user, uint256 usdcAmount, uint256 dynUSDCAmount);

    /// @notice Event emitted when a user opts out of Dynavault.
    /// @param user The address of the user who opted out of Dynavault.
    /// @param dynUSDCAmount The amount of DynUSDC converted back into USDC.
    /// @param usdcAmount The amount of USDC received by the user.
    event OptOut(address indexed user, uint256 dynUSDCAmount, uint256 usdcAmount);

    /// @notice Event emitted when the vault address is updated.
    /// @param prevVault The address of the prev vault.
    /// @param newVault The address of the new vault.
    event VaultUpdated(address prevVault, address newVault);
}
