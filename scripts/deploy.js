const { ethers, upgrades } = require("hardhat")
const { deploy, verifyNew, setContractMaster } = require("./_util");

async function main() {
    // This is just a convenience check
    if (network.name === "hardhat") {
        console.warn(
            "You are trying to deploy a contract to the Hardhat Network, which" +
            "gets automatically created and destroyed every time. Use the Hardhat" +
            " option '--network localhost'"
        );
    }

    // ethers is avaialble in the global scope
    const [deployer] = await ethers.getSigners();
    console.log(
        "Deploying the contracts with the account:",
        await deployer.getAddress()
    );

    console.log("Account balance:", (await deployer.getBalance()).toString());

    let bang = await deploy("BANG", [], "proxy");
    let bangRocks = await deploy("BANGRocks", [bang.address, "Bang Rocks", "BANG"], "proxy");
    let bangCollection = await deploy("BANGCollection", []);
    await bangCollection.initialize(bang.address, "Bang Rocks", "BANGROCKS", "https://i.bang.rocks/metadata/");
    let bangCollections = await deploy(["BANGBeacon", "BANGCollections"], [bangCollection.address, bang.address], "persist");
    await setContractMaster(bang)
    await verifyNew()
}


main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
