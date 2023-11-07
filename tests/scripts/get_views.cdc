/// This script checks all the supported views from
/// a given NFT. Used for testing only.

import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"
import ExampleNFT from "ExampleNFT"

access(all) fun main(address: Address, id: UInt64): Bool {
    let account = getAccount(address)

    let collectionData = ExampleNFT.resolveView(Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
        ?? panic("ViewResolver does not resolve NFTCollectionData view")
    
    let collectionRef = account.capabilities.borrow<&{NonFungibleToken.Collection}>(
            collectionData.publicPath
        ) ?? panic("Could not borrow capability from public collection")

    // Borrow a reference to a specific NFT in the collection
    let nft = collectionRef.borrowNFT(id)
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
