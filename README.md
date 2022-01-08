# Bang Rocks

The Official Bang Rocks repository.

## Quick start

The first things you need to do are cloning this repository and installing its
dependencies:

```sh
git clone https://github.com/bangrocks/bangrocks-smart-contracts.git
cd bangrocks-smart-contracts
npm install
```

Once installed, you can run Hardhat's testing network:

```sh
npx hardhat node
```

Then, on a new terminal, go to the repository's root folder and run this to
deploy your contract locally:

```sh
npm run deploy-local
# or for testnet
npm run deploy-rinkeby
```

Watch mode (Watch for smart contract changes and redeploy to local hardhat node or Ganache):
```
npm run dev-contracts
```
