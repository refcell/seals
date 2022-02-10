// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.11;

import {ERC20} from "@solmate/tokens/ERC20.sol";

/// @title Nibs
/// @notice Project Shares for a given Seal
/// @author Andreas Bigger <andreas@nascent.xyz>
contract Nibs is ERC20{
	/// ERRORS ///

	/// @notice Thrown when trying to directly call the mint or burn functions
	error Unauthorized();

	/// @notice The manager of this campaign
	address public immutable manager;

	/// @notice Deploys a ProjectShare instance with the specified name and symbol
	/// @param name The name of the deployed token
	/// @param symbol The symbol of the deployed token
	/// @dev Deployed from the constructor of the LilJuicebox contract
	constructor(string memory name, string memory symbol) payable ERC20(name, symbol, 18) {
		manager = msg.sender;
	}

	/// @notice Grants the specified address a specified amount of tokens
	/// @param to The address that will receive the tokens
	/// @param amount the amount of tokens to receive
	/// @dev This function should be called from within LilJuicebox, and will revert if manually accessed
	function mint(address to, uint256 amount) public payable {
		if (msg.sender != manager) revert Unauthorized();

		_mint(to, amount);
	}

	/// @notice Burns a specified amount of tokens from a specified address' balance
	/// @param from The address that will get their tokens burned
	/// @param amount the amount of tokens to burn
	/// @dev This function should be called from within LilJuicebox, and will revert if manually accessed
	function burn(address from, uint256 amount) public payable {
		if (msg.sender != manager) revert Unauthorized();

		_burn(from, amount);
	}
}
