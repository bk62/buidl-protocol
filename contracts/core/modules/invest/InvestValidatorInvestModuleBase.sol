// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {IInvestModule} from "../../../interfaces/IInvestModule.sol";
import {IBuidlHub} from "../../../interfaces/IBuidlHub.sol";
import {Errors} from "../../../libraries/Errors.sol";
import {ModuleBase} from "../ModuleBase.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @notice Adds a default method to check if user is a current investor from a module.
 */
abstract contract InvestValidatorInvestModuleBase is ModuleBase, IInvestModule {
    /**
     * @notice Check NFT ownership
     */
    function isInvestor(
        uint256 profileId,
        uint256 projectId,
        address investor,
        uint256 investNFTTokenId
    ) external view override returns (bool) {
        address investNFT = IBuidlHub(hub).getInvestNFT(profileId, projectId);
        if (investNFT == address(0)) {
            return false;
        } else {
            return
                investNFTTokenId == 0
                    ? IERC721(investNFT).balanceOf(investor) != 0
                    : IERC721(investNFT).ownerOf(investNFTTokenId) == investor;
        }
    }
}
