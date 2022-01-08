require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("@openzeppelin/hardhat-upgrades");
require("hardhat-preprocessor");

// The next line is part of the sample project, you don't need it in your
// project. It imports a Hardhat task definition, that can be used for
// testing the frontend.
require("./tasks/faucet");

module.exports = {
    solidity: {
        version: "0.8.2",
        settings: {
            optimizer: {
                enabled: true,
                runs: 1000,
            },
        },
    },
    etherscan: {
        apiKey: "53TD7RKRSZWSWFH7VM6VV82ARS9ID9XZH5"
    },
    networks: {
        hardhat: {
            accounts: {
                mnemonic: "frequent raise tent thing legal fashion core tortoise endorse enroll casual message"
            }
        },
        localhost: {
            accounts: {
                mnemonic: "frequent raise tent thing legal fashion core tortoise endorse enroll casual message"
            }
        },
        ropsten: {
            url: "https://ropsten.infura.io/v3/559e5b93059340a4bb9f6f80750935dd",
            accounts: {
                mnemonic: "frequent raise tent thing legal fashion core tortoise endorse enroll casual message"
            }
        },
        rinkeby: {
            url: "https://rinkeby.infura.io/v3/559e5b93059340a4bb9f6f80750935dd",
            accounts: {
                mnemonic: "frequent raise tent thing legal fashion core tortoise endorse enroll casual message"
            }
        },
    }
}
