// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {Auth} from "@solmate/auth/Auth.sol";


///                        \ | /                        ///
///                       -- * --                       ///
///                        / | \                        ///
///                                                     ///
///         /')    ./')             ('\.    ('\         ///
///       /' /.--''./'')           (''\.''--.\ '\       ///
///  :--''  ;    ''./'')           (''\.''    ;  ''--:  ///
///  :     '     ''./')             ('\.''     '     :  ///
///  :           ''./'               '\.''           :  ///
///  :--''-..--''''                     ''''--..-''--:  ///


/// @title Bloc
/// @notice Sealed Commitment Auctions with Overcollateralized Bid Bands.
/// @notice bloc - A combination of countries, parties, or groups sharing a common purpose.
/// @author Andreas Bigger <andreas@nascent.xyz>
contract Bloc is Auth {

  /// >>>>>>>>>>>>>>>>>>>>  CUSTOM ERRORS  <<<<<<<<<<<<<<<<<<<<< ///

    error NotAuthorized();
    error WrongFrom();
    error InvalidRecipient();
    error UnsafeRecipient();
    error AlreadyMinted();
    error NotMinted();
    error InsufficientDeposit();
    error WrongPhase();
    error InvalidHash();
    error InsufficientPrice();
    error InsufficientValue();
    error InvalidAction();
    error SoldOut();
    error Outlier();
    error MaxTokensMinted();

  /// >>>>>>>>>>>>>>>>>>>>  CUSTOM EVENTS  <<<<<<<<<<<<<<<<<<<<< ///

  event Commit(address indexed from, bytes32 commitment);

  event Reveal(address indexed from, uint256 low, uint256 high);

  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

  event Approval(address indexed owner, address indexed spender, uint256 indexed tokenId);

  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  /// >>>>>>>>>>>>>>>>>>>>>  IMMUTABLES  <<<<<<<<<<<<<<<<<<<<<<< ///

  /// @notice Deposit Reserve Amount
  uint256 public immutable cache;

  /// @notice Commit Start Timestamp
  uint256 public immutable commit;

  /// @notice Reveal Start Timestamp
  uint256 public immutable reveal;

  /// @notice Bidding Period Timestamp
  uint256 public immutable arbitration;

  /// @notice Optional ERC20 Deposit Token
  address public immutable chips;

  /// >>>>>>>>>>>>>>>>>>>>  CUSTOM STORAGE  <<<<<<<<<<<<<<<<<<<< ///

  /// @notice User Commitments
  mapping(address => bytes32) public commits;

  /// @notice A participant's revealed lower band
  mapping(address => uint256) public lreveals;

  /// @notice A participant's revealed high band
  mapping(address => uint256) public hreveals;

  /// @notice Maps if a member accepted project shares
  mapping(address => uint256) public fellows;

  /// >>>>>>>>>>>>>>>>>>>>>  CONSTRUCTOR  <<<<<<<<<<<<<<<<<<<<<< ///

  constructor()
  Auth(
    Auth(msg.sender).owner(),
    Auth(msg.sender).authority()
  )
  {}

  /// >>>>>>>>>>>>>>>>>>>>>  COMMIT LOGIC  <<<<<<<<<<<<<<<<<<<<< ///

  /// @notice Commit is payable to require the deposit amount
  function commit(bytes32 commitment) external payable {
      // Make sure the user has placed the deposit amount
      if (depositToken == address(0) && msg.value < depositAmount) revert InsufficientDeposit();

      // Verify during commit phase
      if (block.timestamp < commitStart || block.timestamp >= revealStart) revert WrongPhase();

      // Transfer the deposit token into this contract
      if (depositToken != address(0)) {
        IERC20(depositToken).transferFrom(msg.sender, address(this), depositAmount);
      }

      // Store Commitment
      commits[msg.sender] = commitment;

      // Emit the commit event
      emit Commit(msg.sender, commitment);
  }

  /// @notice Revealing a commitment
  function reveal(
    uint256 low,
    uint256 high,
    bytes32 blind
  ) external {
    // Optimized MSTORE timestamp use 
    uint256 time = block.timestamp;

    // Verify during the reveal phase
    if (time < reveal || time >= arbitration) revert WrongPhase();

    // Optimized Commit SLOAD 
    bytes32 senderCommit = commits[msg.sender];

    // rehash the commitment
    bytes32 calculatedCommit = keccak256(abi.encodePacked(msg.sender, low, high, blind));

    // Validate commitment
    // Prevent's double reveals by reverting zero commitments
    if (senderCommit == bytes32(0) || senderCommit != calculatedCommit) revert InvalidHash();

    // The user has revealed their correct value
    delete commits[msg.sender];
    lreveals[msg.sender] = low;
    hreveals[msg.sender] = high;

    // "Humanity will be a Type III civilization before this overflows" - andreas
    // h/t 0xsat @ https://twitter.com/0xsat/status/1492927005901340672?s=20&t=9jslhLz9C45Qqa1z9VbHYA
    unchecked {
      count += 1;
    }
  
    // Emit a Reveal Event
    emit Reveal(msg.sender, low, high);
  }

  /// >>>>>>>>>>>>>>>>>>>>  STAMP <> RECEDE  <<<<<<<<<<<<<<<<<<< ///

  /// @notice Accepts the given bid
  function stamp(

  ) external {
    // Check past the reveal phase
    if(block.timestamp < arbitration) revert WrongPhase();

    // Check the user revealed
    if(reveals[msg.sender] != 0)
  }
}
