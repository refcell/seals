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

  /// @notice The resulting user appraisals
  mapping(address => uint256) public reveals;

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
  function reveal(uint256 appraisal, bytes32 blindingFactor) external {
      // Verify during reveal+mint phase
      if (block.timestamp < revealStart || block.timestamp >= restrictedMintStart) revert WrongPhase();

      bytes32 senderCommit = commits[msg.sender];

      bytes32 calculatedCommit = keccak256(abi.encodePacked(msg.sender, appraisal, blindingFactor));

      if (senderCommit != calculatedCommit) revert InvalidHash();

      // The user has revealed their correct value
      delete commits[msg.sender];
      reveals[msg.sender] = appraisal;

      // Add the appraisal to the result value and recalculate variance
      // Calculation adapted from https://math.stackexchange.com/questions/102978/incremental-computation-of-standard-deviation
      if (count == 0) {
        clearingPrice = appraisal;
      } else {
        uint256 clearingPrice_ = clearingPrice;
        uint256 newClearingPrice = (count * clearingPrice_ + appraisal) / (count + 1);

        uint256 carryTerm = count * rollingVariance;
        uint256 clearingDiff = clearingPrice_ > newClearingPrice ?  clearingPrice_ - newClearingPrice : newClearingPrice - clearingPrice_;
        uint256 deviationUpdate = count * (clearingDiff ** 2);
        uint256 meanUpdate = appraisal < newClearingPrice ? newClearingPrice - appraisal : appraisal - newClearingPrice;
        uint256 updateTerm = meanUpdate ** 2;
        rollingVariance = (deviationUpdate + carryTerm + updateTerm) / (count + 1);

        // Update clearingPrice_ (new mean)
        clearingPrice = newClearingPrice;
      }
      unchecked {
        count += 1;
      }

      // Emit a Reveal Event
      emit Reveal(msg.sender, appraisal);
  }

}
