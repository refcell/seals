
  
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {ClonesWithImmutableArgs} from "@clones/ClonesWithImmutableArgs.sol";

// Clone Implementation Imports
import {Bloc} from "./Bloc.sol";
import {Nibs} from "./Nibs.sol";
import {Coffer} from "./Coffer.sol";

/// >>>>>>>>>>>>>>>>>>>>>>>>>  FLOE  <<<<<<<<<<<<<<<<<<<<<<<<< ///

/// @title Floe
/// @notice A floating sheet of ice where seals are spawned
/// @author Andreas Bigger <andreas@nascent.xyz>
/// @dev Adapted from https://github.com/ZeframLou/vested-erc20/blob/main/src/VestedERC20Factory.sol
contract Floe {

  /// @dev Use CloneWithCallData library for cheap deployment
  /// @dev Uses a modified minimal proxy pattern
  using ClonesWithImmutableArgs for address;

  /// >>>>>>>>>>>>>>>>>>>>  CUSTOM ERRORS  <<<<<<<<<<<<<<<<<<<<< ///

  /// Duplicate Seal
  /// @param sender The message sender
  /// @param token The address of the ERC721 Token
  error DuplicateSeal(address sender, address token);

  /// Not Approved
  /// The sender is not approved to create the session for the given ERC721 token
  /// @param sender The message sender
  /// @param approved The address of the approved creator
  /// @param token The address of the ERC721 Token
  error NotApproved(address sender, address approved, address token);

  /// Bad Session Bounds
  /// @param allocationStart The session's allocation period start
  /// @param allocationEnd The session's allocation period end
  /// @param mintingStart The session's minting period start
  /// @param mintingEnd The session's minting period end
  error BadSessionBounds(uint64 allocationStart, uint64 allocationEnd, uint64 mintingStart, uint64 mintingEnd);

  /// Require the ERC721 tokens to already be transferred to the twam contract
  /// Enables permissionless session creation
  /// @param balanceOfThis The ERC721 balance of the twam contract
  /// @param maxMintingAmount The maxmum number of ERC721s to mint
  error RequireMintedERC721Tokens(uint256 balanceOfThis, uint256 maxMintingAmount);

  /// Session Overwrite
  error SessionOverwrite();

  /// Sender is not owner
  error SenderNotOwner();

  /// >>>>>>>>>>>>>>>>>>>>  CUSTOM EVENTS  <<<<<<<<<<<<<<<<<<<<< ///

  /// @dev Emit a creation event to track twams
  event SealDeployed(uint256 id);

  /// >>>>>>>>>>>>>>>>>>>>>>>  STATE  <<<<<<<<<<<<<<<<<<<<<<<<<< ///

  /// @notice The bloc base implementation
  Bloc public immutable bloc;

  /// @notice The nibs base implementation
  Nibs public immutable nibs;

  /// @notice The coffer base implementation
  Coffer public immutable coffer;

  /// @dev Only addresses that have transferred the erc721 tokens to this address can create a session
  /// @dev Maps ERC721 => user
  mapping(address => address) public approvedCreator;

  /// @notice Tracks created TWAM sessions
  /// @dev Maps ERC721 => deployed TwamBase Contract
  mapping(address => address) public createdTwams;

  /// @notice Tracks TWAM Sessions by ID
  mapping(uint256 => address) public sessions;

  /// @notice The next session ID
  /// @dev initialized to 1 for cheaper initial loads
  uint256 public sessionId = 1;

  /// >>>>>>>>>>>>>>>>>>>>>  CONSTRUCTOR  <<<<<<<<<<<<<<<<<<<<<< ///

  /// @notice Creates the Factory with the clone modules
  /// @param bloc_ The bloc base implementation
  /// @param nibs_ The nibs base implementation
  /// @param coffer_ The coffer base implementation
  constructor(
    Bloc bloc_,
    Nibs nibs_,
    Coffer coffer_
  ) {
    bloc = bloc_;
    nibs = nibs_;
    coffer = coffer_;
  }

  /// >>>>>>>>>>>>>>>>>>>>  CREATION LOGIC  <<<<<<<<<<<<<<<<<<<< ///

  /// @notice Creates a Seal - {Bloc, Coffer, Nibs}
  /// @param token The ERC721 Token
  /// @param coordinator The session coordinator who controls the session
  /// @param allocationStart When the allocation period begins
  /// @param allocationEnd When the allocation period ends
  /// @param mintingStart When the minting period begins
  /// @param mintingEnd When the minting period ends
  /// @param minPrice The minimum token price for minting
  /// @param depositToken The token to pay for minting
  /// @param maxMintingAmount The maximum amount of tokens to mint (must be minted to this contract)
  /// @param rolloverOption What happens when the minting period ends and the session is over; one of {1, 2, 3}
  function spawn(
    address token,
    address coordinator,
    uint64 allocationStart,
    uint64 allocationEnd,
    uint64 mintingStart,
    uint64 mintingEnd,
    uint256 minPrice,
    address depositToken,
    uint256 maxMintingAmount,
    uint8 rolloverOption
  ) external returns (
    Bloc bloc,
    Coffer coffer,
    Nibs nibs
  ) {
    // // Prevent Overwriting Sessions
    // if (createdTwams[token] != address(0) || token == address(0)) {
    //   revert DuplicateSession(msg.sender, token);
    // }

    // // For Permissionless Session Creation
    // // We check that the sender is the approvedCreator
    // if (approvedCreator[token] != msg.sender) {
    //   revert NotApproved(msg.sender, approvedCreator[token], token);
    // }

    // // We also have to make sure this address has a sufficient balance of ERC721 tokens for the session
    // // This can be done by setting the ERC721.balanceOf(address(TwamFactory)) to the maxMintingAmount on ERC721 contract deployment
    // uint256 balanceOfThis = IERC721(token).balanceOf(address(this));
    // if (balanceOfThis < maxMintingAmount) revert RequireMintedERC721Tokens(balanceOfThis, maxMintingAmount);

    // // Validate Session Bounds
    // if (
    //   allocationStart > allocationEnd
    //   || mintingStart > mintingEnd
    //   || mintingStart < allocationEnd
    // ) {
    //   revert BadSessionBounds(allocationStart, allocationEnd, mintingStart, mintingEnd);
    // }

    // // We can abi encodePacked instead of manually packing
    // bytes memory data = abi.encodePacked(
    //   token,
    //   coordinator,
    //   allocationStart,
    //   allocationEnd,
    //   mintingStart,
    //   mintingEnd,
    //   minPrice,
    //   maxMintingAmount,
    //   depositToken,
    //   rolloverOption,
    //   sessionId,
    //   address(this)
    // );

    // // Create the TWAM
    // twamBase = TwamBase(
    //     address(implementation).clone(data)
    // );
    // emit TwamDeployed(twamBase);

    // // Set approval for all the ERC721 Tokens
    // IERC721(token).setApprovalForAll(address(twamBase), true);

    // // Record Creation
    // createdTwams[token] = address(twamBase);
    // sessions[sessionId] = address(twamBase);
    // sessionId += 1;
  }
}