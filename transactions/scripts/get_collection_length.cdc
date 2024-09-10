import "NonFungibleToken"
import "ExampleNFT"
import "MetadataViews"

access(all) fun main(address: Address): Int {
    let account = getAccount(address)

    let collectionData = ExampleNFT.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("Could not resolve NFTCollectionData view. The ExampleNFT contract needs to implement the NFTCollectionData Metadata view in order to execute this transaction")

    let collectionRef = account.capabilities.borrow<&{NonFungibleToken.Collection}>(
            collectionData.publicPath
    ) ?? panic("The account ".concat(address.toString()).concat(" does not have a NonFungibleToken Collection at ")
                .concat(collectionData.publicPath.toString())
                .concat("The account must initialize their account with this collection first!"))

    return collectionRef.getLength()
}
