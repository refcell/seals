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
	/// @param name The name of the Quorum Authority
	/// @param signers An array of addresses to trust
	/// @param _quorum The number of required signatures to execute a transaction or change the state
  /// @param seal_ The Seal that manages this contract
  /// @param coinage_ The coinage that this lockbox controls
	constructor(
    string memory name,
		address[] memory signers,
		uint256 _quorum,
    address seal_,
    address coinage_
  )
    QuorumAuthority(
      name,
      signers,
      _quorum,
      Auth(seal_).owner(),
      Auth(seal_).authority()
    )
  {
    seal = seal_;
    coinage = coinage_;
  }

  /// >>>>>>>>>>>>>>>>>>>>>>>  CORKING  <<<<<<<<<<<<<<<<<<<<<<<< ///

  /// @notice Deposits coinage into the Coffer
  /// @dev Can only be called by an authority
  /// @dev Can always be called by seal since it is the owner
  /// @dev Reverts on ERC20 balance underflow
  /// @param beneficiary The address to attribute the deposit
  function cork(address beneficiary) payable external requiresAuth {
    if (coinage == address(0)) balance[beneficiary] += msg.value;
    else balance[beneficiary] += (IERC20(coinage).balanceOf(address(this)) - coinBalance);
  }

  /// @notice Withdraws coinage from the Coffer
  /// @dev Can only be called by an authority
  /// @param deductee The address to deduct the withdrawal
  /// @param nibbles The amount of coinage to withdraw
  function uncork(address deductee, uint256 nibbles) external requiresAuth {

    // Remove from balance
    balance[deductee] -= nibbles;

    // Transfer to the deductee
    if (coinage == address(0)) {
      (bool sent, bytes memory data) = deductee.call{value: nibbles}("");
      if (!sent) revert JammedCork();
    } else {
      IERC20(coinage).transferFrom(address(this), deductee, nibbles);
    }

    // Remove from the total coin balance
    // Comes after to prevent corking reentry
    coinBalance -= nibbles;
  }

  /// >>>>>  AUTHORITY INHERITED THROUGH QUORUMAUTHORITY  <<<<<< ///

}
