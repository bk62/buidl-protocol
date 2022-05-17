// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

/**
 * @title DataTypes
 * @notice Common data types -- structs and enums
 */
library DataTypes {
    /**
     * @notice Protocol state enum
     */
    enum ProtocolState {
        Paused,
        Unpaused,
        BuidlingPaused,
        FundingPaused,
        DAOFactoryPaused
    }

    /**
     * @notice Profile type enum
     */
    enum ProfileType {
        Individual,
        Team,
        Startup,
        NonProfit,
        ProtoDAO,
        DAO,
        Anonymous,
        MadScientist,
        SatanicCult,
        Balaji
    }

    /**
     * @notice Project size enum
     */
    enum ProjectSize {
        Tiny,
        Small,
        Medium,
        Large,
        GoogleKiller,
        LandOnMars,
        DeathStar
    }

    /**
     * @notice Project type enum
     */
    enum ProjectType {
        // Software
        Tool,
        Toy,
        Prototype,
        Buidl,
        // Art
        Art,
        NFT,
        Music,
        // Greater good
        PublicGood,
        Utopian,
        // Greater evil
        WorldDomination,
        // Start something
        ProtoDAO,
        Startup,
        NonProfit
    }

    /**
     * @notice Project state enum
     */
    enum ProjectState {
        HalfBaked,
        Brainstorm,
        Planning,
        Design,
        Development,
        Testing,
        Launch,
        Operations,
        Growth,
        Success,
        ProtoDAO,
        DAO,
        Terminal,
        Closed
    }

    enum ProjectDAOFactoryState {
        None,
        ProtoDAO,
        DAO,
        Launched
    }

    enum ProjectDAOFactoryGovernanceType {
        Individual,
        MultiSig,
        TokenVoting,
        NFTVoting,
        // Experimental
        Dictatorship,
        Monarchy,
        Oligarchy,
        Corporate,
        Bicameral
    }

    struct DAOFactoryDetails {
        ProjectDAOFactoryState daoFactoryState;
        ProjectDAOFactoryGovernanceType governanceType;
    }

    /**
     * @notice Fund greed level aka profit type enum
     */
    enum FundGreedLevel {
        Grant, // Simple fund grants -- contribute without any expectations of anything in return
        Buidl, // Fund grants meant to incentivize #buidl projects in your ecosystem
        VentureFund // Invest for profit - Greed is good!
    }

    /**
     * @notice Fund vault type
     */
    enum FundVaultType {
        TrustVault, // EIP-4626 compatible yield vaults that disburse yields -- no loss!
        PTPodVault, // EIP-4626 compatible PoolTogether vaults that disburse awarded prize payouts from PT -- no loss!
        VentureVault // EIP-4626 compatible yield vaults that invest in projects collectively -- yes, loss! tremendously risky!
    }

    /**
     * @notice Fund Type
     */
    struct FundType {
        FundGreedLevel greedLevel;
        FundVaultType vaultType;
    }

    /**
     * @notice Profile data struct
     *
     * @param profileType Type of profile e.g. individual, team or DAO
     * @param handle Unique (to profiles) handle
     * @param projectCount Number of projects created
     * @param fundCount Number of funds created
     * @param metadataURI ERC-712 Metadata URI - IPFS
     * @param backModule Back module used when someone backs this profile -- nullable
     * @param backNFT NFT contract that issues NFTs to backers -- nullable
     * @param endorsedByModule Module used when this profile endorses someone
     * @param endorsedByNFT NFTs issued when this profile endorses someone
     * @param reputationScore Reputation score for this profile
     */
    struct ProfileStruct {
        ProfileType profileType;
        string handle;
        uint256 projectCount;
        // uint256 fundCount;
        string metadataURI;
        // Actions:
        // Module/NFT for when someone backs this profile:
        address backModule;
        address backNFT;
        // Module/NFT when this profile endorses someone:
        // Opposite of back -- the endorsed profile gets the endorsement NFT
        // address endorsedByModule;
        // address endorsedByNFT;
        // TODO struct with subscores
        // store history
        // uint256 reputationScore;
    }

    /**
     * @notice Project data struct
     *
     * @param profilePointed Profile this project points to
     * @param projectIdPointer Project this project points to
     * @param handle  Unique (to projects) handle
     * @param metadataURI ERC-712 Metadata URI - IPFS
     * @param projectSize Indication of how large, time-consuming or ambitious this project is
     * @param projectType Type of project e.g. a simple command-line tool, an effort at a public good
     * @param investModule Module used when someone invests in this project
     * @param investNFT NFTs issued when someone invests in this project
     * @param investToken ERC-20s issued when someone invests in this project - nullable
     * @param governanceModule Governance module - nullable i.e. project owner governs
     */
    struct ProjectStruct {
        uint256 profilePointed;
        uint256 projectIdPointer;
        string handle;
        string metadataURI;
        ProjectSize projectSize;
        ProjectType projectType;
        ProjectState projectState;
        // Invest in a project
        address investModule;
        address investNFT;
        address investToken;
        address governanceModule;
        DAOFactoryDetails daoFactoryDetails;
    }

    /**
     * @notice A struct containing venture fund data
     *
     * @param handle  Unique (to projects) handle
     * @param metadataURI ERC-712 Metadata URI - IPFS
     * @param grantType Type of grant
     * @param applyModule Module used when someone applies to this grant
     * @param applyNFT NFTs issued when someone applies to this grant
     * @param investedByModule Module used when this fund invests in someone
     * @param investedByNFT NFT issued when this fund invests in someone
     */
    struct FundStruct {
        string handle;
        string metadataURI;
        FundGreedLevel fundGreedLevel;
        FundVaultType fundVaultType;
        // Apply for a grant/investment via a project
        address applyModule;
        address applyNFT;
        // Invest in this fund
        address investInModule;
        address investInNFT;
        address investInToken;
        // Got invest from
        address investmentFromModule;
        address investmentFromNFT;
        // TODO
        // investment details struct
        // amount, timestamp
    }

    struct CreateProfileData {
        address to;
        string handle;
        string metadataURI;
        ProfileType profileType;
        address backModule;
        bytes backModuleInitData;
        // address endorsedByModule;
        // bytes endorsedByModuleInitData;
    }

    struct CreateProjectData {
        uint256 profileId;
        string handle;
        string metadataURI;
        ProjectSize projectSize;
        ProjectType projectType;
        ProjectState projectState;
        address investModule;
        bytes investModuleInitData;
    }

    struct CreateFundData {
        uint256 profileId;
        string handle;
        string metadataURI;
        FundGreedLevel fundGreedLevel;
        FundVaultType fundVaultType;
        address applyModule;
        bytes applyModuleInitData;
        address investmentFromModule;
        bytes investmentFromModuleInitData;
    }
}
