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
import { TCommon } from "./types/TCommon.sol";

// abstract contracts
import { Clonable } from "./utilities/Clonable.sol";

import "hardhat/console.sol";

/// @title Escrow Contract
/// @dev A contract that allows users to deposit USDC and earn yield if opted-in to a yield-bearing vault.
contract Escrow is Clonable, ReentrancyGuard, IEscrow {
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC4626;
    using AddressLibrary for address;

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice USDC token address
    IERC20 public usdc;

    /// @notice Dynavault address
    IERC4626 public vault;

    /// @notice Address of the project allocation manager
    address public projectAllocationManager;

    /// @notice Mapping to track the balances and statuses of each user in the Escrow contract.
    /// @dev Maps each user address to their corresponding `UserInfo` struct.
    mapping(address => TEscrow.UserInfo) public userInfo;

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyPAM() {
        if (_msgSender() != projectAllocationManager) revert Errors.LaunchpadV3_Unauthorized();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                         NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IEscrow
    function deposit(uint256 amount, TCommon.OptStatus optStatus) external override nonReentrant {
        if (amount == 0) revert Errors.LaunchpadV3_Escrow_InvalidAmount();

        TEscrow.UserInfo storage _user = userInfo[_msgSender()];

        // Interaction: Transfer USDC from user to this contract
        usdc.safeTransferFrom(_msgSender(), address(this), amount);

        // if the user is opt-in then we deposit to vault
        if (optStatus == TCommon.OptStatus.OptIn) {
            // Interaction: Approve USDC to be spent by the vault
            usdc.approve(address(vault), amount);

            // Interaction: Deposit USDC into the vault and get DynUSDC (shares) for the user
            uint256 _dynUSDCAmount = vault.deposit({ assets: amount, receiver: address(this) });

            // Check: Ensure the user has received DynUSDC
            if (_dynUSDCAmount == 0) revert Errors.LaunchpadV3_Escrow_InsufficientDynUSDCAmountReceived();

            // Effect: Update user info
            _user.balance += _dynUSDCAmount;
        } else {
            // Effect: if the user is opt-out (default) then we deposit to escrow
            _user.balance += amount;
        }

        // Effect: Update user opt status
        _user.optStatus = TCommon.OptStatus.OptIn;

        // Emit deposit event
        emit Deposited(_msgSender(), amount, optStatus);
    }

    /// @inheritdoc IEscrow
    function withdraw() external override nonReentrant {
        TEscrow.UserInfo memory _user = userInfo[_msgSender()];

        if (_user.balance == 0) revert Errors.LaunchpadV3_Escrow_InsufficientBalance(_user.balance, _user.optStatus);

        // If user is opted-out (default), withdraw USDC directly
        uint256 _withdrawAmount = _user.balance;

        // If user is opted-in, convert DynUSDC to USDC
        if (_user.optStatus == TCommon.OptStatus.OptIn) {
            // Redeem DynUSDC from the vault and convert back to USDC
            _withdrawAmount = vault.redeem({ shares: _user.balance, receiver: address(this), owner: address(this) });
        }

        // Effect: delete the user
        delete userInfo[_msgSender()];

        // Interaction: Transfer USDC to user
        usdc.safeTransfer(_msgSender(), _withdrawAmount);

        // Emit withdrawal event
        emit Withdrawn(_msgSender(), _withdrawAmount);
    }

    /*//////////////////////////////////////////////////////////////
                   NON-CONSTANT ONLY-ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IEscrow
    function initializer(address usdcAddress, address vaultAddress, address pamAddress) external override {
        // Check: Ensure the contract is not already initialized
        if (!address(usdc).isAddressZero()) {
            revert Errors.LaunchpadV3_Escrow_AlreadyInitialized();
        }

        // Check: Ensure the USDC and Dynavault addresses are not zero
        usdcAddress.checkAddressZero();
        vaultAddress.checkAddressZero();

        usdc = IERC20(usdcAddress);
        vault = IERC4626(vaultAddress);
    }

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

    /*//////////////////////////////////////////////////////////////
                     NON-CONSTANT ONLY-PAM FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IEscrow
    function takeFundsFromUser(address user, uint256 amount) external override onlyPAM {
        TEscrow.UserInfo storage _user = userInfo[user];

        // Check: Balance must be sufficient
        if (_user.balance < amount) {
            revert Errors.LaunchpadV3_Escrow_InsufficientBalance(_user.balance, _user.optStatus);
        }

        // Effect: Update user state
        _user.balance -= amount;

        // Interaction: Send DynUSDC or USDC
        // If opt-in, send DynUSDC
        if (_user.optStatus == TCommon.OptStatus.OptIn) {
            vault.safeTransfer(_msgSender(), amount);
        } else {
            // If opt-out, send USDC
            usdc.safeTransfer(_msgSender(), amount);
        }

        emit FundsTaken(user, amount);
    }

    /// @inheritdoc IEscrow
    function refundFundsToUser(address user, uint256 amount) external override onlyPAM {
        TEscrow.UserInfo storage _user = userInfo[user];

        // Effect: Update user state
        _user.balance += amount;

        // Interaction: Send DynUSDC or USDC
        // If opt-in, take DynUSDC
        if (_user.optStatus == TCommon.OptStatus.OptIn) {
            vault.safeTransferFrom(projectAllocationManager, address(this), amount);
        } else {
            // If opt-out, take USDC
            usdc.safeTransferFrom(projectAllocationManager, address(this), amount);
        }

        emit FundsRefunded(user, amount);
    }
}
