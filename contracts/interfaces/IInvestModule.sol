// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

/**
 * @title IInvestModule
 *
 * @notice
 */
interface IInvestModule {
    /**
     * @notice Initialize mod. Called once only.
     */
    function initializeModule(
        uint256 profileId,
        uint256 projectId,
        bytes calldata data
    ) external returns (bytes memory);

    /**
     * @notice Process action. Called from Hub only.
     */
    function process(
        address investor,
        uint256 profileId,
        uint256 projectId,
        bytes calldata data
    ) external;

    /**
     * @notice Transfer hook called before NFT transfer. Called from Hub only.
     */
    function moduleNFTTransferHook(
        uint256 profileId,
        uint256 projectId,
        address from,
        address to,
        uint256 nftTokenId
    ) external;

    /**
     * @notice Whether an account is a current investor.
     * TODO: Meant to replace check on investor NFT ownership?
     */
    function isInvestor(
        uint256 profileId,
        uint256 projectId,
        address investor,
        uint256 nftTokenId
    ) external view returns (bool);
}
