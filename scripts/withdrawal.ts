import { ethers, getNamedAccounts } from "hardhat"

async function main() {
    const { deployer } = await getNamedAccounts();
    const fundme = await ethers.getContract("GoFundMe", deployer)
    console.log('Withdrawing Funds...')
    const transactionResponse = await fundme.withdraw()
    await transactionResponse.wait(1)
    console.log('Withdrawal successful')
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
    // to run this script use yarn hardhat run scripts/withdrawal.ts --network localhost