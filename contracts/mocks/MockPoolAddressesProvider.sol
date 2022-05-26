// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

interface IMockPoolAddressesProvider {
    function getPool() external returns (address);
}

contract MockPoolAddressesProvider is IMockPoolAddressesProvider {
    address public _pool;

    constructor(address pool_) {
        _pool = pool_;
    }

    function getPool() external override returns (address) {
        return _pool;
    }
}
