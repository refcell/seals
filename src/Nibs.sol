// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {ERC20} from "@solmate/tokens/ERC20.sol";

/// @title Nibs
/// @notice Project Shares for a given bloc
/// @notice Adapted from LilJuicebox in https://github.com/m1guelpf/lil-web3
/// @author Andreas Bigger <andreas@nascent.xyz>
contract Nibs is ERC20 {

  /// >>>>>>>>>>>>>>>>>>>>  CUSTOM ERRORS  <<<<<<<<<<<<<<<<<<<<< ///
	
  /// @notice Prevents unauthorized token minting or burning
	error Unauthorized();

  /// >>>>>>>>>>>>>>>>>>>>>  IMMUTABLES  <<<<<<<<<<<<<<<<<<<<<<< ///

	/// @notice The bloc that maps to this nibs
	address public immutable bloc;

  /// >>>>>>>>>>>>>>>>>>>>>  CONSTRUCTOR  <<<<<<<<<<<<<<<<<<<<<< ///

	/// @notice Deploys Nibs with the name and symbol metadata
  /// @dev Deployed from the Floe Factory
	/// @param name The name of the deployed token
	/// @param symbol The symbol of the deployed token
  /// @param bloc_ The bloc that manages this contract
	constructor(string memory name, string memory symbol, address bloc_) payable ERC20(name, symbol, 18) {
		bloc = bloc_;
	}

  /// >>>>>>>>>>>>>>>>>>  MINTING & BURNING  <<<<<<<<<<<<<<<<<<< ///

	/// @notice Grants the specified address a specified amount of tokens
	/// @dev This function will revert if not called from bloc
	/// @param to The address that will receive the tokens
	/// @param amount the amount of tokens to receive
	function chunk(address to, uint256 amount) public payable {
		if (msg.sender != bloc) revert Unauthorized();

		_mint(to, amount);
	}

	/// @notice Burns a specified amount of tokens from a specified address' balance
  /// @dev This function will revert if not called from bloc
	/// @param from The address that will get their tokens burned
	/// @param amount the amount of tokens to burn
	function melt(address from, uint256 amount) public payable {
		if (msg.sender != bloc) revert Unauthorized();

		_burn(from, amount);
	}
}
