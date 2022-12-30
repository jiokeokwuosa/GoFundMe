import { ethers, getNamedAccounts } from "hardhat"

async function main() {
    const { deployer } = await getNamedAccounts();
    const fundme = await ethers.getContract("GoFundMe", deployer)
    console.log('Funding Contract...')
    const transactionResponse = await fundme.fund({value:ethers.utils.parseEther("0.1")})
    await transactionResponse.wait(1)
    console.log('Funded')
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
    // to run this script use yarn hardhat run scripts/fundme.ts --network localhost