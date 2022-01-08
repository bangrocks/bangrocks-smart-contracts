// contracts/lib/BANGLib.sol
// SPDX-License-Identifier: SUDO
pragma solidity ^0.8.0;

library BANGLib {
    // Used as a generic separator when hashing arguments
    bytes32 constant SEP = keccak256("/SUDO_DOMAIN_SEPARATOR/");

    // Access Control
    bytes32 constant ROLE_SUDO = keccak256("ROLE_SUDO");
    bytes32 constant ROLE_BANG = keccak256("ROLE_BANG");
    bytes32 constant ROLE_ZKSYNC = keccak256("ROLE_ZKSYNC");
}
