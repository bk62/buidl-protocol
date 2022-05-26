// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockaToken is ERC20("MockaToken", "aToken") {
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
