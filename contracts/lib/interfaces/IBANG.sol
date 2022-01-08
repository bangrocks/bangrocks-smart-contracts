// contracts/IBANG.sol
// SPDX-License-Identifier: SUDO
pragma solidity ^0.8.0;

interface IBANG {
    function isRole(bytes32 role, address account) external view returns (bool);

    function checkServer(
        address account,
        uint256 nonce,
        uint256 expires,
        bytes memory signature,
        bytes memory args
    ) external;

    function checkRole(bytes32 role, address account) external view;

    function setRoles(address[] memory modules) external;
}
