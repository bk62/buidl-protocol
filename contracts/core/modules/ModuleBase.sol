// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {Errors} from "../../libraries/Errors.sol";
import {Events} from "../../libraries/Events.sol";

/**
 * @title Base module
 */

abstract contract ModuleBase {
    address public immutable hub;

    modifier onlyHub() {
        if (msg.sender != hub) revert Errors.NotHub();
        _;
    }

    constructor(address hub_) {
        if (hub_ == address(0)) revert Errors.ConstructorParamsInvalid();
        hub = hub_;
        emit Events.ModuleBaseConstructed(hub_, block.timestamp);
    }
}
