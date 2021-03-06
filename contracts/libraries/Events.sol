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

    event ProfileCreated(
        uint256 indexed profileId,
        address indexed creator,
        address indexed to,
        string handle,
        string metadataURI,
        bytes encodedMetadata,
        bytes backModuleReturnData,
        uint256 timestamp
    );
    event DefaultProfileSet(address indexed account, uint256 indexed profileId, uint256 timestamp);

    // Projects
    event ProjectCreated(
        uint256 indexed profileId,
        uint256 indexed projectId,
        address indexed creator,
        string handle,
        string metadataURI,
        bytes encodedMetadata,
        bytes investModuleReturnData,
        uint256 timestamp
    );

    // Back Profiles
    event BackModuleWhitelisted(
        address indexed module,
        bool indexed whitelisted,
        uint256 timestamp
    );
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
        uint256 indexed profileId,
        address indexed profileOwner,
        bytes moduleData,
        uint256 value,
        address[] erc20s,
        uint256[] amounts,
        uint256 backNftTokenId,
        address backNft,
        uint256 timestamp
    );

    // Invest in Projects
    event InvestModuleWhitelisted(
        address indexed module,
        bool indexed whitelisted,
        uint256 timestamp
    );
    event InvestNFTInitialized(uint256 indexed profileId, uint256 indexed pubId, uint256 timestamp);
    event InvestNFTDeployed(
        uint256 indexed profileId,
        uint256 indexed projectId,
        address indexed investNFT,
        uint256 timestamp
    );
    event Invested(
        address indexed investor,
        uint256 indexed profileId,
        uint256 indexed projectId,
        address profileOwner,
        bytes moduleData,
        uint256 value,
        address[] erc20s,
        uint256[] amounts,
        uint256 investNftTokenId,
        uint256 timestamp
    );
    // address investNft,
    event InvestNFTTransferred(
        uint256 indexed profileId,
        uint256 indexed projectId,
        uint256 indexed nftId,
        address from,
        address to,
        uint256 timestamp
    );

    // ERC 20s
    event ERC20Whitelisted(address indexed erc20, bool indexed whitelisted, uint256 timestamp);

    // Yield trusts
    event YieldTrustCreated(
        uint256 indexed profileId,
        address indexed erc20,
        address indexed recipient,
        address vault,
        address creator,
        uint256 timestamp
    );
    event YieldSourceVaultDeployed(
        uint256 indexed profileId,
        address indexed currency,
        address vault,
        address aToken,
        uint256 timestamp
    );
    event YieldTrustDeposited(
        uint256 indexed profileId,
        address indexed asset,
        uint256 amount,
        address indexed receiver,
        address vault,
        uint256 timestamp
    );

    // Modules
    event ModuleBaseConstructed(address hub, uint256 timestamp);
}
