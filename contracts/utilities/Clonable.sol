// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

/// @title a contract which implements EIP-1167 minimal proxy pattern and adds role based access control
/// @notice grants DEFAULT_ADMIN_ROLE when deploying the implementation contract and after cloning a new instance
abstract contract Clonable is AccessControl {
    /*//////////////////////////////////////////////////////////////
                            PRIVATE STORAGE
    //////////////////////////////////////////////////////////////*/

    bool private _initializedRoleBasedAccessControl;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Cloned(address newInstance);

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error Clonable_AlreadyInitializedRBAC();

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice marked the constructor function as payable, because it costs less gas to execute,
    /// since the compiler does not have to add extra checks to ensure that a payment wasn't provided.
    /// A constructor can safely be marked as payable, since only the deployer would be able to pass funds,
    /// and the project itself would not pass any funds.
    constructor() payable {
        setDefaultAdmin(msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                         NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice clones a new instance of this contract and grant default admin role to caller
    function getClone() external returns (address) {
        return clone(msg.sender);
    }

    /// @notice clones a new instance of this contract and grant default admin roler to given defaultAdmin
    function clone(address defaultAdmin) public returns (address newInstance) {
        // Copied from https://github.com/optionality/clone-factory/blob/master/contracts/CloneFactory.sol
        bytes20 addressBytes = bytes20(address(this));
        assembly {
            // EIP-1167 bytecode
            let clone_code := mload(0x40)
            mstore(clone_code, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone_code, 0x14), addressBytes)
            mstore(add(clone_code, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            newInstance := create(0, clone_code, 0x37)
        }
        emit Cloned(newInstance);
        Clonable(newInstance).setDefaultAdmin(defaultAdmin);
    }

    /// @dev initializes DEFAULT_ADMIN_ROLE (can be initialized only once)
    /// @notice this function does emit a RoleGranted event in AccessControl._grantRole
    function setDefaultAdmin(address initialAdmin) public {
        if (_initializedRoleBasedAccessControl) revert Clonable_AlreadyInitializedRBAC();
        _grantRole(DEFAULT_ADMIN_ROLE, initialAdmin);
        _initializedRoleBasedAccessControl = true;
    }
}
