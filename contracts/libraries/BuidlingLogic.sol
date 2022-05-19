// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {DataTypes} from "./DataTypes.sol";
import {Errors} from "./Errors.sol";
import {Events} from "./Events.sol";
import {Constants} from "./Constants.sol";
import {IBackModule} from "../interfaces/IBackModule.sol";
import {IInvestModule} from "../interfaces/IInvestModule.sol";
import {IBuidlHub} from "../interfaces/IBuidlHub.sol";

/**
 * @notice Library containing logic for profile and project creation.
 */
library BuidlingLogic {
    function createProfile(
        DataTypes.CreateProfileData calldata vars,
        uint256 profileId,
        mapping(bytes32 => uint256) storage _profileIdByHandleHash,
        mapping(uint256 => DataTypes.ProfileStruct) storage _profileById,
        mapping(address => bool) storage _backModuleWhitelisted
    ) external {
        _validateHandle(vars.handle);

        bytes32 handleHash = keccak256(bytes(vars.handle));

        if (_profileIdByHandleHash[handleHash] != 0) revert Errors.HandleTaken();
        _profileIdByHandleHash[handleHash] = profileId;

        _profileById[profileId].handle = vars.handle;
        _profileById[profileId].metadataURI = vars.metadataURI;

        bytes memory backModuleReturnData;
        if (vars.backModule != address(0)) {
            _profileById[profileId].backModule = vars.backModule;
            backModuleReturnData = _initBackModule(
                profileId,
                vars.backModule,
                vars.backModuleInitData,
                _backModuleWhitelisted
            );
        }

        emit Events.ProfileCreated(
            profileId,
            msg.sender,
            vars.to,
            vars.handle,
            vars.metadataURI,
            abi.encode(vars.profileType, vars.backModule),
            backModuleReturnData,
            block.timestamp
        );
    }

    /**
     * @notice Set back module for a profile.
     */
    function setBackModule(
        uint256 profileId,
        address module,
        bytes calldata moduleInitData,
        DataTypes.ProfileStruct storage _profile,
        mapping(address => bool) storage _backModuleWhitelisted
    ) external {
        if (module != _profile.backModule) {
            _profile.backModule = module;
        }

        bytes memory moduleReturnData;
        if (module != address(0)) {
            if (!_backModuleWhitelisted[module]) revert Errors.BackModuleNotWhitelisted();
            moduleReturnData = IBackModule(module).initializeModule(profileId, moduleInitData);
            emit Events.BackModuleSet(profileId, module, moduleReturnData, block.timestamp);
        }
    }

    function createProject(
        DataTypes.CreateProjectData calldata vars,
        uint256 projectId,
        mapping(bytes32 => uint256[2]) storage _profileProjectIdsByProjectHandleHash,
        mapping(uint256 => mapping(uint256 => DataTypes.ProjectStruct))
            storage _projectByIdByProfile,
        mapping(address => bool) storage _investModuleWhitelisted
    ) external {
        _validateHandle(vars.handle);

        bytes32 handleHash = keccak256(bytes(vars.handle));

        if (
            keccak256(abi.encodePacked(_profileProjectIdsByProjectHandleHash[handleHash])) !=
            keccak256(abi.encodePacked([0, 0]))
        ) revert Errors.HandleTaken();
        _profileProjectIdsByProjectHandleHash[handleHash] = [vars.profileId, projectId];

        _projectByIdByProfile[vars.profileId][projectId].metadataURI = vars.metadataURI;
        _projectByIdByProfile[vars.profileId][projectId].handle = vars.handle;

        // invest module init
        bytes memory investModuleReturnData = _initInvestModule(
            vars.profileId,
            projectId,
            vars.investModule,
            vars.investModuleInitData,
            _projectByIdByProfile,
            _investModuleWhitelisted
        );

        _emitProjectCreated(
            vars.profileId,
            projectId,
            vars.handle,
            vars.metadataURI,
            abi.encode(vars.projectType, vars.projectState, vars.projectSize),
            investModuleReturnData
        );
    }

    function _initBackModule(
        uint256 profileId,
        address backModule,
        bytes memory backModuleInitData,
        mapping(address => bool) storage _backModuleWhitelisted
    ) private returns (bytes memory) {
        if (!_backModuleWhitelisted[backModule]) revert Errors.BackModuleNotWhitelisted();
        return IBackModule(backModule).initializeModule(profileId, backModuleInitData);
    }

    function _initInvestModule(
        uint256 profileId,
        uint256 projectId,
        address investModule,
        bytes memory investModuleInitData,
        mapping(uint256 => mapping(uint256 => DataTypes.ProjectStruct))
            storage _projectByIdByProfile,
        mapping(address => bool) storage _investModuleWhitelisted
    ) private returns (bytes memory) {
        if (investModule == address(0)) return new bytes(0);
        if (!_investModuleWhitelisted[investModule]) revert Errors.InvestModuleNotWhitelisted();
        _projectByIdByProfile[profileId][projectId].investModule = investModule;
        return
            IInvestModule(investModule).initializeModule(
                profileId,
                projectId,
                investModuleInitData
            );
    }

    function _emitProjectCreated(
        uint256 profileId,
        uint256 projectId,
        string memory handle,
        string memory metadataURI,
        bytes memory encodedMetadata,
        bytes memory investModuleReturnData
    ) internal {
        emit Events.ProjectCreated(
            profileId,
            projectId,
            IBuidlHub(address(this)).ownerOf(profileId),
            handle,
            metadataURI,
            encodedMetadata,
            investModuleReturnData,
            block.timestamp
        );
    }

    function _validateHandle(string calldata handle) private pure {
        bytes memory byteHandle = bytes(handle);
        if (byteHandle.length == 0 || byteHandle.length > Constants.MAX_HANDLE_LENGTH)
            revert Errors.HandleLengthInvalid();

        uint256 byteHandleLength = byteHandle.length;
        for (uint256 i = 0; i < byteHandleLength; ) {
            if (
                (byteHandle[i] < "0" ||
                    byteHandle[i] > "z" ||
                    (byteHandle[i] > "9" && byteHandle[i] < "a")) &&
                byteHandle[i] != "." &&
                byteHandle[i] != "-" &&
                byteHandle[i] != "_"
            ) revert Errors.HandleContainsInvalidCharacters();
            unchecked {
                ++i;
            }
        }
    }
}
