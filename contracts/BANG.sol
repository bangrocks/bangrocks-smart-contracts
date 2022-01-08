// contracts/BANG.sol
// SPDX-License-Identifier: SUDO
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "./lib/interfaces/IBANG.sol";
import "./lib/BANGLib.sol";

contract BANG is IBANG, AccessControlUpgradeable {
    using ECDSAUpgradeable for bytes32;

    mapping(uint256 => bool) private _nonces;

    function initialize() public initializer {
        __AccessControl_init();
        _setupRole(BANGLib.ROLE_BANG, _msgSender());
        _setupRole(BANGLib.ROLE_SUDO, _msgSender());
        _setRoleAdmin(BANGLib.ROLE_SUDO, BANGLib.ROLE_SUDO);
    }

    function setRoles(address[] memory modules)
        external
        override
        onlyRole(BANGLib.ROLE_BANG)
    {
        for (uint256 i = 0; i < modules.length; i++) {
            _setupRole(BANGLib.ROLE_BANG, modules[i]);
        }
    }

    function checkRole(bytes32 role, address account) external view override {
        _checkRole(role, account);
    }

    function isRole(bytes32 role, address account)
        public
        view
        virtual
        override
        returns (bool)
    {
        return AccessControlUpgradeable.hasRole(role, account);
    }

    function getEncodedArgs(
        address account,
        address sender,
        uint256 nonce,
        uint256 expires,
        bytes calldata args
    ) public view returns (bytes memory) {
        return
            abi.encode(
                block.chainid,
                nonce,
                account,
                sender,
                expires,
                BANGLib.SEP,
                keccak256(args)
            );
    }

    function getIssuer(
        address account,
        uint256 nonce,
        uint256 expires,
        bytes calldata args,
        bytes calldata signature
    ) public view returns (address) {
        bytes memory argsEncoded = getEncodedArgs(
            account,
            _msgSender(),
            nonce,
            expires,
            args
        );
        bytes32 claimHash = keccak256(argsEncoded).toEthSignedMessageHash();
        return claimHash.recover(signature);
    }

    function checkServer(
        address account,
        uint256 nonce,
        uint256 expires,
        bytes calldata signature,
        bytes calldata args
    ) public override {
        require(block.timestamp < expires, "Signature expired");
        if (!hasRole(BANGLib.ROLE_SUDO, account)) {
            require(!_nonces[nonce], "Nonce used");
            _nonces[nonce] = true;
            address issuer = getIssuer(
                account,
                nonce,
                expires,
                args,
                signature
            );
            _checkRole(BANGLib.ROLE_BANG, issuer);
        }
    }
}
