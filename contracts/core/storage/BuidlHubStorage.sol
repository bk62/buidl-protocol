// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {DataTypes} from "../../libraries/DataTypes.sol";
import {IAavePoolAddressesProvider} from "../../defi/IAavePoolAddressesProvider.sol";

abstract contract BuidlHubStorage {
    mapping(address => bool) internal _profileCreatorWhitelisted;
    mapping(address => bool) internal _backModuleWhitelisted;
    mapping(address => bool) internal _investModuleWhitelisted;

    mapping(bytes32 => uint256) internal _profileIdByHandleHash;
    mapping(uint256 => DataTypes.ProfileStruct) internal _profileById;

    mapping(uint256 => mapping(uint256 => DataTypes.ProjectStruct)) internal _projectByIdByProfile;
    mapping(bytes32 => uint256[2]) internal _profileProjectIdsByProjectHandleHash;

    mapping(bytes32 => DataTypes.YieldTrustStruct) internal _yieldTrustByProfileCurrencyHash;

    mapping(address => uint256) internal _defaultProfileByAddress;

    uint256 internal _profileCounter;
    address internal _governance;

    // whitelisted ERC-20s
    mapping(address => bool) internal _erc20Whitelisted;

    // AAVE yield source information - for Yield Trust Vaults
    IAavePoolAddressesProvider internal _aavePoolAddressProvider;
    // ERC-20 addr => corresponding Aave aToken
    // also used to track erc20s allowed to be yield trust underyling assets
    // b/c some ERC-20s might be whitelisted but not supported by Aave
    // TODO need events to track what's been set
    mapping(address => address) _aaveaTokenByCurrency;

    // Modules and chainlink
    address _clNativePriceFeed;
    mapping(address => address) _clPriceFeedByCurrency;
}
