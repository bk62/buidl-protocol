// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Events} from "../../libraries/Events.sol";
import {DataTypes} from "../../libraries/DataTypes.sol";
import {Errors} from "../../libraries/Errors.sol";

abstract contract MultiState {
    DataTypes.ProtocolState private _state;

    modifier whenNotPaused() {
        _validateNotPaused();
        _;
    }

    modifier whenBuidlingEnabled() {
        _validateBuidlingEnabled();
        _;
    }

    modifier whenFundingEnabled() {
        _validateFundingEnabled();
        _;
    }

    modifier whenDAOFactoryEnabled() {
        _validateDAOFactoryEnabled();
        _;
    }

    function getState() external view returns (DataTypes.ProtocolState) {
        return _state;
    }

    function _setState(DataTypes.ProtocolState newState) internal {
        DataTypes.ProtocolState prevState = _state;
        _state = newState;
        emit Events.StateSet(msg.sender, prevState, newState, block.timestamp);
    }

    function _validateNotPaused() internal view {
        if (_state == DataTypes.ProtocolState.Paused) revert Errors.Paused();
    }

    function _validateBuidlingEnabled() internal view {
        if (_state == DataTypes.ProtocolState.BuidlingPaused) {
            revert Errors.BuidlingPaused();
        }
    }

    function _validateFundingEnabled() internal view {
        if (_state == DataTypes.ProtocolState.FundingPaused) {
            revert Errors.FundingPaused();
        }
    }

    function _validateDAOFactoryEnabled() internal view {
        if (_state != DataTypes.ProtocolState.DAOFactoryPaused) {
            revert Errors.DAOFactoryPaused();
        }
    }
}
