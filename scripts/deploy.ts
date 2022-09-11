import { ethers } from 'hardhat'

async function main() {
    /**
    const worldIDAddress = await fetch('https://developer.worldcoin.org/api/v1/contracts')
        .then(res => res.json() as Promise<{ key: string; value: string }[]>)
        .then(res => res.find(({ key }) => key === 'staging.semaphore.wld.eth').value)
    **/
    const ContractFactory = await ethers.getContractFactory('Contract')
    const contract = await ContractFactory.deploy("0xABB70f7F39035586Da57B3c8136035f87AC0d2Aa")

    await contract.deployed()

    console.log('Contract deployed to:', contract.address)
    
}

main().catch(error => {
    console.error(error)
    process.exitCode = 1
})
