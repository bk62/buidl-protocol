// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {IBackModule} from "../../../interfaces/IBackModule.sol";
import {IBuidlHub} from "../../../interfaces/IBuidlHub.sol";
import {Errors} from "../../../libraries/Errors.sol";
import {ModuleBase} from "../ModuleBase.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @notice Adds a default method to check if user is a current backer from a module.
 */
abstract contract BackValidatorBackModuleBase is ModuleBase, IBackModule {
    /**
     * @notice Check NFT ownership
     */
    function isBacker(
        uint256 profileId,
        address backer,
        uint256 backNFTTokenId
    ) external view override returns (bool) {
        address backNFT = IBuidlHub(hub).getBackNFT(profileId);
        if (backNFT == address(0)) {
            return false;
        } else {
            return
                backNFTTokenId == 0
                    ? IERC721(backNFT).balanceOf(backer) != 0
                    : IERC721(backNFT).ownerOf(backNFTTokenId) == backer;
        }
    }
}
