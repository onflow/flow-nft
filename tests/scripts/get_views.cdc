/// This script checks all the supported views from
/// a given NFT. Used for testing only.

import "NonFungibleToken"
import "MetadataViews"
import "ExampleNFT"

access(all) fun main(address: Address, id: UInt64): [Type] {
    let account = getAccount(address)

    let collectionData = ExampleNFT.resolveView(Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
        ?? panic("ViewResolver does not resolve NFTCollectionData view")
    
    let collectionRef = account.capabilities.borrow<&{NonFungibleToken.Collection}>(
            collectionData.publicPath
        ) ?? panic("Could not borrow capability from public collection")

    // Borrow a reference to a specific NFT in the collection
    let nft = collectionRef.borrowNFT(id: id)
        ?? panic("Could not get a reference to the NFT")
    return nft.getViews()
}
