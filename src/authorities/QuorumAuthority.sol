// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {Auth, Authority} from "@solmate/auth/Auth.sol";

/// @title QuorumAuthority
/// @notice Succinct Quorum Authority
/// @author Andreas Bigger <andreas@nascent.xyz>
contract QuorumAuthority is Auth, Authority {

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

  /// >>>>>>>>>>>>>>>>>>>>>>>  STATE  <<<<<<<<<<<<<<<<<<<<<<<<<< ///

	/// @dev Components of an Ethereum signature
	struct Signature {
		uint8 v;
		bytes32 r;
		bytes32 s;
	}

	/// @notice Signature nonce, incremented with each successful execution or state change
	/// @dev This is used to prevent signature reuse
	/// @dev Initialised at 1 because it makes the first transaction slightly cheaper
	uint256 public nonce = 1;

  /// @notice The amount of required signatures to execute a transaction or change the state
	uint256 public quorum;

	/// @notice A list of signers, and wether they're trusted by this contract
	/// @dev This automatically generates a getter for us!
	mapping(address => bool) public isSigner;

  /// >>>>>>>>>>>>>>>>>>>>>  IMMUTABLES  <<<<<<<<<<<<<<<<<<<<<<< ///

	/// @dev The EIP-712 domain separator
	bytes32 public immutable domainSeparator;

  /// @dev EIP-712 types for a signature that updates the quorum
	bytes32 public constant QUORUM_HASH = keccak256('UpdateQuorum(uint256 newQuorum,uint256 nonce)');

	/// @dev EIP-712 types for a signature that updates a signer state
	bytes32 public constant SIGNER_HASH = keccak256('UpdateSigner(address signer,bool shouldTrust,uint256 nonce)');

	/// @dev EIP-712 types for a signature that executes a transaction
	bytes32 public constant EXECUTE_HASH = keccak256('Execute(address target,uint256 value,bytes payload,uint256 nonce)');

  /// >>>>>>>>>>>>>>>>>>>>>  CONSTRUCTOR  <<<<<<<<<<<<<<<<<<<<<< ///





    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event UserRoleUpdated(address indexed user, uint8 indexed role, bool enabled);

    event PublicCapabilityUpdated(bytes4 indexed functionSig, bool enabled);

    event RoleCapabilityUpdated(uint8 indexed role, bytes4 indexed functionSig, bool enabled);

    event TargetCustomAuthorityUpdated(address indexed target, Authority indexed authority);

    /*///////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner, Authority _authority) Auth(_owner, _authority) {}

    /*///////////////////////////////////////////////////////////////
                       CUSTOM TARGET AUTHORITY STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => Authority) public getTargetCustomAuthority;

    /*///////////////////////////////////////////////////////////////
                            ROLE/USER STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => bytes32) public getUserRoles;

    mapping(bytes4 => bool) public isCapabilityPublic;

    mapping(bytes4 => bytes32) public getRolesWithCapability;

    function doesUserHaveRole(address user, uint8 role) public view virtual returns (bool) {
        return (uint256(getUserRoles[user]) >> role) & 1 != 0;
    }

    function doesRoleHaveCapability(uint8 role, bytes4 functionSig) public view virtual returns (bool) {
        return (uint256(getRolesWithCapability[functionSig]) >> role) & 1 != 0;
    }

    /*///////////////////////////////////////////////////////////////
                          AUTHORIZATION LOGIC
    //////////////////////////////////////////////////////////////*/

    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) public view virtual override returns (bool) {
        Authority customAuthority = getTargetCustomAuthority[target];

        if (address(customAuthority) != address(0)) return customAuthority.canCall(user, target, functionSig);

        return
            isCapabilityPublic[functionSig] || bytes32(0) != getUserRoles[user] & getRolesWithCapability[functionSig];
    }

    /*///////////////////////////////////////////////////////////////
               CUSTOM TARGET AUTHORITY CONFIGURATION LOGIC
    //////////////////////////////////////////////////////////////*/

    function setTargetCustomAuthority(address target, Authority customAuthority) public virtual requiresAuth {
        getTargetCustomAuthority[target] = customAuthority;

        emit TargetCustomAuthorityUpdated(target, customAuthority);
    }

    /*///////////////////////////////////////////////////////////////
                  PUBLIC CAPABILITY CONFIGURATION LOGIC
    //////////////////////////////////////////////////////////////*/

    function setPublicCapability(bytes4 functionSig, bool enabled) public virtual requiresAuth {
        isCapabilityPublic[functionSig] = enabled;

        emit PublicCapabilityUpdated(functionSig, enabled);
    }

    /*///////////////////////////////////////////////////////////////
                      USER ROLE ASSIGNMENT LOGIC
    //////////////////////////////////////////////////////////////*/

    function setUserRole(
        address user,
        uint8 role,
        bool enabled
    ) public virtual requiresAuth {
        if (enabled) {
            getUserRoles[user] |= bytes32(1 << role);
        } else {
            getUserRoles[user] &= ~bytes32(1 << role);
        }

        emit UserRoleUpdated(user, role, enabled);
    }

    /*///////////////////////////////////////////////////////////////
                  ROLE CAPABILITY CONFIGURATION LOGIC
    //////////////////////////////////////////////////////////////*/

    function setRoleCapability(
        uint8 role,
        bytes4 functionSig,
        bool enabled
    ) public virtual requiresAuth {
        if (enabled) {
            getRolesWithCapability[functionSig] |= bytes32(1 << role);
        } else {
            getRolesWithCapability[functionSig] &= ~bytes32(1 << role);
        }

        emit RoleCapabilityUpdated(role, functionSig, enabled);
    }
}
