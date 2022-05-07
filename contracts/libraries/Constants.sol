// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

library Constants {
    string internal constant BACK_NFT_NAME_SUFFIX = "-Backer";
    string internal constant BACK_NFT_SYMBOL_SUFFIX = "-Bk";
    string internal constant INVEST_NFT_NAME_INFIX = "-Investor-";
    string internal constant INVEST_NFT_SYMBOL_INFIX = "-In-";
    uint8 internal constant MAX_HANDLE_LENGTH = 31;
    uint16 internal constant MAX_PROFILE_IMAGE_URI_LENGTH = 6000;
}
