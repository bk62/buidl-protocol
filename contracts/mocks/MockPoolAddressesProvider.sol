// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {IAavePoolAddressesProvider} from "../defi/IAavePoolAddressesProvider.sol";

contract MockPoolAddressesProvider is IAavePoolAddressesProvider {
    address public _pool;

    constructor(address pool_) {
        _pool = pool_;
    }

    function getPool() public view override returns (address) {
        return _pool;
    }
}
