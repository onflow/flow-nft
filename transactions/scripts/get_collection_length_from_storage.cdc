import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"
import ExampleNFT from "ExampleNFT"

access(all) fun main(address: Address): Int {
    let account = getAuthAccount<auth(BorrowValue) &Account>(address)

    let collectionData = ExampleNFT.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("Could not resolve NFTCollectionData view. The ExampleNFT contract needs to implement the NFTCollectionData Metadata view in order to execute this transaction")

    let collectionRef = account.storage.borrow<&{NonFungibleToken.Collection}>(
            from: collectionData.storagePath
            ) ?? panic("The account ".concat(address.toString())
                        .concat(" does not store an ExampleNFT.Collection object at the path ")
                        .concat(collectionData.storagePath.toString())
                        .concat("The account must initialize their account with this collection first!"))

    return collectionRef.getLength()
}
