// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

// interfaces
import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// libraries
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Errors } from "./libraries/Errors.sol";

// types
import { TEscrow } from "./types/TEscrow.sol";

// contracts
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract Escrow is Ownable {
    using SafeERC20 for IERC20;

    /// @notice USDC token address
    IERC20 public immutable usdc;

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

    /// @notice Event emitted when a user withdraws their yield.
    event YieldWithdrawn(address indexed user, uint256 yieldAmount);

    /// @notice Event emitted when a user withdraws USDC.
    event Withdraw(address indexed user, uint256 amount);

    constructor(address owner_, IERC20 usdc_, IERC4626 _vault_) Ownable(owner_) {
        usdc = usdc_;
        vault = _vault_;
    }

    // Allows user to participate in the project and interact with `ProjectAllocationManager` contract
    // TODO: implementation
    function participate() external { }

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
    function withdraw(uint256 usdcAmount) external {
        TEscrow.UserInfo memory _user = userInfo[_msgSender()];

        // If the user has participated to the project, they cannot withdraw their USDC
        // TODO: send a call to the `ProjectAllocationManager` contract to check if the project has started the sale
        // then the user cannot withdraw
        if (_user.hasParticipated) revert Errors.LaunchpadV3_Escrow_UserCannotWithdraw();

        // If user is opted in, convert DynUSDC to USDC
        if (_user.optStatus == TEscrow.OptStatus.OptIn) {
            if (_user.dynUSDCBalance == 0) revert Errors.LaunchpadV3_Escrow_InsufficientDynUSDCBalance();

            // Redeem DynUSDC from the vault and convert back to USDC
            usdcAmount = vault.withdraw(usdcAmount, address(this), address(this));
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
    function optIn() external {
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
    function optOut() external {
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
