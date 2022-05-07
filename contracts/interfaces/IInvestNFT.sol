// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {DataTypes} from "../libraries/DataTypes.sol";

/**
 * @title IInvestNFT
 *
 * @notice
 */
interface IInvestNFT {
    /**
     * @notice Initialize, set Hub as minter and save profileId and projectId
     */
    function initialize(
        uint256 profileId,
        uint256 projectId,
        string calldata name,
        string calldata symbol
    ) external;

    /**
     * @notice Mint upon `back` action
     */
    function mint(address to) external returns (uint256);

    // TODO governance
}
