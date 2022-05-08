// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import {IBackNFT} from "../interfaces/IBackNFT.sol";
// import {IBackModule} from "../interfaces/IBackModule.sol";
import {IBuidlHub} from "../interfaces/IBuidlHub.sol";
import {Errors} from "../libraries/Errors.sol";
import {Events} from "../libraries/Events.sol";
import {DataTypes} from "../libraries/DataTypes.sol";
import {Constants} from "../libraries/Constants.sol";
import {NFTBaseUpgradeable} from "./base/NFTBaseUpgradeable.sol";

/**
 * @title BackNFT
 *
 * @notice NFT minted when a profile is backed.
 */
contract BackNFT is NFTBaseUpgradeable, IBackNFT {
    address public immutable hub;

    uint256 internal _profileId;
    uint256 internal _tokenIdCounter;

    // bool private _initialized;

    // Created w/ pre-computed hub adress before hub is deployed
    constructor(address hub_) {
        if (hub_ == address(0)) revert Errors.ConstructorParamsInvalid();
        hub = hub_;
        // _initialized = true;
    }

    /// @inheritdoc IBackNFT
    function initialize(
        uint256 profileId,
        string calldata name,
        string calldata symbol
    ) external override initializer {
        // if (_initialized) revert Errors.Initialized();
        // _initialized = true;

        // Store profile id
        _profileId = profileId;

        // Init ERC-721 metadata
        __ERC721_init(name, symbol);

        // emit events
        emit Events.BackNFTInitialized(profileId, block.timestamp);
    }

    /// @inheritdoc IBackNFT
    function mint(address to) external override returns (uint256) {
        if (msg.sender != hub) revert Errors.NotHub();
        unchecked {
            uint256 tokenId = ++_tokenIdCounter;
            _safeMint(to, tokenId);
            return tokenId;
        }
    }

    /**
     * @dev
     */
    // TODO
    // function tokenURI(uint256 tokenId) public view override returns (string memory) {
    //     if (!_exists(tokenId)) revert Errors.TokenDoesNotExist();
    //     return IBuidlHub(hub).getBackNFT(_profileId);
    // }
}
