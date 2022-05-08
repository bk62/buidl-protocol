// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {DataTypes} from "./DataTypes.sol";
import {Errors} from "./Errors.sol";
import {Events} from "./Events.sol";
import {Constants} from "./Constants.sol";
import {IBackNFT} from "../interfaces/IBackNFT.sol";
import {IBackModule} from "../interfaces/IBackModule.sol";
import {BackNFT} from "../core/BackNFT.sol";
import {IInvestNFT} from "../interfaces/IInvestNFT.sol";
import {IInvestModule} from "../interfaces/IInvestModule.sol";
import {InvestNFT} from "../core/InvestNFT.sol";

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title FundingLogic
 *
 * @notice
 */
library FundingLogic {
    using Strings for uint256;

    /**
     * @notice Back profiles.
     */
    function back(
        address backer,
        uint256 profileId,
        bytes calldata moduleData,
        address backNFTImpl,
        mapping(uint256 => DataTypes.ProfileStruct) storage _profileById,
        mapping(bytes32 => uint256) storage _profileIdByHandleHash
    ) external returns (uint256) {
        string memory handle = _profileById[profileId].handle;
        if (_profileIdByHandleHash[keccak256(bytes(handle))] != profileId)
            revert Errors.TokenDoesNotExist();

        address backModule = _profileById[profileId].backModule;
        address backNFT = _profileById[profileId].backNFT;

        if (backNFT == address(0)) {
            backNFT = _deployBackNFT(profileId, handle, backNFTImpl);
            _profileById[profileId].backNFT = backNFT;
        }

        uint256 tokenId = IBackNFT(backNFT).mint(backer);

        if (backModule != address(0)) {
            IBackModule(backModule).process(backer, profileId, moduleData);
        }

        emit Events.Backed(backer, profileId, moduleData, block.timestamp);
        return tokenId;
    }

    /**
     * @notice Invest in projects
     */
    function invest(
        address investor,
        uint256 profileId,
        uint256 projectId,
        bytes calldata moduleData,
        address investNFTImpl,
        mapping(uint256 => DataTypes.ProfileStruct) storage _profileById,
        mapping(uint256 => mapping(uint256 => DataTypes.ProjectStruct))
            storage _projectByIdByProfile
    ) external returns (uint256) {
        // TODO
        // getPointerIfDerivativeProject

        uint256 tokenId;
        // Avoid stack too deep
        {
            address investNFT = _projectByIdByProfile[profileId][projectId].investNFT;
            if (investNFT == address(0)) {
                investNFT = _deployInvestNFT(
                    profileId,
                    projectId,
                    _profileById[profileId].handle,
                    investNFTImpl
                );
                tokenId = IInvestNFT(investNFT).mint(investor);
            }
        }

        IInvestModule(_projectByIdByProfile[profileId][projectId].investModule).process(
            investor,
            profileId,
            projectId,
            moduleData
        );

        _emitInvestedEvent(investor, profileId, projectId, moduleData);

        return tokenId;
    }

    function _deployBackNFT(
        uint256 profileId,
        string memory handle,
        address backNFTImpl
    ) private returns (address) {
        address backNFT = Clones.clone(backNFTImpl);

        bytes4 firstBytes = bytes4(bytes(handle));
        IBackNFT(backNFT).initialize(
            profileId,
            string(abi.encodePacked(handle, Constants.BACK_NFT_NAME_SUFFIX)),
            string(abi.encodePacked(firstBytes, Constants.BACK_NFT_SYMBOL_SUFFIX))
        );

        emit Events.BackNFTDeployed(profileId, backNFT, block.timestamp);

        return backNFT;
    }

    function _deployInvestNFT(
        uint256 profileId,
        uint256 projectId,
        string memory handle,
        address investNFTImpl
    ) private returns (address) {
        address investNFT = Clones.clone(investNFTImpl);

        bytes4 firstBytes = bytes4(bytes(handle));

        string memory name = string(
            abi.encodePacked(handle, Constants.INVEST_NFT_NAME_INFIX, projectId.toString())
        );
        // TODO use proejct handles
        string memory symbol = string(
            abi.encodePacked(firstBytes, Constants.INVEST_NFT_SYMBOL_INFIX, projectId.toString())
        );

        IInvestNFT(investNFT).initialize(profileId, projectId, name, symbol);
        emit Events.InvestNFTDeployed(profileId, projectId, investNFT, block.timestamp);

        return investNFT;
    }

    function _emitInvestedEvent(
        address investor,
        uint256 profileId,
        uint256 projectId,
        bytes calldata moduleData
    ) private {
        emit Events.Invested(investor, profileId, projectId, moduleData, block.timestamp);
    }
}
