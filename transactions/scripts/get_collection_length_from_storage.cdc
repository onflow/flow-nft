import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"
import ExampleNFT from "ExampleNFT"

access(all) fun main(address: Address): Int {
    let account = getAuthAccount<auth(BorrowValue) &Account>(address)

    let collectionData = ExampleNFT.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
        ?? panic("ViewResolver does not resolve NFTCollectionData view")

    let collectionRef = account.storage.borrow<&{NonFungibleToken.Collection}>(
            from: collectionData.storagePath
        ) ?? panic("Could not borrow reference to collection from storage")

    return collectionRef.getLength()
}
