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
        address aToken,
        string calldata name,
        string calldata symbol
    ) external;

    /**
     * @notice Get aToken address
     */
    function aToken() external view returns (address);

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
     * @notice Total deposits by contributors to the fund i.e. total assets - total yield.
     * @return uint256 Total deposits
     */
    function totalDeposits() external view returns (uint256);

    /**
     * @notice Max claimable yield from yield source by corresponding profile NFT owner.
     * @return uint256 Max amount
     */
    function maxClaimYield() external view returns (uint256);

    /**
     * @notice Claim yield from yield source -- only callable by corresponding profile NFT owner.
     */
    function claimYield(uint256 amount) external returns (uint256);
}
