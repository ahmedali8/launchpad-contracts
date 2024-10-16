// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import { IERC20, ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC4626 } from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract VaultMock is ERC4626 {
    constructor(address underlying) ERC20("VaultMock", "VaultM") ERC4626(IERC20(underlying)) { }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        _burn(account, amount);
    }
}
