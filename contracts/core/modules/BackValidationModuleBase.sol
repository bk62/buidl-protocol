// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {Errors} from "../../libraries/Errors.sol";
import {Events} from "../../libraries/Events.sol";
import {IBuidlHub} from "../../interfaces/IBuidlHub.sol";
import {IBackModule} from "../../interfaces/IBackModule.sol";
import {ModuleBase} from "./ModuleBase.sol";

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title Abstract contract that adds a method to check if an address has backed a given profile via module or NFT ownership.
 * Only meant for inhertiance by Invest modules.
 * E.g. See {BackersOnlyInvestModule}
 */

abstract contract BackValidationModuleBase is ModuleBase {
    /**
     * @notice Validate if a user is a backer of a given profile.
     * Reverts unless user is a profile backer or owner.
     *
     * @param profileId Profile id to check
     * @param user Address to check
     */
    function _checkBackValidity(uint256 profileId, address user) internal view {
        address backModule = IBuidlHub(hub).getBackModule(profileId);
        bool isBacking;
        if (backModule != address(0)) {
            isBacking = IBackModule(backModule).isBacker(profileId, user, 0);
        } else {
            address backNFT = IBuidlHub(hub).getBackNFT(profileId);
            isBacking = backNFT != address(0) && IERC721(backNFT).balanceOf(user) != 0;
        }
        if (!isBacking && IERC721(hub).ownerOf(profileId) != user) {
            revert Errors.NotAllowed();
        }
    }
}
