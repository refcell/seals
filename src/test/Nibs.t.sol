// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {Bloc} from "../Bloc.sol";
import {Nibs} from "../Nibs.sol";

contract NibsTest is DSTestPlus {
  Nibs nibs;
  Bloc bloc;

  /// @dev Mock ERC20 Token Receiver
  address public receiver = address(1337);

  /// >>>>>>>>>>>>>>>>>>>>>  METADATA  <<<<<<<<<<<<<<<<<<<<<<< ///

  string public constant NIBS_NAME = "Seal Nibs";
  string public constant NIBS_SYMBOL = "NIBS";

  /// >>>>>>>>>>>>>>>>>>>>  PRECURSORS  <<<<<<<<<<<<<<<<<<<<<< ///

  function setUp() public {
      // Create Empty Bloc First
      bloc = new Bloc();
      nibs = new Nibs(
        NIBS_NAME,
        NIBS_SYMBOL,
        address(bloc)
      );

      // Validate Metadata
      assert(keccak256(abi.encodePacked(nibs.name())) == keccak256(abi.encodePacked(NIBS_NAME)));
      assert(keccak256(abi.encodePacked(nibs.symbol())) == keccak256(abi.encodePacked(NIBS_SYMBOL)));
  }

  /// >>>>>>>>>>>>>>>>>>  MINTING & BURNING  <<<<<<<<<<<<<<<<<<< ///

  /// @notice Tests chunk - minting project shares
  function testChunk() public {
    // We should be able to chunk from the bloc context
    startHoax(address(bloc), address(bloc), type(uint256).max);
    nibs.chunk(receiver, 1337);
    // TODO: check balance
    vm.stopPrank();
  }
}
