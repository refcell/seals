// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {ERC20} from "@solmate/tokens/ERC20.sol";

/// @title Nibs
/// @notice Project Shares for a given Seal
/// @notice Adapted from LilJuicebox in https://github.com/m1guelpf/lil-web3
/// @author Andreas Bigger <andreas@nascent.xyz>
contract Nibs is ERC20{
	/// @notice Prevents unauthorized token minting or burning
	error Unauthorized();

	/// @notice The Seal that maps to this nibs
	address public immutable seal;

	/// @notice Deploys Nibs with the name and symbol metadata
	/// @param name The name of the deployed token
	/// @param symbol The symbol of the deployed token
  /// @param seal_ The Seal that manages this contract
	/// @dev Deployed from the constructor of the LilJuicebox contract
	constructor(string memory name, string memory symbol, address seal_) payable ERC20(name, symbol, 18) {
		seal = seal_;
	}

	/// @notice Grants the specified address a specified amount of tokens
	/// @dev This function will revert if not called from Seal
	/// @param to The address that will receive the tokens
	/// @param amount the amount of tokens to receive
	function mint(address to, uint256 amount) public payable {
		if (msg.sender != seal) revert Unauthorized();

		_mint(to, amount);
	}

	/// @notice Burns a specified amount of tokens from a specified address' balance
  /// @dev This function will revert if not called from Seal
	/// @param from The address that will get their tokens burned
	/// @param amount the amount of tokens to burn
	function burn(address from, uint256 amount) public payable {
		if (msg.sender != seal) revert Unauthorized();

		_burn(from, amount);
	}
}
