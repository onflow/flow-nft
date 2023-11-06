import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"
import ExampleNFT from "ExampleNFT"

access(all) fun main(address: Address): Int {
    let account = getAccount(address)

    let collectionData = ExampleNFT.resolveView(Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
        ?? panic("ViewResolver does not resolve NFTCollectionData view")

    let collectionRef = account.capabilities.borrow<&{NonFungibleToken.Collection}>(
            collectionData.publicPath
        ) ?? panic("Could not borrow capability from public collection")

    return collectionRef.getLength()
}
