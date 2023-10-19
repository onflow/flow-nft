/// This script checks all the supported views from
/// a given NFT. Used for testing only.

import "NonFungibleToken"
import "MetadataViews"
import "ExampleNFT"

pub fun main(address: Address, id: UInt64): [Type] {
    let account = getAccount(address)

    let collectionRef = account
        .getCapability(ExampleNFT.CollectionPublicPath)
        .borrow<&{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")

    // Borrow a reference to a specific NFT in the collection
    let nft = collectionRef.borrowNFT(id: id)
    return nft.getViews()
}
