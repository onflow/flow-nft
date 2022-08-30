import ExampleNFT from "../../contracts/ExampleNFT.cdc"

pub fun main(): UInt64 {
    return ExampleNFT.totalSupply
}
