// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {IERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {SafeERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {Errors} from "../../libraries/Errors.sol";
import {Events} from "../../libraries/Events.sol";
import {IBuidlHub} from "../../interfaces/IBuidlHub.sol";
import {IBackModule} from "../../interfaces/IBackModule.sol";
import {ModuleBase} from "./ModuleBase.sol";

import {ERC20ICO} from "./ERC20ICO.sol";

abstract contract ERCICOModuleBase is Context, ModuleBase {
    using SafeERC20Upgradeable for ERC20Upgradeable;

    address immutable _erc20Impl;

    constructor(address hub, address erc20Impl) ModuleBase(hub) {
        if (erc20Impl == address(0)) revert Errors.ConstructorParamsInvalid();
        _erc20Impl = erc20Impl;
    }

    function _deployErc20(
        address admin,
        string memory name,
        string memory symbol
    ) internal returns (ERC20ICO) {
        address erc20Addr = Clones.clone(_erc20Impl);
        ERC20ICO erc20 = ERC20ICO(erc20Addr);
        erc20.initialize(address(this), admin, name, symbol);
        // emit Events.ModuleERC20Deployed(erc20, name, symbol);
        return erc20;
    }

    function _mint(
        ERC20ICO erc20,
        address to,
        uint256 amount
    ) internal {
        erc20.mint(to, amount);
    }

    function _getLatestPrice(address priceFeedAddr) internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddr);
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return uint256(price);
    }
}
