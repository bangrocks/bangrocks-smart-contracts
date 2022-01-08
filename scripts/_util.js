const fs = require('fs')
const path = require('path')
const { run, ethers, upgrades } = require('hardhat')

const accessibleContracts = ['BANGRocks']
let newContracts = []
let unaccessible = []
let tokenAddress = {}

try {
  tokenAddress = JSON.parse(fs.readFileSync(__dirname + '/../tokenAddresses.json', { encoding: 'utf8' }))
} catch (e) { }

const SAVE_CONTRACT_DIRS = [path.join(process.cwd(), 'deployments')]

async function setContractMaster(contract) {
  if (unaccessible.length > 0) {
    console.log("Updating roles...")
    await contract.setRoles(unaccessible)
  } else {
    console.log("Roles up to date.")
  }
}

async function verifyNew() {
  if (newContracts.length === 0) return
  console.log(`Waiting 5 minutes for Etherscan verification...`)
  return new Promise(resolve => setTimeout(() => {
    console.log(`Verifying contracts: ${newContracts.map(([x]) => x).join(', ')} ...`)
    const verifications = newContracts.map(([, address, constructorArguments]) => (
      run("verify:verify", {
        address,
        constructorArguments: constructorArguments.length > 0 ? constructorArguments : undefined,
      }).catch(err => console.log(err))
    ))

    resolve(Promise.all(verifications))
  }, 300000))
}

async function deploy(contractName, args, type, opts = {}) {
  let aliasName = contractName
  if (Array.isArray(contractName)) {
    aliasName = contractName[1]
    contractName = contractName[0]
  }

  const { chainId } = await ethers.provider.getNetwork()
  const Factory = await ethers.getContractFactory(contractName)
  const deploying = !tokenAddress[aliasName] || !tokenAddress[aliasName][chainId]

  process.stdout.write(`🚀 ${deploying ? 'Deploying' : 'Upgrading'} ${aliasName}...\r`)

  let contract
  switch (type) {
    case 'proxy':
      contract = (deploying ?
          (await upgrades.deployProxy(Factory, args, opts)) :
          (await upgrades.upgradeProxy(tokenAddress[aliasName][chainId], Factory, opts)))
      break
    case 'persist':
      contract = (deploying ?
        (await Factory.deploy.apply(Factory, args)) :
        (await ethers.getContractAt(contractName, tokenAddress[aliasName][chainId])))
        if (deploying) newContracts.push([aliasName, contract.address, args])
        else (await contract.upgradeTo(args[0]))
      break
      default:
        contract = await Factory.deploy.apply(Factory, args)
        newContracts.push([aliasName, contract.address, args])
      break
  }

  console.log(`✅ ${deploying ? 'Deployed' : 'Upgraded'} ${contractName}.                  `)
  if (deploying && accessibleContracts.includes(contractName)) {
    unaccessible.push(contract.address)
  }
  saveContractFiles(chainId, contractName, aliasName, contract.address)
  return contract
}

function saveContractFiles(chainId, name, aliasName, address) {
  tokenAddress = {
    ...tokenAddress,
    [aliasName]: {
      ...(tokenAddress[aliasName] || {}),
      [chainId]: address,
    }
  }

  fs.writeFileSync(
    __dirname + "/../tokenAddresses.json",
    JSON.stringify(tokenAddress, null, 2)
  )

  SAVE_CONTRACT_DIRS.forEach(contractsDir => {
    if (!fs.existsSync(contractsDir)) {
      fs.mkdirSync(contractsDir)
    }

    const TokenArtifact = artifacts.readArtifactSync(name)

    const artifact = {
      name: TokenArtifact.contractName,
      abi: TokenArtifact.abi,
    }

    fs.writeFileSync(
      contractsDir + `/${aliasName}.json`,
      JSON.stringify(artifact, null, 2)
    )

    fs.writeFileSync(
      contractsDir + `/_contractAddresses.json`,
      JSON.stringify(tokenAddress, null, 2)
    )
  })
}

module.exports = { SAVE_CONTRACT_DIRS, verifyNew, setContractMaster, deploy }
