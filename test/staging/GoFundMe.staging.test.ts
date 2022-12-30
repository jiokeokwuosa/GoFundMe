import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { assert } from "chai";
import { ethers, network } from "hardhat";
import { developmentChains } from "../../helper-hardhat-config";
import { GoFundMe } from "../../typechain-types";

!developmentChains.includes(network.name) ?
describe("GoFundMe", async function () {
    let fundMe: GoFundMe;
    let deployer: SignerWithAddress;   
    const valueSent = ethers.utils.parseEther("0.2")   

    beforeEach(async function () {
        const accounts = await ethers.getSigners()       
        deployer = accounts[0]
        fundMe = await ethers.getContract("GoFundMe", deployer.address)          
    })

    it("allows people to fund and withdraw", async function(){
        await fundMe.fund({value:valueSent,  gasLimit: 100000})
        await fundMe.withdraw({
            gasLimit: 100000,
        })
        const endingBalance = await fundMe.provider.getBalance(fundMe.address)  
        assert.equal(endingBalance.toString(), "0")
    })  
}) : describe.skip