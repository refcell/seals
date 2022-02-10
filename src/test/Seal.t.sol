// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {Seal} from "../Seal.sol";

contract SealTest is DSTestPlus {
    Seal seal;

    function setUp() public {
        seal = new Seal();
    }
}
