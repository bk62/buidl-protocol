// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {Errors} from "../../../libraries/Errors.sol";
import {Events} from "../../../libraries/Events.sol";
import {IBuidlHub} from "../../../interfaces/IBuidlHub.sol";
import {IBackModule} from "../../../interfaces/IBackModule.sol";

import {ModuleBase} from "../ModuleBase.sol";
import {BackValidatorBackModuleBase} from "./BackValidatorBackModuleBase.sol";
import {ERC20ICO} from "../ERC20ICO.sol";
import {ERCICOModuleBase} from "../ERC20ICOModuleBase.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @notice Back module that mints ERC20 tokens to backers based on amount and configuration.
 */
contract BackERC20ICOModule is
    ModuleBase,
    IBackModule,
    ERCICOModuleBase,
    BackValidatorBackModuleBase
{
    // ERC-20 by profile
    mapping(uint256 => ERC20ICO) internal _mappingERC20ByProfile;
    // per token price in USD fiat by profile
    mapping(uint256 => uint256) internal _mappingTokenUsdPriceByProfile;

    constructor(address hub, address erc20Impl) ERCICOModuleBase(hub, erc20Impl) {}

    /**
     * @param data Decoded into (name, symbol, )
     */
    function initializeModule(uint256 profileId, bytes calldata data)
        external
        override
        returns (bytes memory)
    {
        address owner = IERC721(hub).ownerOf(profileId);

        // decode calldata
        if (data.length == 0) revert Errors.InitializerParamsInvalid();
        (string memory name, string memory symbol, uint256 tokenUsdPrice) = abi.decode(
            data,
            (string, string, uint256)
        );
        if (tokenUsdPrice == 0) revert Errors.InitializerParamsInvalid();

        // deploy profile specific erc20 contract
        // string memory name = "Test";
        // string memory symbol = "T";
        ERC20ICO erc20 = _deployErc20(owner, name, symbol);
        _mappingERC20ByProfile[profileId] = erc20;
        _mappingTokenUsdPriceByProfile[profileId] = tokenUsdPrice;

        return data;
    }

    /**
     * @param data (address erc20 token used to back if any, bool used native currency instead of erc20s, uint256 amount)
     */
    function process(
        address backer,
        uint256 profileId,
        bytes calldata data
    ) external override {
        // mint tokens to backer
        ERC20ICO erc20 = _mappingERC20ByProfile[profileId];
        if (address(erc20) == address(0)) revert Errors.TokenDoesNotExist();
        if (data.length == 0) revert Errors.InvalidModuleArgs();

        // TODO
        // assuming single currency payment here -- but hub supports multi currencies + native in 1 txn!!
        (address paymentCurrency, bool nativeCurrency, uint256 amount) = abi.decode(
            data,
            (address, bool, uint256)
        );

        address priceFeedAddr = IBuidlHub(hub).getPriceFeed(paymentCurrency, nativeCurrency);
        uint256 price = _getLatestPrice(priceFeedAddr);
        uint256 tokenUsdPrice = _mappingTokenUsdPriceByProfile[profileId];
        // e.g. 10 link * 20 $/link / (2 $/token) = 100 tokens
        uint256 mintAmount = (amount * price) / tokenUsdPrice;

        _mint(erc20, _msgSender(), mintAmount);
    }

    function moduleNFTTransferHook(
        uint256 profileId,
        address from,
        address to,
        uint256 nftTokenId
    ) external override {}
}
