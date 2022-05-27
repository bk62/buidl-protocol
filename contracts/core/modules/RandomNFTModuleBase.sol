// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {Errors} from "../../libraries/Errors.sol";
import {Events} from "../../libraries/Events.sol";
import {IBuidlHub} from "../../interfaces/IBuidlHub.sol";
import {IBackModule} from "../../interfaces/IBackModule.sol";
import {ModuleBase} from "./ModuleBase.sol";
import {NFTBaseUpgradeable} from "../base/NFTBaseUpgradeable.sol";

import {IERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

abstract contract RandomNFTModuleBase is ModuleBase {
    address immutable _nftImpl;

    constructor(address hub, address nftImpl) ModuleBase(hub) {
        if (nftImpl == address(0)) revert Errors.ConstructorParamsInvalid();
        _nftImpl = nftImpl;
    }

    function _deployNft() internal returns (NFTBaseUpgradeable) {
        address nftAddr = Clones.clone(_nftImpl);
        NFTBaseUpgradeable nft = NFTBaseUpgradeable(nftAddr);
        // nft.initialize();
        return nft;
    }

    function _mint() internal {}
}
