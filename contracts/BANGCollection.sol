// contracts/BANGCollection.sol
// SPDX-License-Identifier: SUDO
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "./lib/interfaces/IBANGCollection.sol";
import "./lib/BANGLib.sol";
import "./lib/BANGModule.sol";

contract BANGCollection is
    BANGModule,
    IBANGCollection,
    ERC721EnumerableUpgradeable
{
    using StringsUpgradeable for uint256;
    mapping(uint256 => uint256) tokenNftIds;
    string public baseURI;

    function initialize(
        address bang,
        string calldata name,
        string calldata symbol,
        string calldata baseURI_
    ) public virtual override initializer {
        __ERC721_init(name, symbol);
        __ERC721Enumerable_init();
        __BANGModule_init(bang);
        setBaseURI(baseURI_);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newURI) public {
        baseURI = _newURI;
    }

    function contractURI() public view virtual returns (string memory) {
        string memory baseURI_ = _baseURI();
        return
            bytes(baseURI_).length > 0
                ? string(abi.encodePacked(baseURI_, "_metadata.json"))
                : ".json";
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            super.isApprovedForAll(owner, operator) ||
            operator == address(bang);
    }

    function withdraw(
        uint256 nonce,
        uint256 expires,
        bytes memory signature
    ) public {
        bang.checkServer(_msgSender(), nonce, expires, signature, "");
        uint256 balance = address(this).balance;
        payable(_msgSender()).transfer(balance);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token."
        );
        string memory baseURI_ = _baseURI();
        return
            bytes(baseURI_).length > 0
                ? string(
                    abi.encodePacked(
                        baseURI_,
                        tokenNftIds[tokenId],
                        "/",
                        tokenId.toString(),
                        ".json"
                    )
                )
                : ".json";
    }

    function getNftId(uint256 tokenId) public view returns (uint256) {
        return tokenNftIds[tokenId];
    }

    function burn(
        uint256 nonce,
        uint256 expires,
        uint256 tokenId,
        bytes memory signature
    ) public override {
        bang.checkServer(
            _msgSender(),
            nonce,
            expires,
            signature,
            abi.encode(tokenId)
        );

        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "BANGCollection: caller is not owner nor approved"
        );
        _burn(tokenId);
    }

    function mintNFTFromZkSync(
        address,
        uint32,
        uint32,
        bytes calldata,
        address recipient,
        uint32 nftId
    ) public {
        bang.checkRole(BANGLib.ROLE_ZKSYNC, _msgSender());
        uint256 tokenId = totalSupply();
        tokenNftIds[tokenId] = uint256(nftId);
        _mint(recipient, tokenId);
    }

    function mint(
        address recipient,
        uint256 nonce,
        uint256 expires,
        uint256 nftId,
        uint256 times,
        uint256 limit,
        bytes memory signature
    ) public override {
        bang.checkServer(
            _msgSender(),
            nonce,
            expires,
            signature,
            abi.encode(nftId, BANGLib.SEP, times, BANGLib.SEP, limit)
        );

        uint256 tokenId = totalSupply();
        require(tokenId + times <= limit, "Amount exceeds limit.");

        for (uint256 i = 0; i < times; i++) {
            tokenNftIds[tokenId] = nftId;
            _mint(recipient, tokenId++);
        }
    }
}
