// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

// interfaces
import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// libraries
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { Errors } from "./libraries/Errors.sol";
import { AddressLibrary } from "./libraries/AddressLibrary.sol";

// types
import { TEscrow } from "./types/TEscrow.sol";

// abstract contracts
import { Clonable } from "./utilities/Clonable.sol";

// TODO: implement IEscrow
contract Escrow is Clonable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using AddressLibrary for address;

    /// @notice USDC token address
    IERC20 public usdc;

    /// @notice Dynavault address
    IERC4626 public vault;

    /// @notice Mapping to track the balances and statuses of each user in the Escrow contract.
    /// @dev Maps each user address to their corresponding `UserInfo` struct.
    mapping(address => TEscrow.UserInfo) public userInfo;

    /// @notice Event emitted when a user deposits USDC.
    event Deposit(address indexed user, uint256 amount);

    /// @notice Event emitted when a user opts in to Dynavault.
    event OptIn(address indexed user, uint256 usdcAmount, uint256 dynUSDCAmount);

    /// @notice Event emitted when a user opts out of Dynavault.
    event OptOut(address indexed user, uint256 dynUSDCAmount, uint256 usdcAmount);

    /// @notice Event emitted when a user withdraws USDC.
    event Withdraw(address indexed user, uint256 amount);

    function initializer(IERC20 usdcAddress, IERC4626 vaultAddress) external {
        // Check: Ensure the contract is not already initialized
        if (!address(usdc).isAddressZero() || !address(vault).isAddressZero()) {
            revert Errors.LaunchpadV3_EscrowAlreadyInitialized();
        }

        // Check: Ensure the USDC and Dynavault addresses are not zero
        address(usdcAddress).checkAddressZero();
        address(vaultAddress).checkAddressZero();

        usdc = usdcAddress;
        vault = vaultAddress;
    }

    /// @notice Allows users to add USDC into the escrow contract.
    /// @param amount The amount of USDC to deposit.
    function deposit(uint256 amount) external {
        if (amount == 0) revert Errors.LaunchpadV3_Escrow_InvalidAmount();

        // Transfer USDC from user to this contract
        usdc.safeTransferFrom(_msgSender(), address(this), amount);

        // Update user's USDC balance in the escrow contract
        userInfo[_msgSender()].usdcBalance += amount;

        // Emit deposit event
        emit Deposit(_msgSender(), amount);
    }

    /// @notice Allows users to withdraw their USDC (including yield) from the escrow contract.
    /// @dev If the user is opted in, their DynUSDC will be converted back to USDC.
    function withdraw(uint256 usdcAmount) external nonReentrant {
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

    /// @notice Allows users to opt-in to Dynavault and convert their USDC to DynUSDC.
    function optIn() external nonReentrant {
        TEscrow.UserInfo memory _user = userInfo[_msgSender()];

        // Check: Ensure the user has USDC to convert
        if (_user.usdcBalance == 0) revert Errors.LaunchpadV3_Escrow_InsufficientUSDCBalance();

        // Check: If the user is already opted-in
        if (_user.optStatus == TEscrow.OptStatus.OptIn) revert Errors.LaunchpadV3_UserAlreadyOptedIn();

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

    /// @notice Allows users to opt out of Dynavault and convert DynUSDC back to USDC.
    function optOut() external nonReentrant {
        TEscrow.UserInfo memory _user = userInfo[_msgSender()];

        // Check: Ensure the user is opted in
        if (_user.optStatus != TEscrow.OptStatus.OptIn) revert Errors.LaunchpadV3_UserNotOptedIn();

        // Check: Ensure the user has DynUSDC to convert back to USDC
        if (_user.dynUSDCBalance == 0) revert Errors.LaunchpadV3_Escrow_InsufficientDynUSDCBalance();

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
}
