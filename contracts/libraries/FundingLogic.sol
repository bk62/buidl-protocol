// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

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
import "../defi/IYieldTrustVault.sol";

// import "hardhat/console.sol";

/**
 * @title FundingLogic
 *
 * @notice
 */
library FundingLogic {
    using Strings for uint256;
    using SafeERC20 for IERC20;

    /**
     * @notice Create yield trust
     */
    function createYieldTrust(
        DataTypes.YieldTrustStruct memory trust,
        mapping(bytes32 => DataTypes.YieldTrustStruct) storage _yieldTrustByProfileCurrencyHash,
        mapping(uint256 => DataTypes.ProfileStruct) storage _profileById,
        mapping(address => bool) storage _erc20Whitelisted,
        address ytVaultImpl,
        address yieldSource
    ) external {
        // check profile exists
        if (
            trust.profileId == 0 ||
            // convert handle to bytes and check if empty
            bytes(_profileById[trust.profileId].handle).length == 0
        ) {
            revert Errors.ProfileNotFound();
        }

        // check currency
        if (trust.currency == address(0) || !_erc20Whitelisted[trust.currency]) {
            revert Errors.InvalidERC20();
        }

        bytes32 ytHash = getYieldTrustHash(trust.profileId, trust.currency);

        // check trust does not already exist
        if (_yieldTrustByProfileCurrencyHash[ytHash].profileId != 0) {
            // already exists
            revert Errors.AlreadyExists();
        }

        trust.vault = _deployYTVault(
            ytVaultImpl,
            _profileById[trust.profileId].handle,
            trust.profileId,
            trust.currency,
            yieldSource
        );

        // store trust by hash of (profileId, currency addr)
        _yieldTrustByProfileCurrencyHash[ytHash] = trust;

        // emit event
        emit Events.YieldTrustCreated(
            trust.profileId,
            trust.currency,
            msg.sender, // creator
            IBuidlHub(address(this)).ownerOf(trust.profileId), // recipient
            block.timestamp
        );
    }

    /**
     * @notice Back profiles.
     */
    function back(
        address backer,
        uint256 profileId,
        bytes calldata moduleData,
        address backNFTImpl,
        address[] calldata erc20s,
        uint256[] calldata amounts,
        mapping(uint256 => DataTypes.ProfileStruct) storage _profileById
    ) external returns (uint256) {
        if (erc20s.length != amounts.length) revert Errors.ArrayMismatch();

        {
            if (msg.value == 0) {
                bool allZero = true;
                for (uint256 i = 0; i < amounts.length; ) {
                    if (amounts[i] != 0) {
                        allZero = false;
                        break;
                    }
                    unchecked {
                        i++;
                    }
                }
                // all amounts are = 0
                if (allZero) revert Errors.ZeroAmounts();
            }
        }

        address backNFT = _profileById[profileId].backNFT;

        if (backNFT == address(0)) {
            backNFT = _deployBackNFT(profileId, _profileById[profileId].handle, backNFTImpl);
            _profileById[profileId].backNFT = backNFT;
        }

        uint256 tokenId = IBackNFT(backNFT).mint(backer);

        // Avoid stack too deep

        address backModule = _profileById[profileId].backModule;

        // Process via back module
        // if back module is set, send any native currency in tx to module
        // send to owner wallet otherwise
        if (backModule != address(0)) {
            _transferFundsTo(backModule, msg.value, erc20s, amounts);
            IBackModule(backModule).process(backer, profileId, moduleData);
        } else {
            address profileOwner = IBuidlHub(address(this)).ownerOf(profileId);
            _transferFundsTo(profileOwner, msg.value, erc20s, amounts);
        }

        emit Events.Backed(
            backer,
            profileId,
            IBuidlHub(address(this)).ownerOf(profileId), // TODO cache
            moduleData,
            msg.value,
            erc20s,
            amounts,
            block.timestamp
        );
        return tokenId;
    }

    /**
     * @notice Invest in projects
     */
    function invest(
        DataTypes.ProjectInvestor memory projectInvestor,
        bytes calldata moduleData,
        address investNFTImpl,
        address[] calldata erc20s,
        uint256[] calldata amounts,
        mapping(uint256 => DataTypes.ProfileStruct) storage _profileById,
        mapping(uint256 => mapping(uint256 => DataTypes.ProjectStruct))
            storage _projectByIdByProfile
    ) external returns (uint256 tokenId) {
        if (erc20s.length != amounts.length) revert Errors.ArrayMismatch();

        tokenId = _deployAndMintInvestNFT(
            projectInvestor,
            _profileById[projectInvestor.profileId].handle,
            _projectByIdByProfile[projectInvestor.profileId][projectInvestor.projectId].investNFT,
            investNFTImpl
        );

        // _processInvestPayments(investor, profileId, projectId, moduleData, investModule);
        // Process via module
        // if module is set, send any native currency in tx to module
        // send to owner wallet otherwise
        address investModule = _projectByIdByProfile[projectInvestor.profileId][
            projectInvestor.projectId
        ].investModule;
        if (investModule != address(0)) {
            _transferFundsTo(investModule, msg.value, erc20s, amounts);
            IInvestModule(investModule).process(
                projectInvestor.investor,
                projectInvestor.profileId,
                projectInvestor.projectId,
                moduleData
            );
        } else {
            _transferFundsTo(
                IBuidlHub(address(this)).ownerOf(projectInvestor.profileId),
                msg.value,
                erc20s,
                amounts
            );
        }

        _emitInvestedEvent(
            projectInvestor.investor,
            projectInvestor.profileId,
            projectInvestor.projectId,
            moduleData,
            msg.value,
            erc20s,
            amounts
        );

        return tokenId;
    }

    function _deployAndMintInvestNFT(
        DataTypes.ProjectInvestor memory projectInvestor,
        string memory handle,
        address investNFT,
        address investNFTImpl
    ) internal returns (uint256 tokenId) {
        if (investNFT == address(0)) {
            investNFT = _deployInvestNFT(
                projectInvestor.profileId,
                projectInvestor.projectId,
                handle,
                investNFTImpl
            );
        }
        tokenId = IInvestNFT(investNFT).mint(projectInvestor.investor);
    }

    function _deployBackNFT(
        uint256 profileId,
        string memory handle,
        address backNFTImpl
    ) private returns (address) {
        address backNFT = Clones.clone(backNFTImpl);

        bytes4 firstBytes = bytes4(bytes(handle));
        IBackNFT(backNFT).initialize(
            profileId,
            string(abi.encodePacked(handle, Constants.BACK_NFT_NAME_SUFFIX)),
            string(abi.encodePacked(firstBytes, Constants.BACK_NFT_SYMBOL_SUFFIX))
        );

        emit Events.BackNFTDeployed(profileId, backNFT, block.timestamp);

        return backNFT;
    }

    function _deployInvestNFT(
        uint256 profileId,
        uint256 projectId,
        string memory handle,
        address investNFTImpl
    ) private returns (address) {
        address investNFT = Clones.clone(investNFTImpl);

        bytes4 firstBytes = bytes4(bytes(handle));

        string memory name = string(
            abi.encodePacked(handle, Constants.INVEST_NFT_NAME_INFIX, projectId.toString())
        );
        // TODO use proejct handles
        string memory symbol = string(
            abi.encodePacked(firstBytes, Constants.INVEST_NFT_SYMBOL_INFIX, projectId.toString())
        );

        IInvestNFT(investNFT).initialize(profileId, projectId, name, symbol);
        emit Events.InvestNFTDeployed(profileId, projectId, investNFT, block.timestamp);

        return investNFT;
    }

    function _emitInvestedEvent(
        address investor,
        uint256 profileId,
        uint256 projectId,
        bytes calldata moduleData,
        uint256 value,
        address[] calldata erc20s,
        uint256[] calldata amounts
    ) private {
        emit Events.Invested(
            investor,
            profileId,
            projectId,
            // TODO cache, calling ownerOF here instead of in invest method to avoid stack too deep error
            IBuidlHub(address(this)).ownerOf(profileId),
            moduleData,
            value,
            erc20s,
            amounts,
            block.timestamp
        );
    }

    function _transferFundsTo(
        address recipient,
        uint256 value,
        address[] calldata erc20s,
        uint256[] calldata amounts
    ) internal {
        if (value != 0) {
            (bool success, ) = payable(recipient).call{value: value}("");
            if (!success) {
                revert Errors.FundTransferFailed();
            }
        }
        for (uint256 i = 0; i < erc20s.length; ) {
            address currency = erc20s[i];
            uint256 amount = amounts[i];
            IERC20(currency).safeTransferFrom(msg.sender, recipient, amount);
            unchecked {
                i++;
            }
        }
    }

    function getYieldTrustHash(uint256 profileId, address currency) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(profileId, currency));
    }

    function _deployYTVault(
        address vaultImpl,
        string memory handle,
        uint256 profileId,
        address currency,
        address yieldSource
    ) internal returns (address) {
        address vault = Clones.clone(vaultImpl);

        bytes4 firstBytes = bytes4(bytes(handle));

        string memory name = string(
            abi.encodePacked(handle, Constants.YIELD_TRUST_VAULT_NAME_INFIX, profileId.toString())
        );
        string memory symbol = string(
            abi.encodePacked(
                firstBytes,
                Constants.YIELD_TRUST_VAULT_SYMBOL_INFIX,
                profileId.toString()
            )
        );

        IYieldTrustVault(vault).initialize(profileId, currency, yieldSource, name, symbol);

        emit Events.YieldSourceVaultDeployed(
            profileId,
            currency,
            vault,
            yieldSource,
            block.timestamp
        );

        return vault;
    }
}
