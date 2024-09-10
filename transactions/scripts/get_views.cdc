/// This script checks all the supported views from
/// a given NFT. Used for testing only.

import "NonFungibleToken"
import "MetadataViews"
import "ExampleNFT"

access(all) fun main(address: Address, id: UInt64): [Type] {
    let account = getAccount(address)

    let collectionData = ExampleNFT.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("Could not resolve NFTCollectionData view. The ExampleNFT contract needs to implement the NFTCollectionData Metadata view in order to execute this transaction")
    
    let collectionRef = account.capabilities.borrow<&{NonFungibleToken.Collection}>(
            collectionData.publicPath
    ) ?? panic("The account ".concat(address.toString()).concat(" does not have a NonFungibleToken Collection at ")
                .concat(collectionData.publicPath.toString())
                .concat("The account must initialize their account with this collection first!"))

    // Borrow a reference to a specific NFT in the collection
    let nft = collectionRef.borrowNFT(id)
        ?? panic("Could not get a reference to the ExampleNFT NFT with id=".concat(id.toString()))
    return nft.getViews()
}
