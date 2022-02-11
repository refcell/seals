// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {IERC20} from "./interfaces/IERC20.sol";
import {QuorumAuthority} from "./authorities/QuorumAuthority.sol";

import {Auth} from "@solmate/auth/Auth.sol";

/// @title Coffer
/// @notice A Lockbox Contract that stores auction collaterals
/// @dev Uses Auth patterns as demonstrated in https://github.com/Rari-Capital/vaults/blob/main/src/Vault.sol
/// @author Andreas Bigger <andreas@nascent.xyz>
contract Coffer is QuorumAuthority {

  /// >>>>>>>>>>>>>>>>>>>>  CUSTOM ERRORS  <<<<<<<<<<<<<<<<<<<<< ///

	/// @notice Thrown when the provided signatures are invalid, duplicated, or out of order
	error InvalidSignatures();

	/// @notice Thrown when the execution of the requested transaction fails
	error ExecutionFailed();

  /// @notice Thrown when uncork fails
  error JammedCork();

  /// >>>>>>>>>>>>>>>>>>>>  CUSTOM EVENTS  <<<<<<<<<<<<<<<<<<<<< ///

	/// @notice Emitted when a deposit is made
  /// @param depositor The msg.sender
  /// @dev The depositor must be an authority
  event Deposit(address depositor);

  /// >>>>>>>>>>>>>>>>>>>>>  IMMUTABLES  <<<<<<<<<<<<<<<<<<<<<<< ///

	/// @notice The Seal that manages this Coffer
	address public immutable seal;

  /// @notice The accepted coinage for the Coffer
  address public immutable coinage;

  /// >>>>>>>>>>>>>>>>>>>>>>>  STATE  <<<<<<<<<<<<<<<<<<<<<<<<<< ///

	/// @notice User Balances
  mapping(address => uint256) public balance;

  /// @notice The total coinage balance
  uint256 public coinBalance;

  /// >>>>>>>>>>>>>>>>>>>>>  CONSTRUCTOR  <<<<<<<<<<<<<<<<<<<<<< ///

	/// @notice Deploys Coffer
  /// @dev Initiates the Auth Module with seal_ as the sole authority
  /// @dev Deployed from the Floe Factory
  /// @param seal_ The Seal that manages this contract
	constructor(address seal_)
    QuorumAuthority(
      Auth(seal_).owner(),
      Auth(seal_).authority()
    )
  {}

  /// >>>>>>>>>>>>>>>>>>>>>>>  CORKING  <<<<<<<<<<<<<<<<<<<<<<<< ///

  /// @notice Deposits coinage into the Coffer
  /// @dev Can only be called by an authority
  /// @dev Reverts on ERC20 balance underflow
  /// @param beneficiary The address to attribute the deposit
  function cork(address calldata beneficiary) public external requiresAuth {
    if (coinage == address(0)) balance[beneficiary] += msg.value;
    else balance[beneficiary] += (IERC20(coinage).balanceOf(address(this)) - coinBalance);
  }

  /// @notice Withdraws coinage from the Coffer
  /// @dev Can only be called by an authority
  /// @param deductee The address to deduct the withdrawal
  /// @param nibbles The amount of coinage to withdraw
  function uncork(address calldata deductee, uint256 calldata nibbles) external requiresAuth {

    // Remove from balance
    balance[deductee] -= nibbles;

    // Transfer to the deductee
    if (coinage == address(0)) {
      (bool sent, bytes memory data) = _to.call{value: nibbles}("");
      if (!sent) revert JammedCork();
    } else {
      IERC20(coinage).safeTransferFrom(address(this), deductee, nibbles);
    }

    // Remove from the total coin balance
    // Comes after to prevent corking reentry
    coinBalance -= nibbles;
  }

  /// >>>>>  AUTHORITY INHERITED THROUGH QUORUMAUTHORITY  <<<<<< ///

}
