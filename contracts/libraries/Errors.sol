// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

library Errors {
    error HandleTaken();
    error HandleLengthInvalid();
    error HandleContainsInvalidCharacters();
    error ProfileImageURILengthInvalid();

    error ProfileCreatorNotWhitelisted();
    error BackModuleNotWhitelisted();

    error NotGovernance();
    error NotProfileOwner();

    error Paused();
    error BuidlingPaused();
    error FundingPaused();
    error DAOFactoryPaused();

    error ConstructorParamsInvalid();
    error Initialized();
    error NotHub();
    error TokenDoesNotExist();

    error ArrayMismatch();

    error FundTransferFailed();

    error ProfileNotFound();
}
