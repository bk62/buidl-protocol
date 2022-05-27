// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

// import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20PresetMinterPauserUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/presets/ERC20PresetMinterPauserUpgradeable.sol";
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

import {Errors} from "../../libraries/Errors.sol";

contract ERC20ICO is ERC20PresetMinterPauserUpgradeable {
    address public immutable hub;
    // module that initialized this ERC20 token
    address public module;

    constructor(address hub_) {
        if (hub_ == address(0)) revert Errors.ConstructorParamsInvalid();
        hub = hub_;
    }

    modifier onlyModule() {
        if (msg.sender != module) revert Errors.NotAllowed();
        _;
    }

    function initialize(
        address module_,
        address admin,
        string memory name,
        string memory symbol
    ) public virtual initializer {
        if (module_ == address(0)) revert Errors.InitializerParamsInvalid();
        module = module_;

        // See `ERC20PresetMinterPauserUpgradeable.__ERC20PresetMinterPauser_init_unchained()`
        __ERC20_init_unchained(name, symbol);
        __Pausable_init_unchained();

        // caller is admin and pauser
        // module is minter
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(MINTER_ROLE, module);
        _setupRole(PAUSER_ROLE, admin);
    }
}
