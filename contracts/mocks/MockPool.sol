// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IMockERC20Mintable} from "./MockERC20.sol";

interface IMockPool {
    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external;

    function simulateYield(address depositor, uint256 amount) external;
}

contract MockPool is IMockPool {
    IERC20 public _aToken;

    constructor(address aToken_) {
        _aToken = IERC20(aToken_);
    }

    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external override {
        IMockERC20Mintable(address(_aToken)).mint(onBehalfOf, amount);
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external override {
        IERC20 assetERC20 = IERC20(asset);
        require(assetERC20.balanceOf(address(this)) >= amount, "insufficient-balance");

        // give asset
        assetERC20.transferFrom(address(this), to, amount);
        // "burn" aToken
        IMockERC20Mintable(address(_aToken)).transferFrom(msg.sender, address(this), amount);
    }

    function simulateYield(address depositor, uint256 amount) external override {
        IMockERC20Mintable(address(_aToken)).mint(depositor, amount);
    }
}
