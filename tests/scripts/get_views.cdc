/// This script checks all the supported views from
/// a given NFT. Used for testing only.

import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"
import ExampleNFT from "ExampleNFT"

pub fun main(address: Address, id: UInt64): Bool {
    let account = getAccount(address)

    let collectionRef = account
        .getCapability(ExampleNFT.CollectionPublicPath)
        .borrow<&{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not borrow capability from public collection")

    // Borrow a reference to a specific NFT in the collection
    let nft = collectionRef.borrowNFT(id: id)
    let views = nft.getViews()

    let expected = [
        Type<MetadataViews.Display>(),
        Type<MetadataViews.Royalties>(),
        Type<MetadataViews.Editions>(),
        Type<MetadataViews.ExternalURL>(),
        Type<MetadataViews.NFTCollectionData>(),
        Type<MetadataViews.NFTCollectionDisplay>(),
        Type<MetadataViews.Serial>(),
        Type<MetadataViews.Traits>()
    ]
    assert(expected == views)

    return true
}
