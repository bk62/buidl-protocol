// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {IInvestModule} from "../../../interfaces/IInvestModule.sol";
import {ModuleBase} from "../ModuleBase.sol";
import {BackValidationModuleBase} from "../BackValidationModuleBase.sol";
import {InvestValidatorInvestModuleBase} from "./InvestValidatorInvestModuleBase.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @notice Invest module that only allows backers of the profile that owns the project
 * to invest.
 */
contract BackerOnlyInvestModule is
    BackValidationModuleBase,
    IInvestModule,
    InvestValidatorInvestModuleBase
{
    constructor(address hub) ModuleBase(hub) {}

    function initializeModule(
        uint256 profileId,
        uint256 projectId,
        bytes calldata data
    ) external pure override returns (bytes memory) {
        return new bytes(0);
    }

    function process(
        address investor,
        uint256 profileId,
        uint256 projectId,
        bytes calldata data
    ) external override {
        // revert unless investor is a current backer of the profile or profile owner
        _checkBackValidity(profileId, investor);
    }

    function moduleNFTTransferHook(
        uint256 profileId,
        uint256 projectId,
        address from,
        address to,
        uint256 nftTokenId
    ) external override {}
}
