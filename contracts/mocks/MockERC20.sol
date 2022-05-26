// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMockERC20Mintable is IERC20 {
    function mint(address to, uint256 amount) external;
}

contract MockERC20 is ERC20("MockERC20", "MERC20") {
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
