// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {Auth} from "@solmate/auth/Auth.sol";

/// @title Coffer
/// @notice A Lockbox Contract that stores auction collaterals
/// @dev Uses Auth patterns as demonstrated in https://github.com/Rari-Capital/vaults/blob/main/src/Vault.sol
/// @dev Adapted from Lil Gnosis in https://github.com/m1guelpf/lil-web3
/// @author Andreas Bigger <andreas@nascent.xyz>
contract Coffer is Auth {

  /// >>>>>>>>>>>>>>>>>>>>  CUSTOM ERRORS  <<<<<<<<<<<<<<<<<<<<< ///

	/// @notice Thrown when the provided signatures are invalid, duplicated, or out of order
	error InvalidSignatures();

	/// @notice Thrown when the execution of the requested transaction fails
	error ExecutionFailed();

  /// >>>>>>>>>>>>>>>>>>>>  CUSTOM EVENTS  <<<<<<<<<<<<<<<<<<<<< ///

	/// @notice Emitted when the number of required signatures is updated
	/// @param newQuorum The new amount of required signatures
	event QuorumUpdated(uint256 newQuorum);

	/// @notice Emitted when a new transaction is executed
	/// @param target The address the transaction was sent to
	/// @param value The amount of ETH sent in the transaction
	/// @param payload The data sent in the transaction
	event Executed(address target, uint256 value, bytes payload);

	/// @notice Emitted when a new signer gets added or removed from the trusted signers
	/// @param signer The address of the updated signer
	/// @param shouldTrust Wether the contract will trust this signer going forwards
	event SignerUpdated(address indexed signer, bool shouldTrust);

  /// >>>>>>>>>>>>>>>>>>>>>  IMMUTABLES  <<<<<<<<<<<<<<<<<<<<<<< ///

	/// @notice The Seal that manages this Coffer
	address public immutable seal;

  /// >>>>>>>>>>>>>>>>>>>>>  CONSTRUCTOR  <<<<<<<<<<<<<<<<<<<<<< ///

	/// @notice Deploys Coffer
  /// @dev Initiates the Auth Module with seal_ as the sole authority
  /// @dev Deployed from the Floe Factory
  /// @param seal_ The Seal that manages this contract
	constructor(address seal_)
    Auth(
      Auth(seal_).owner(),
      Auth(seal_).authority()
    )
  {}

  /// @notice Can deposit to this contract
  function 
}
