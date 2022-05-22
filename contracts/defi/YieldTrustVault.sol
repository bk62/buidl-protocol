// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import {IBuidlHub} from "../interfaces/IBuidlHub.sol";
import {Errors} from "../libraries/Errors.sol";
import {Events} from "../libraries/Events.sol";
import {DataTypes} from "../libraries/DataTypes.sol";

import "./IYieldTrustVault.sol";

contract YieldTrustVault is ReentrancyGuardUpgradeable, ERC20Upgradeable, IYieldTrustVault {
    using SafeERC20 for IERC20Metadata;
    using Address for address;

    // Globals:
    address public immutable hub;

    // underlying asset
    IERC20Metadata internal _asset;
    // total current deposits -- deposits - withdrawals
    // does not include any yield!
    // used to track amount claimable/withdrawable by recipient
    uint256 internal _currentDeposits;

    // yield source
    address internal _yieldSource;
    // Profile NFT tokenID that is the yield recipient
    uint256 internal _profileId;

    // Modifiers:
    modifier onlyHub() {
        if (msg.sender != hub) revert Errors.NotHub();
        _;
    }

    modifier onlyRecipient() {
        if (msg.sender != yieldRecipient()) revert Errors.NotAllowed();
        _;
    }

    // Created w/ pre-computed hub address
    constructor(address hub_) {
        if (hub_ == address(0)) revert Errors.ConstructorParamsInvalid();
        hub = hub_;
    }

    /// @inheritdoc IYieldTrustVault
    function initialize(
        uint256 profileId_,
        address underlyingERC20_,
        address yieldSource_,
        string calldata name,
        string calldata symbol
    ) external override initializer {
        if (profileId_ == 0) revert Errors.ConstructorParamsInvalid();
        if (underlyingERC20_ == address(0)) revert Errors.ConstructorParamsInvalid();
        if (yieldSource_ == address(0)) revert Errors.ConstructorParamsInvalid();

        _profileId = profileId_;
        _asset = IERC20Metadata(underlyingERC20_);
        _yieldSource = yieldSource_;

        __ReentrancyGuard_init();

        __ERC20_init_unchained(name, symbol);
    }

    /// @inheritdoc ERC20Upgradeable
    function decimals() public view virtual override returns (uint8) {
        return _asset.decimals();
    }

    // ERC-4626 methods:

    /// @inheritdoc IERC4626
    function asset() public view override returns (address) {
        return address(_asset);
    }

    /// @inheritdoc IERC4626
    function totalAssets() public view override returns (uint256) {
        // TODO yield source balance
        return
            _asset.balanceOf(address(this)) + IERC20Metadata(_yieldSource).balanceOf(address(this));
    }

    /// @inheritdoc IERC4626
    function convertToShares(uint256 assets) public pure override returns (uint256) {
        // always 1:1
        return assets;
    }

    /// @inheritdoc IERC4626
    function convertToAssets(uint256 shares) public pure override returns (uint256) {
        // always 1:1
        return shares;
    }

    /// @inheritdoc IERC4626
    function maxDeposit(address) public pure override returns (uint256) {
        return type(uint256).max;
    }

    /// @inheritdoc IERC4626
    function previewDeposit(uint256 assets) public pure override returns (uint256) {
        return assets;
    }

    function maxMint(address) public pure override returns (uint256) {
        return type(uint256).max;
    }

    function previewMint(uint256 shares) public pure override returns (uint256) {
        return shares;
    }

    function maxWithdraw(address owner) public view override returns (uint256) {
        return balanceOf(owner);
    }

    function previewWithdraw(uint256 assets) public pure override returns (uint256) {
        return assets;
    }

    function maxRedeem(address owner) public view virtual override returns (uint256) {
        return balanceOf(owner);
    }

    function previewRedeem(uint256 shares) public pure override returns (uint256) {
        return shares;
    }

    // Deposit/withdraw methods:

    function deposit(uint256 assets, address receiver)
        public
        override
        nonReentrant
        returns (uint256)
    {
        // shares:assets = 1:1
        _deposit(assets, receiver);
        return assets;
    }

    function mint(uint256 shares, address receiver) public override nonReentrant returns (uint256) {
        // shares:assets = 1:1
        _deposit(shares, receiver);
        return shares;
    }

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public override nonReentrant returns (uint256) {
        // shares:assets = 1:1
        _withdraw(assets, receiver, owner);
        return assets;
    }

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public override nonReentrant returns (uint256) {
        // shares:assets = 1:1
        _withdraw(shares, receiver, owner);
        return shares;
    }

    // IYieldTrustVault methods:

    /// @inheritdoc IYieldTrustVault
    function yieldSource() external view override returns (address) {
        return _yieldSource;
    }

    /// @inheritdoc IYieldTrustVault
    function profileId() external view override returns (uint256) {
        return _profileId;
    }

    /// @inheritdoc IYieldTrustVault
    function yieldRecipient() public view override returns (address) {
        return IBuidlHub(hub).ownerOf(_profileId);
    }

    /// @inheritdoc IYieldTrustVault
    function batchDeposit() external override returns (uint256) {
        uint256 assetBalance = _asset.balanceOf(address(this));
        _asset.safeApprove(address(_yieldSource), assetBalance);
        // _yieldSource.deposit(address(this), assetBalance); // TODO
        emit YieldSourceBatchDeposit(assetBalance);
        return assetBalance;
    }

    /// @inheritdoc IYieldTrustVault
    function claimYield(uint256 amount) external override onlyRecipient returns (uint256) {
        // yield = current vault assets - total deposited assets;
        uint256 maxYieldAmount = totalAssets() - _currentDeposits;
        if (amount > maxYieldAmount) revert Errors.InsufficientBalance();
        // if un-deposited balance >= yield, transfer yield to recipient
        // else, withdraw (yield - un-deposited balance), transfer to recipient
        _ensureContractAssetBalance(amount);
        _asset.safeTransfer(yieldRecipient(), amount);
        emit YieldClaimed(msg.sender, amount);
    }

    // Internal:

    function _deposit(uint256 assetsOrShares, address receiver) internal {
        if (assetsOrShares < 0) revert Errors.ZeroAmounts();
        _asset.safeTransferFrom(msg.sender, address(this), assetsOrShares);
        _mint(receiver, assetsOrShares);

        _currentDeposits += assetsOrShares;

        emit Deposit(msg.sender, receiver, assetsOrShares, assetsOrShares);
    }

    function _withdraw(
        uint256 assetsOrShares,
        address receiver,
        address owner
    ) internal {
        if (assetsOrShares < 0) revert Errors.ZeroAmounts();
        if (balanceOf(owner) < assetsOrShares) revert Errors.InsufficientBalance();

        if (msg.sender != owner) {
            if (allowance(owner, msg.sender) < assetsOrShares)
                revert Errors.InsufficientAllowance();
        }

        _burn(owner, assetsOrShares);
        if (msg.sender != owner) {
            decreaseAllowance(msg.sender, assetsOrShares);
        }

        _ensureContractAssetBalance(assetsOrShares);

        _asset.safeTransfer(receiver, assetsOrShares);

        _currentDeposits -= assetsOrShares;

        emit Withdraw(msg.sender, receiver, owner, assetsOrShares, assetsOrShares);
    }

    function _ensureContractAssetBalance(uint256 balanceRequired) internal {
        uint256 currentBalance = _asset.balanceOf(address(this));
        if (currentBalance > balanceRequired) {
            return;
        }
        uint256 toWithdraw = balanceRequired - currentBalance;
        // withdraw from yield source
        // _yieldSource.withdraw(address(this), toWithdraw); // TODO

        emit YieldSourceWithdrawal(toWithdraw);
    }
}
