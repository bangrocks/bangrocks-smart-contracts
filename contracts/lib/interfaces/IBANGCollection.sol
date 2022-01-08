// contracts/IBANGCollection.sol
// SPDX-License-Identifier: SUDO
pragma solidity ^0.8.0;

interface IBANGCollection {
    function mint(
        address receiver,
        uint256 nonce,
        uint256 expires,
        uint256 nftId,
        uint256 times,
        uint256 limit,
        bytes memory signature
    ) external;

    function burn(
        uint256 nonce,
        uint256 expires,
        uint256 tokenId,
        bytes memory signature
    ) external;

    function initialize(
        address bang,
        string calldata name,
        string calldata symbol,
        string calldata baseURI_
    ) external;
}
