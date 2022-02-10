// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {Auth} from "@solmate/auth/Auth.sol";

/// @title Coffer
/// @notice A Lockbox Contract that stores auction collaterals
/// @notice Uses Auth patterns as demonstrated in https://github.com/Rari-Capital/vaults/blob/main/src/Vault.sol
/// @author Andreas Bigger <andreas@nascent.xyz>
contract Coffer is Auth {
	/// @notice Prevents unauthorized token minting or burning
	error Unauthorized();

	/// @notice The Seal that manages this Coffer
	address public immutable seal;

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

  // TODO: deposits and withdrawals
}
