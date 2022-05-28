// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import {DataTypes} from "./DataTypes.sol";
import {Errors} from "./Errors.sol";
import {Events} from "./Events.sol";
import {Constants} from "./Constants.sol";
import {IBuidlHub} from "../interfaces/IBuidlHub.sol";
import {IBackNFT} from "../interfaces/IBackNFT.sol";
import {IBackModule} from "../interfaces/IBackModule.sol";
import {BackNFT} from "../core/BackNFT.sol";
import {IInvestNFT} from "../interfaces/IInvestNFT.sol";
import {IInvestModule} from "../interfaces/IInvestModule.sol";
import {InvestNFT} from "../core/InvestNFT.sol";

library TokenURILogic {
    using Strings for uint256;

    function getBackNFTTokenURI(
        uint256 profileId,
        uint256 tokenId,
        string memory handle,
        string memory metadataURI,
        string memory githubUsername
    ) external pure returns (string memory) {
        string memory handleWithAtSymbol = string(abi.encodePacked("@", handle));
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        abi.encodePacked(
                            '{"name":"Backer of ',
                            handleWithAtSymbol,
                            '","description":"Backed creator ',
                            handleWithAtSymbol,
                            " - NFT Token Id: ",
                            Strings.toString(tokenId),
                            '","attributes":[{"trait_type":"id","value":"#',
                            Strings.toString(tokenId),
                            '"},{"trait_type":"backedGithubUsername","value":"',
                            githubUsername,
                            '"},{"trait_type":"backedHandle","value":"',
                            handleWithAtSymbol,
                            '"},{"trait_type":"backedMetadataURI","value":"',
                            metadataURI,
                            '"}]}'
                        )
                    )
                )
            );
    }

    function getInvestNFTTokenURI(
        // uint256 profileId,
        // uint256 projectId,
        uint256 tokenId,
        string memory profileHandle,
        string memory projectHandle,
        string memory profileMetadataURI,
        string memory projectMetadataURI,
        string memory githubUsername,
        string memory githubRepoName
    ) external pure returns (string memory) {
        string memory projectHandleURI = string(
            abi.encodePacked("@", profileHandle, "/", projectHandle)
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        abi.encodePacked(
                            '{"name":"Investor of ',
                            projectHandleURI,
                            '","description":"Invested in project ',
                            projectHandleURI,
                            '","attributes":[{"trait_type":"id","value":"#',
                            Strings.toString(tokenId),
                            '"},{"trait_type":"investedGithubUsername","value":"',
                            githubUsername,
                            '"},{"trait_type":"investedGithubRepoName","value":"',
                            githubRepoName,
                            '"},{"trait_type":"investedProfileMetadataURI","value":"',
                            profileMetadataURI,
                            '"},{"trait_type":"investedProjectMetadataURI","value":"',
                            projectMetadataURI,
                            '"}]}'
                        )
                    )
                )
            );
    }
}
