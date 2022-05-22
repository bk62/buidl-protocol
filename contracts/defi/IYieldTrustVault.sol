// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import "./IERC4626.sol";

/**
 * @title Yield Trust EIP-4626 compatible vault spec
 */
interface IYieldTrustVault is IERC4626 {
    /**
     * @dev Indicates that `amount` of underlying assets were deposited into yield source.
     */
    event YieldSourceBatchDeposit(uint256 amount);

    /**
     * @dev Indicates `amount` of yields were claimed by corresponding profile NFT's current owner `user`
     */
    event YieldClaimed(address indexed user, uint256 amount);

    /**
     * @dev Indicates `amount` withdrawn from yield source.
     */
    event YieldSourceWithdrawal(uint256 amount);

    /**
     * @notice Initialize vault
     */
    function initialize(
        uint256 profileId,
        address assetErc20,
        address yieldSource,
        string calldata name,
        string calldata symbol
    ) external;

    /**
     * @notice Get yield source address
     */
    function yieldSource() external view returns (address);

    /**
     * @notice Get profile token id corresponding to profile id i.e. profile NFT token Id on hub
     */
    function profileId() external view returns (uint256);

    /**
     * @notice Get yield recipient i.e. current profile NFT owner
     */
    function yieldRecipient() external view returns (address);

    /**
     * @notice Deposit all underlying assets held by contract into the yield source.
     * @return uint256 Amount deposited
     */
    function batchDeposit() external returns (uint256);

    /**
     * @notice Claim yield from yield source -- only callable by corresponding profile NFT owner.
     */
    function claimYield(uint256 amount) external returns (uint256);
}
