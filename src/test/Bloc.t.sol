// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {Bloc} from "../Bloc.sol";

contract BlocTest is DSTestPlus {
    Bloc bloc;

    function setUp() public {
        bloc = new Bloc();
    }
}
