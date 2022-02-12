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

  /// >>>>>>>>>>>>>>>>>>>>>  CONSTRUCTOR  <<<<<<<<<<<<<<<<<<<<<< ///

  constructor()
  Auth(
    Auth(msg.sender).owner(),
    Auth(msg.sender).authority()
  )
  {}


}
