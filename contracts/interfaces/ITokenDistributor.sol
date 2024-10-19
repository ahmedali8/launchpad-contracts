// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

// types
import { TTokenDistributor } from "../types/TTokenDistributor.sol";

/// @title ITokenDistributor
/// @notice Interface for the TokenDistributor contract.
/// @dev This contract manages token distributions for the project on the destination chain.
interface ITokenDistributor {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Event emitted when the project information is initialized.
    /// @param projectInfo The project information details.
    event Initialized(TTokenDistributor.ProjectInfo projectInfo);

    /// @notice Event emitted when tokens are claimed by a user.
    /// @dev This will be called in the `_lzReceive` function of layerzero inheritance.
    /// @param user The address of the user who claimed tokens.
    /// @param amount The amount of tokens claimed by the user.
    /// @param guid The global unique identifier for the claim from layerzero.
    event TokensClaimed(address indexed user, uint256 amount, bytes32 guid);

    /// @notice Event emitted when a user requests a resolution to revert the state in the source chain.
    /// @param user The address of the user requesting the claim resolution.
    /// @param amount The amount of tokens requested.
    /// @param guid The global unique identifier for the claim from layerzero.
    event ResolveRequested(address indexed user, uint256 amount, bytes32 guid);

    /*//////////////////////////////////////////////////////////////
                   NON-CONSTANT ONLY-ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Initializes the project information for the token distribution.
    /// @dev Only the admin can call this function.
    /// @param projectInfo The struct containing the initial project details.
    function initializer(TTokenDistributor.ProjectInfo calldata projectInfo) external;
}
