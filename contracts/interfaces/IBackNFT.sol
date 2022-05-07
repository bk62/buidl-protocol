// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {DataTypes} from "../libraries/DataTypes.sol";

/**
 * @title IBackNFT
 *
 * @notice
 */
interface IBackNFT {
    /**
     * @notice Initialize, set Hub as minter and save profileId
     */
    function initialize(uint256 profileId) external;

    /**
     * @notice Mint upon `back` action
     */
    function mint(address to) external returns (uint256);

    // TODO governance
}
