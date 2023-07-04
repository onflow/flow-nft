// This script borrows an NFT from a collection

import NonFungibleToken from "NonFungibleToken"
import ExampleNFT from "ExampleNFT"

pub fun main(address: Address, id: UInt64) {
    let account = getAccount(address)

    let collectionRef = account
        .getCapability(ExampleNFT.CollectionPublicPath)
        .borrow<&{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")

    // Borrow a reference to a specific NFT in the collection
    let _ = collectionRef.borrowNFT(id: id)
}
