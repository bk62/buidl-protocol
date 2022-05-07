// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

/**
 * @title IBackModule
 *
 * @notice
 */
interface IBackModule {
    /**
     * @notice Initialize mod. Called once only.
     */
    function initializeModule(uint256 profileId, bytes calldata data)
        external
        returns (bytes memory);

    /**
     * @notice Process action. Called from Hub only.
     */
    function process(
        address actor,
        uint256 profileId,
        bytes calldata data
    ) external;

    /**
     * @notice Transfer hook called before NFT transfer. Called from Hub only.
     */
    function moduleNFTTransferHook(
        uint256 profileId,
        address from,
        address to,
        uint256 nftTokenId
    ) external;

    /**
     * @notice Whether an account is a current backer.
     * TODO: Meant to replace check on backer NFT ownership?
     */
    function isBacker(
        uint256 profileId,
        address backer,
        uint256 nftTokenId
    ) external view returns (bool);
}
