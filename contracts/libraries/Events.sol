// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {DataTypes} from "./DataTypes.sol";

library Events {
    event StateSet(
        address indexed caller,
        DataTypes.ProtocolState indexed prevState,
        DataTypes.ProtocolState indexed newState,
        uint256 timestamp
    );
    event GovernanceSet(
        address indexed caller,
        address indexed prevGov,
        address indexed newGov,
        uint256 timestamp
    );
    event ProfileCreatorWhitelisted(
        address indexed profileCreator,
        bool indexed whitelisted,
        uint256 timestamp
    );
    event BackModuleWhitelisted(
        address indexed module,
        bool indexed whitelisted,
        uint256 timestamp
    );
    event InvestModuleWhitelisted(
        address indexed module,
        bool indexed whitelisted,
        uint256 timestamp
    );
    event ProfileCreated(
        uint256 indexed profileId,
        address indexed creator,
        address indexed to,
        string handle,
        string profileMetadataURI,
        uint256 timestamp
    );
    event DefaultProfileSet(address indexed account, uint256 indexed profileId, uint256 timestamp);
    event ProjectCreated(
        uint256 indexed profileId,
        uint256 indexed projectId,
        string projectMetadataURI,
        uint256 timestamp
    );

    // Back Profiles
    event BackNFTInitialized(uint256 indexed profileId, uint256 timestamp);
    event BackModuleSet(
        uint256 indexed profileId,
        address module,
        bytes moduleReturnData,
        uint256 timestamp
    );
    event BackNFTDeployed(uint256 indexed profileId, address indexed BackNFT, uint256 timestamp);
    event Backed(
        address indexed backer,
        uint256[] profileIds,
        bytes[] moduleDatas,
        uint256 timestamp
    );

    // Invest Projects
    event InvestNFTInitialized(uint256 indexed profileId, uint256 indexed pubId, uint256 timestamp);
    event InvestNFTDeployed(
        uint256 indexed profileId,
        uint256 indexed projectId,
        address indexed sponsorNFT,
        uint256 timestamp
    );
    event Invested(
        address indexed sponsor,
        uint256 indexed profileId,
        uint256 indexed projectId,
        uint256 rootProfileId,
        uint256 rootProjectId,
        bytes sponsorModuleData,
        uint256 timestamp
    );
    event InvestNFTTransferred(
        uint256 indexed profileId,
        uint256 indexed projectId,
        uint256 indexed nftId,
        address from,
        address to,
        uint256 timestamp
    );
}
