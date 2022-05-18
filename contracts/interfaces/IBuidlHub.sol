// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {DataTypes} from "../libraries/DataTypes.sol";

/**
 * @title IBuidlHub
 *
 * @notice Interface for BuidlHub contract.
 */
interface IBuidlHub is IERC721 {
    /**
     * @notice Set governance address. Only callable by current governance address.
     *
     * @param newGovernance New governance address.
     */
    function setGovernance(address newGovernance) external;

    /**
     * @notice Set Protocol State.
     *
     * @param newState `ProtocolState` to transition to.
     */
    function setState(DataTypes.ProtocolState newState) external;

    /**
     * @notice Set whether a given profile creator address is whitelisted i.e. allowed to create profiles.
     *
     * @param profileCreator Address to whitelist or de-whitelist.
     * @param whitelist Bool indicating whether to whitelist the address.
     */
    function whitelistProfileCreator(address profileCreator, bool whitelist) external;

    /**
     * @notice Set whether a Back module is whitelisted.
     */
    function whitelistBackModule(address module, bool whitelist) external;

    /**
     * @notice Set whether an Invest module is whitelisted.
     */
    function whitelistInvestModule(address module, bool whitelist) external;

    /**
     * @notice Set whether an ERC-20 currency is whitelisted.
     */
    function whitelistERC20(address erc20, bool whitelist) external;

    /**
     * @notice Create a profile.
     *
     * @param vars `CreateProfileData` struct.
     */
    function createProfile(DataTypes.CreateProfileData calldata vars) external returns (uint256);

    /**
     * @notice Set the default profile for an address.
     */
    function setDefaultProfile(uint256 profileId) external;

    /**
     * @notice Set a profile's back module. Callable by profile owner only.
     */
    function setBackModule(
        uint256 profileId,
        address module,
        bytes calldata moduleInitData
    ) external;

    /**
     * @notice Create a project.
     *
     * @param vars `ProjectData` struct.
     */
    function createProject(DataTypes.CreateProjectData calldata vars) external returns (uint256);

    /**
     * @notice Create a Yield Trust ERC-4626 compatible vault
     *
     * @param trust `YieldTrustStruct` struct.
     */
    function createYieldTrust(DataTypes.YieldTrustStruct calldata trust) external;

    /**
     * TODO
     */
    // function setProfileMetadataURI(uint256 profileId, string calldata metadataURI) external;

    // function setBackNFTURI

    /**
     * Funding methods:
     * _________________
     */

    // Back a profile

    /**
     * @notice Back a profile with ERC 20s and/or native currency
     * @param profileId Token id of profile
     * @param backModuleData Data to pass to back module
     * @param erc20s Addresses of ERC-20s
     * @param amounts Amounts of ERC-20s, corresponding to the same position in the `erc20s` argument
     * @return uint256 Token id of issued back NFT
     */
    function back(
        uint256 profileId,
        bytes calldata backModuleData,
        address[] calldata erc20s,
        uint256[] calldata amounts
    ) external payable returns (uint256);

    /**
     * @notice Emit a Back NFT transfer event
     */
    // TODO
    // function emitBackNFTTransferEvent(
    //     uint256 profileId,
    //     uint256 followNFTId,
    //     address from,
    //     address to
    // ) external;

    // Invest in a project

    /**
     * @notice Invest in a project with ERC 20s and/or native currency
     * @param profileId Profile that created the project
     * @param projectId Project id
     * @param investModuleData Data to pass to invest module
     * @param erc20s Addresses of ERC-20s
     * @param amounts Amounts of ERC-20s, corresponding to the same position in the `erc20s` argument
     * @return uint256 Token if of issued invest NFT
     */
    function invest(
        uint256 profileId,
        uint256 projectId,
        bytes calldata investModuleData,
        address[] calldata erc20s,
        uint256[] calldata amounts
    ) external payable returns (uint256);

    /**
     * View methods:
     * ______________
     */

    /**
     * @notice Get whether a profile creator address is whitelisted.
     */
    function isProfileCreatorWhitelisted(address profileCreator) external view returns (bool);

    /**
     * @notice Get whether a back module is whitelisted.
     */
    function isBackModuleWhitelisted(address module) external view returns (bool);

    /**
     * @notice Get whether an invest module is whitelisted.
     */
    function isInvestModuleWhitelisted(address module) external view returns (bool);

    /**
     * @notice Get whether an erc-20 currency is whitelisted.
     */
    function isERC20listed(address erc20) external view returns (bool);

    /**
     * @notice Get the default profile for an address.
     */
    function defaultProfile(address account) external view returns (uint256);

    /**
     * @notice Get the governance address.
     */
    function getGovernance() external view returns (address);

    /**
     * @notice Get the number of projects created by a profile.
     */
    function getProjectCount(uint256 profileId) external view returns (uint256);

    /**
     * @notice Get back module for a profile
     */
    function getBackModule(uint256 profileId) external view returns (address);

    /**
     * @notice Get back NFT associated with a profile
     */
    function getBackNFT(uint256 profileId) external view returns (address);

    // TODO
    // function getBackNFTURI()

    /**
     * @notice
     */
    function getInvestModule(uint256 profileId, uint256 projectId) external view returns (address);

    /**
     * @notice Get invest NFT associated with a project
     */
    function getInvestNFT(uint256 profileId, uint256 projectId) external view returns (address);

    /**
     * @notice Get the handle corresponding to a profile.
     */
    function getHandle(uint256 profileId) external view returns (string memory);

    /**
     * @notice Get the metadata URI for a given project.
     */
    function getProjectMetadataURI(uint256 profileId, uint256 projectId)
        external
        view
        returns (string memory);

    /**
     * @notice Get profile id corresponding to a handle.
     */
    function getProfileIdByHandle(string calldata handle) external view returns (uint256);

    /**
     * @notice Return the full data struct for a profile.
     *
     * @param profileId Id of the profile.
     *
     * @return ProfileStruct Profile struct.
     */
    function getProfile(uint256 profileId) external view returns (DataTypes.ProfileStruct memory);

    /**
     * @notice Get the full data struct for a given project.
     *
     * @param profileId Id of the profile that created the project.
     * @param projectId Id of the project.
     *
     * @return ProjectStruct Project struct
     */
    function getProject(uint256 profileId, uint256 projectId)
        external
        view
        returns (DataTypes.ProjectStruct memory);

    /**
     * @notice Get the data struct for a given Yield Trust.
     *
     * @param profileId Id of the profile that is the yield recipient.
     * @param currency Address of the (whitelisted) ERC-20 that is the underlying asset.
     *
     * @return YieldTrustSTruct Yield trust struct
     */
    function getYieldTrust(uint256 profileId, address currency)
        external
        view
        returns (DataTypes.YieldTrustStruct memory);

    /**
     * @notice Get back NFT impl addr
     */
    function getBackNFTImpl() external view returns (address);

    /**
     * @notice Get invest NFT impl addr
     */
    function getInvestNFTImpl() external view returns (address);
}
