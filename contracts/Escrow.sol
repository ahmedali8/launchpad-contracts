// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

// interfaces
import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IEscrow } from "./interfaces/IEscrow.sol";

// libraries
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { Errors } from "./libraries/Errors.sol";
import { AddressLibrary } from "./libraries/AddressLibrary.sol";

// types
import { TEscrow } from "./types/TEscrow.sol";

// abstract contracts
import { Clonable } from "./utilities/Clonable.sol";

/// @title Escrow Contract
/// @dev A contract that allows users to deposit USDC and earn yield if opted-in to a yield-bearing vault.
contract Escrow is Clonable, ReentrancyGuard, IEscrow {
    using SafeERC20 for IERC20;
    using AddressLibrary for address;

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice USDC token address
    IERC20 public usdc;

    /// @notice Dynavault address
    IERC4626 public vault;

    /// @notice Mapping to track the balances and statuses of each user in the Escrow contract.
    /// @dev Maps each user address to their corresponding `UserInfo` struct.
    mapping(address => TEscrow.UserInfo) public userInfo;

    /*//////////////////////////////////////////////////////////////
                         NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IEscrow
    function initializer(address usdcAddress, address vaultAddress) external override {
        // Check: Ensure the contract is not already initialized
        if (!address(usdc).isAddressZero() || !address(vault).isAddressZero()) {
            revert Errors.LaunchpadV3_Escrow_AlreadyInitialized();
        }

        // Check: Ensure the USDC and Dynavault addresses are not zero
        usdcAddress.checkAddressZero();
        vaultAddress.checkAddressZero();

        usdc = IERC20(usdcAddress);
        vault = IERC4626(vaultAddress);
    }

    /// @inheritdoc IEscrow
    function deposit(uint256 amount) external override {
        if (amount == 0) revert Errors.LaunchpadV3_Escrow_InvalidAmount();

        // Transfer USDC from user to this contract
        usdc.safeTransferFrom(_msgSender(), address(this), amount);

        // Update user's USDC balance in the escrow contract
        userInfo[_msgSender()].usdcBalance += amount;

        // Emit deposit event
        emit Deposit(_msgSender(), amount);
    }

    /// @inheritdoc IEscrow
    function withdraw(uint256 usdcAmount) external override nonReentrant {
        TEscrow.UserInfo memory _user = userInfo[_msgSender()];

        // If user is opted in, convert DynUSDC to USDC
        if (_user.optStatus == TEscrow.OptStatus.OptIn) {
            if (_user.dynUSDCBalance == 0) revert Errors.LaunchpadV3_Escrow_InsufficientDynUSDCBalance();

            // Redeem DynUSDC from the vault and convert back to USDC
            usdcAmount = vault.withdraw({ assets: usdcAmount, receiver: address(this), owner: address(this) });
            _user.dynUSDCBalance = 0;
            _user.optStatus = TEscrow.OptStatus.OptOut;
        }

        // If user is opted out, withdraw USDC directly

        if (_user.usdcBalance < usdcAmount) {
            revert Errors.LaunchpadV3_Escrow_InsufficientUSDCBalance();
        }

        // Transfer USDC to user
        usdc.safeTransfer(_msgSender(), usdcAmount);

        // Emit withdrawal event
        emit Withdraw(_msgSender(), usdcAmount);
    }

    /// @inheritdoc IEscrow
    function optIn() external override nonReentrant {
        TEscrow.UserInfo memory _user = userInfo[_msgSender()];

        // Check: If the user is already opted-in
        if (_user.optStatus == TEscrow.OptStatus.OptIn) revert Errors.LaunchpadV3_UserAlreadyOptedIn();

        // Check: Ensure the user has USDC to convert
        if (_user.usdcBalance == 0) revert Errors.LaunchpadV3_Escrow_InsufficientUSDCBalance();

        // Approve Dynavault to spend the user's USDC
        usdc.approve(address(vault), _user.usdcBalance);

        // Deposit USDC into Dynavault and mint DynUSDC (shares) for the user
        uint256 _dynUSDCAmount = vault.deposit({ assets: _user.usdcBalance, receiver: address(this) });

        // Update user info to storage
        _user.usdcBalance = 0;
        _user.dynUSDCBalance += _dynUSDCAmount;
        _user.optStatus = TEscrow.OptStatus.OptIn;
        userInfo[_msgSender()] = _user;

        // Emit opt-in event
        emit OptIn(_msgSender(), _user.usdcBalance, _dynUSDCAmount);
    }

    /// @inheritdoc IEscrow
    function optOut() external override nonReentrant {
        TEscrow.UserInfo memory _user = userInfo[_msgSender()];

        // Check: Ensure the user is opted in
        if (_user.optStatus != TEscrow.OptStatus.OptIn) revert Errors.LaunchpadV3_UserNotOptedIn();

        // Assert Invariant: The DynUSDC balance of user cannot be zero when opted-in.
        assert(_user.dynUSDCBalance > 0);

        // Convert DynUSDC (shares) back to USDC (assets)
        uint256 _usdcAmount =
            vault.redeem({ shares: _user.dynUSDCBalance, receiver: address(this), owner: address(this) });

        // Update user info to storage
        _user.dynUSDCBalance = 0;
        _user.usdcBalance += _usdcAmount;
        _user.optStatus = TEscrow.OptStatus.OptOut;
        userInfo[_msgSender()] = _user;

        // Emit opt-out event
        emit OptOut(_msgSender(), _user.dynUSDCBalance, _usdcAmount);
    }

    /*//////////////////////////////////////////////////////////////
                   ONLY-ADMIN NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Sets a new vault address.
    /// @dev Can only be called by the admin.
    /// @dev Reverts if the new vault address is zero address.
    /// @dev Emits a `VaultUpdated` event.
    /// @param newVaultAddress The address of the new vault.
    function setVault(address newVaultAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        // Check: Ensure the new vault address is not zero
        newVaultAddress.checkAddressZero();

        // Emit vault update event
        emit VaultUpdated(address(vault), newVaultAddress);

        // Update the vault address
        vault = IERC4626(newVaultAddress);
    }
}
