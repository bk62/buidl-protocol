// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import {IBuidlHub} from "../interfaces/IBuidlHub.sol";
import {Events} from "../libraries/Events.sol";
import {Constants} from "../libraries/Constants.sol";
import {DataTypes} from "../libraries/DataTypes.sol";
import {Errors} from "../libraries/Errors.sol";
import {BuidlingLogic} from "../libraries/BuidlingLogic.sol";
import {FundingLogic} from "../libraries/FundingLogic.sol";
import {TokenURILogic} from "../libraries/TokenURILogic.sol";
import {NFTBase} from "./base/NFTBase.sol";
import {MultiState} from "./base/MultiState.sol";
import {BuidlHubStorage} from "./storage/BuidlHubStorage.sol";
import {IAavePoolAddressesProvider} from "../defi/IAavePoolAddressesProvider.sol";

/**
 * @title BuidlHub
 *
 * @notice Main entrypoint to the Buidl Protocol.
 *
 * @dev Following Lens Protocol, events emit current block timestamp.
 *      Inspired by Lens Protocol `LensHub`.
 */
contract BuidlHub is IBuidlHub, BuidlHubStorage, NFTBase, MultiState {
    address internal immutable backNFTImpl;
    address internal immutable investNFTImpl;
    address internal immutable yieldTrustVaultImpl;
    address internal immutable erc20IcoImpl; // erc20 impl for ICO modules

    /**
     * @dev Modifier to revert unless called by governance address.
     */
    modifier onlyGov() {
        _validateCallerIsGovernance();
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        address newGovernance,
        address backNFTImpl_,
        address investNFTImpl_,
        address yieldTrustVaultImpl_,
        address erc20IcoImpl_
    ) ERC721(name, symbol) {
        if (backNFTImpl_ == address(0)) revert Errors.ConstructorParamsInvalid();
        if (investNFTImpl_ == address(0)) revert Errors.ConstructorParamsInvalid();
        if (yieldTrustVaultImpl_ == address(0)) revert Errors.ConstructorParamsInvalid();
        if (erc20IcoImpl_ == address(0)) revert Errors.ConstructorParamsInvalid();

        backNFTImpl = backNFTImpl_;
        investNFTImpl = investNFTImpl_;
        yieldTrustVaultImpl = yieldTrustVaultImpl_;
        erc20IcoImpl = erc20IcoImpl_;

        _setState(DataTypes.ProtocolState.Paused);
        _setGovernance(newGovernance);
    }

    /**
     * Governance methods:
     * ____________________
     */

    /// @inheritdoc IBuidlHub
    function setGovernance(address newGovernance) external override onlyGov {
        _setGovernance(newGovernance);
    }

    /// @inheritdoc IBuidlHub
    function setState(DataTypes.ProtocolState newState) external override onlyGov {
        _setState(newState);
    }

    /// @inheritdoc IBuidlHub
    function whitelistProfileCreator(address profileCreator, bool whitelist)
        external
        override
        onlyGov
    {
        _profileCreatorWhitelisted[profileCreator] = whitelist;
        emit Events.ProfileCreatorWhitelisted(profileCreator, whitelist, block.timestamp);
    }

    ///@inheritdoc IBuidlHub
    function whitelistBackModule(address module, bool whitelist) external override onlyGov {
        _backModuleWhitelisted[module] = whitelist;
        emit Events.BackModuleWhitelisted(module, whitelist, block.timestamp);
    }

    ///@inheritdoc IBuidlHub
    function whitelistInvestModule(address module, bool whitelist) external override onlyGov {
        _investModuleWhitelisted[module] = whitelist;
        emit Events.InvestModuleWhitelisted(module, whitelist, block.timestamp);
    }

    ///@inheritdoc IBuidlHub
    function whitelistERC20(address erc20, bool whitelist) external override onlyGov {
        _erc20Whitelisted[erc20] = whitelist;
        emit Events.ERC20Whitelisted(erc20, whitelist, block.timestamp);
    }

    ///@inheritdoc IBuidlHub
    function setAavePoolAddressProvider(address provider_) external override onlyGov {
        if (provider_ == address(0)) revert Errors.ConstructorParamsInvalid();
        _aavePoolAddressProvider = IAavePoolAddressesProvider(provider_);
    }

    ///@inheritdoc IBuidlHub
    function setAaveaToken(address erc20, address aToken) external override onlyGov {
        if (erc20 == address(0) || aToken == address(0)) revert Errors.ConstructorParamsInvalid();
        _aaveaTokenByCurrency[erc20] = aToken;
    }

    /// @inheritdoc IBuidlHub
    function setPriceFeed(address erc20, address priceFeed) external override {
        if (priceFeed == address(0)) revert Errors.ConstructorParamsInvalid();
        if (erc20 == address(0)) {
            // native
            _clNativePriceFeed = priceFeed;
        } else {
            _clPriceFeedByCurrency[erc20] = priceFeed;
        }
    }

    /**
     * Profile owner methods:
     * _______________________
     */

    /// @inheritdoc IBuidlHub
    function createProfile(DataTypes.CreateProfileData calldata vars)
        external
        override
        whenNotPaused
        returns (uint256)
    {
        if (!_profileCreatorWhitelisted[msg.sender]) revert Errors.ProfileCreatorNotWhitelisted();

        unchecked {
            uint256 profileId = ++_profileCounter;
            _safeMint(vars.to, profileId);
            BuidlingLogic.createProfile(
                vars,
                profileId,
                _profileIdByHandleHash,
                _profileById,
                _backModuleWhitelisted
            );
            return profileId;
        }
    }

    /// @inheritdoc IBuidlHub
    function setDefaultProfile(uint256 profileId) external override whenNotPaused {
        _setDefaultProfile(msg.sender, profileId);
    }

    /// @inheritdoc IBuidlHub
    function setBackModule(
        uint256 profileId,
        address module,
        bytes calldata moduleInitData
    ) external override whenNotPaused {
        _validateCallerIsProfileOwner(profileId);
        BuidlingLogic.setBackModule(
            profileId,
            module,
            moduleInitData,
            _profileById[profileId],
            _backModuleWhitelisted
        );
    }

    /// @inheritdoc IBuidlHub
    function createProject(DataTypes.CreateProjectData calldata vars)
        external
        override
        whenBuidlingEnabled
        returns (uint256)
    {
        _validateCallerIsProfileOwner(vars.profileId);

        unchecked {
            uint256 projectId = ++_profileById[vars.profileId].projectCount;
            BuidlingLogic.createProject(
                vars,
                projectId,
                _profileProjectIdsByProjectHandleHash,
                _projectByIdByProfile,
                _investModuleWhitelisted
            );
            return projectId;
        }
    }

    /// @inheritdoc IBuidlHub
    function createYieldTrust(DataTypes.YieldTrustStruct calldata trust)
        external
        override
        whenFundingEnabled
    {
        // _validateCallerIsProfileOwner(trust.profileId); // anyone can create

        FundingLogic.createYieldTrust(
            trust,
            _yieldTrustByProfileCurrencyHash,
            _profileById,
            _erc20Whitelisted,
            yieldTrustVaultImpl,
            _aaveaTokenByCurrency
        );
    }

    /// @inheritdoc IBuidlHub
    function emitYieldTrustDepositEvent(
        uint256 profileId,
        address asset,
        uint256 amount,
        address receiver,
        address vault
    ) external override {
        FundingLogic.emitYieldTrustDeposited(profileId, asset, amount, receiver, vault);
    }

    /// @inheritdoc IBuidlHub
    function getAavePool() external view override returns (address) {
        _aavePoolAddressProvider.getPool();
    }

    ///@inheritdoc IBuidlHub
    function getAaveaToken(address erc20) external view override returns (address) {
        return _aaveaTokenByCurrency[erc20];
    }

    // TODO
    /// @inheritdoc IBuildHub
    // function setProfileImageURI(uint256 profileId, string calldata imageURI)
    //     external
    //     overide
    //     whenNotPaused
    // {
    //     _validateCallerIsProfileOwner(profileId);
    //     _setProfileImageURI(profileId, imageURI);
    // }

    // TODO
    // function setBackNFTURI

    /**
     * @notice Burns profile corresponding to `profileId` -- maintains profile
     *         data struct but deletes the hande hash.
     */
    function burn(uint256 profileId) public override whenNotPaused {
        super.burn(profileId);
        _clearHandleHash(profileId);
    }

    /**
     *  Interaction methods:
     * _____________________________
     */

    /// @inheritdoc IBuidlHub
    function back(
        uint256 profileId,
        bytes calldata backModuleData,
        address[] calldata erc20s,
        uint256[] calldata amounts
    ) external payable override whenFundingEnabled returns (uint256) {
        return
            FundingLogic.back(
                msg.sender,
                profileId,
                backModuleData,
                backNFTImpl,
                erc20s,
                amounts,
                _profileById
            );
    }

    /// @inheritdoc IBuidlHub
    function invest(
        uint256 profileId,
        uint256 projectId,
        bytes calldata investModuleData,
        address[] calldata erc20s,
        uint256[] calldata amounts
    ) external payable override whenFundingEnabled returns (uint256) {
        return
            FundingLogic.invest(
                DataTypes.ProjectInvestor(profileId, projectId, msg.sender),
                investModuleData,
                // investNFTImpl,
                erc20s,
                amounts,
                _profileById,
                _projectByIdByProfile
            );
    }

    /**
     * External view methods:
     * -----------------------
     */

    /// @inheritdoc IBuidlHub
    function isProfileCreatorWhitelisted(address profileCreator)
        external
        view
        override
        returns (bool)
    {
        return _profileCreatorWhitelisted[profileCreator];
    }

    /// @inheritdoc IBuidlHub
    function isBackModuleWhitelisted(address module) external view override returns (bool) {
        return _backModuleWhitelisted[module];
    }

    /// @inheritdoc IBuidlHub
    function isInvestModuleWhitelisted(address module) external view override returns (bool) {
        return _investModuleWhitelisted[module];
    }

    /// @inheritdoc IBuidlHub
    function isERC20listed(address erc20) external view override returns (bool) {
        return _erc20Whitelisted[erc20];
    }

    /// @inheritdoc IBuidlHub
    function defaultProfile(address account) external view override returns (uint256) {
        return _defaultProfileByAddress[account];
    }

    /// @inheritdoc IBuidlHub
    function getGovernance() external view override returns (address) {
        return _governance;
    }

    /// @inheritdoc IBuidlHub
    function getProjectCount(uint256 profileId) external view override returns (uint256) {
        return _profileById[profileId].projectCount;
    }

    /// @inheritdoc IBuidlHub
    function getHandle(uint256 profileId) external view override returns (string memory) {
        return _profileById[profileId].handle;
    }

    // TODO getPubPointer?

    /// @inheritdoc IBuidlHub
    function getProjectMetadataURI(uint256 profileId, uint256 projectId)
        external
        view
        override
        returns (string memory)
    {
        return _projectByIdByProfile[profileId][projectId].metadataURI;
    }

    /// @inheritdoc IBuidlHub
    function getProfileIdByHandle(string calldata handle) external view override returns (uint256) {
        bytes32 handleHash = keccak256(bytes(handle));
        return _profileIdByHandleHash[handleHash];
    }

    /**
     * @notice Convenience function to get profile by handle
     */
    function getProfileByHandle(string calldata handle)
        external
        view
        returns (DataTypes.ProfileStruct memory)
    {
        bytes32 handleHash = keccak256(bytes(handle));
        uint256 profileId = _profileIdByHandleHash[handleHash];
        if (profileId == 0) revert Errors.ProfileNotFound();
        return _profileById[profileId];
    }

    /// @inheritdoc IBuidlHub
    function getProfile(uint256 profileId)
        external
        view
        override
        returns (DataTypes.ProfileStruct memory)
    {
        return _profileById[profileId];
    }

    function getProjectIdsByHandle(string calldata handle)
        external
        view
        returns (uint256[2] memory)
    {
        bytes32 handleHash = keccak256(bytes(handle));
        return _profileProjectIdsByProjectHandleHash[handleHash];
    }

    function getProjectByHandle(string calldata handle)
        external
        view
        returns (DataTypes.ProjectStruct memory)
    {
        bytes32 handleHash = keccak256(bytes(handle));
        uint256[2] storage ids = _profileProjectIdsByProjectHandleHash[handleHash];
        return _projectByIdByProfile[ids[0]][ids[1]];
    }

    /// @inheritdoc IBuidlHub
    function getProject(uint256 profileId, uint256 projectId)
        external
        view
        override
        returns (DataTypes.ProjectStruct memory)
    {
        return _projectByIdByProfile[profileId][projectId];
    }

    /// @inheritdoc IBuidlHub
    function getYieldTrust(uint256 profileId, address currency)
        external
        view
        override
        returns (DataTypes.YieldTrustStruct memory)
    {
        return
            _yieldTrustByProfileCurrencyHash[FundingLogic.getYieldTrustHash(profileId, currency)];
    }

    /// @inheritdoc IBuidlHub
    function getAavePoolAddressProvider() external view override returns (address) {
        return address(_aavePoolAddressProvider);
    }

    /// @inheritdoc IBuidlHub
    function getPriceFeed(address erc20, bool native) external view override returns (address) {
        if (native) return _clNativePriceFeed;
        return _clPriceFeedByCurrency[erc20];
    }

    // // TODO
    // function getProjectType(uint256 projectId, uint256 projectId) external view override returns(DataTypes.ProjectType) {

    // }

    /// @inheritdoc IERC721Metadata
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return _profileById[tokenId].metadataURI;
    }

    /// @inheritdoc IBuidlHub
    function getBackModule(uint256 profileId) public view override returns (address) {
        return _profileById[profileId].backModule;
    }

    /// @inheritdoc IBuidlHub
    function getBackNFT(uint256 profileId) public view override returns (address) {
        return _profileById[profileId].backNFT;
    }

    /// @inheritdoc IBuidlHub
    function getBackNFTURI(uint256 profileId, uint256 tokenId)
        external
        view
        override
        returns (string memory)
    {
        // return _profileById[profileId].metadataURI;
        return
            TokenURILogic.getBackNFTTokenURI(
                profileId,
                tokenId,
                _profileById[profileId].handle,
                _profileById[profileId].metadataURI,
                _profileById[profileId].githubUsername
            );
    }

    /// @inheritdoc IBuidlHub
    function getInvestModule(uint256 profileId, uint256 projectId)
        public
        view
        override
        returns (address)
    {
        return _projectByIdByProfile[profileId][projectId].investModule;
    }

    /// @inheritdoc IBuidlHub
    function getInvestNFT(uint256 profileId, uint256 projectId)
        public
        view
        override
        returns (address)
    {
        return _projectByIdByProfile[profileId][projectId].investNFT;
    }

    /// @inheritdoc IBuidlHub
    function getInvestNFTURI(
        uint256 profileId,
        uint256 projectId,
        uint256 tokenId
    ) external view override returns (string memory) {
        // return _projectByIdByProfile[profileId][projectId].metadataURI;
        return
            TokenURILogic.getInvestNFTTokenURI(
                // profileId,
                // projectId,
                tokenId,
                _profileById[profileId].handle,
                _projectByIdByProfile[profileId][projectId].handle,
                _profileById[profileId].metadataURI,
                _projectByIdByProfile[profileId][projectId].metadataURI,
                _profileById[profileId].githubUsername,
                _projectByIdByProfile[profileId][projectId].githubRepoName
            );
    }

    /// @inheritdoc IBuidlHub
    function getBackNFTImpl() external view override returns (address) {
        return backNFTImpl;
    }

    /// @inheritdoc IBuidlHub
    function getInvestNFTImpl() external view override returns (address) {
        return investNFTImpl;
    }

    /// @inheritdoc IBuidlHub
    function getYieldTrustVaultImpl() external view override returns (address) {
        return yieldTrustVaultImpl;
    }

    /**
     * Internal methods:
     * __________________
     */

    function _setGovernance(address newGov) internal {
        address prevGov = _governance;
        _governance = newGov;
        emit Events.GovernanceSet(msg.sender, prevGov, newGov, block.timestamp);
    }

    // Unset by calling with `profileId = 0`
    function _setDefaultProfile(address account, uint256 profileId) internal {
        if (profileId > 0 && account != ownerOf(profileId)) revert Errors.NotProfileOwner();

        _defaultProfileByAddress[account] = profileId;

        emit Events.DefaultProfileSet(account, profileId, block.timestamp);
    }

    function _clearHandleHash(uint256 profileId) internal {
        bytes32 handleHash = keccak256(bytes(_profileById[profileId].handle));
        _profileIdByHandleHash[handleHash] = 0;
    }

    function _validateCallerIsGovernance() internal view {
        if (msg.sender != _governance) revert Errors.NotGovernance();
    }

    function _validateCallerIsProfileOwner(uint256 profileId) internal view {
        if (msg.sender != ownerOf(profileId)) revert Errors.NotProfileOwner();
    }
}
