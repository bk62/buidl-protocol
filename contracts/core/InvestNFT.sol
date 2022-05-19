// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import {IInvestNFT} from "../interfaces/IInvestNFT.sol";
import {IInvestModule} from "../interfaces/IInvestModule.sol";
import {IBuidlHub} from "../interfaces/IBuidlHub.sol";
import {Errors} from "../libraries/Errors.sol";
import {Events} from "../libraries/Events.sol";
import {DataTypes} from "../libraries/DataTypes.sol";
import {Constants} from "../libraries/Constants.sol";
import {NFTBaseUpgradeable} from "./base/NFTBaseUpgradeable.sol";

/**
 * @title InvestNFT
 *
 * @notice NFT minted when a profile is backed.
 */
contract InvestNFT is NFTBaseUpgradeable, IInvestNFT {
    address public immutable hub;

    uint256 internal _profileId;
    uint256 internal _projectId;
    uint256 internal _tokenIdCounter;

    // Created with pre-computed hub address
    constructor(address hub_) {
        if (hub_ == address(0)) revert Errors.ConstructorParamsInvalid();
        hub = hub_;
    }

    /// @inheritdoc IInvestNFT
    function initialize(
        uint256 profileId,
        uint256 projectId,
        string calldata name,
        string calldata symbol
    ) external override initializer {
        // Store profile and project ids
        _profileId = profileId;
        _projectId = projectId;

        // Init ERC-721 metadata
        __ERC721_init(name, symbol);

        // emit events
        emit Events.InvestNFTInitialized(profileId, projectId, block.timestamp);
    }

    /// @inheritdoc IInvestNFT
    function mint(address to) external override returns (uint256) {
        if (msg.sender != hub) revert Errors.NotHub();
        unchecked {
            uint256 tokenId = ++_tokenIdCounter;
            _safeMint(to, tokenId);
            return tokenId;
        }
    }

    /**
     * @dev Return the Invest NFT URI fetched from the hub.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) revert Errors.TokenDoesNotExist();
        return IBuidlHub(hub).getInvestNFTURI(_profileId, _projectId);
    }
}
