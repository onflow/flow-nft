/// This transaction is what an account would run
/// to set itself up to receive NFTs. This function
/// uses views to know where to set up the collection
/// in storage and to create the empty collection.

import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"

transaction(address: Address, publicPath: PublicPath, id: UInt64) {

    prepare(signer: auth(IssueStorageCapabilityController, PublishCapability, SaveValue) &Account) {
        let collection = getAccount(address).capabilities.borrow<&{NonFungibleToken.Collection}>(publicPath)
            ?? panic("Could not borrow a reference to the collection")

        let nftRef = collection.borrowNFT(id)
            ?? panic("Could not borrow a reference to the desired NFT")
        
        let collectionData = nftRef.resolveView(Type<MetadataViews.NFTCollectionData>())! as! MetadataViews.NFTCollectionData

        // Create a new empty collections
        let emptyCollection <- collectionData.createEmptyCollection()

        // save it to the account
        signer.storage.save(<-emptyCollection, to: collectionData.storagePath)

        // create a public capability for the collection
        let collectionCap = signer.capabilities.storage.issue<&{NonFungibleToken.Receiver, NonFungibleToken.Collection}>(
                collectionData.storagePath
            )
        signer.capabilities.publish(collectionCap, at: publicPath)
    }
}
