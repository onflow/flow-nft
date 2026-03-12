/// This transaction is what an account would run
/// to set itself up to receive NFTs. This function
/// uses views to know where to set up the collection
/// in storage and to create the empty collection.

import "NonFungibleToken"
import "MetadataViews"

transaction(address: Address, publicPath: PublicPath, id: UInt64) {

    prepare(signer: auth(IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {
        let collection = getAccount(address).capabilities.borrow<&{NonFungibleToken.Collection}>(publicPath)
            ?? panic("Could not borrow a reference to the NonFungibleToken Collection for the account with Address "
                      .concat(address.toString())
                      .concat(" at path ")
                      .concat(publicPath.toString())
                      .concat(". The account needs to set up their collection first"))

        let nftRef = collection.borrowNFT(id)
            ?? panic("Could not borrow a reference to the desired NFT with id "
                      .concat(id.toString()))

        let collectionData = nftRef.resolveView(Type<MetadataViews.NFTCollectionData>()) as? MetadataViews.NFTCollectionData
            ?? panic("The NFT at id "
                     .concat(id.toString())
                     .concat(" does not support the NFTCollectionData metadata view."))

        // Return early if the account already has a collection at this storage path
        if signer.storage.check<@{NonFungibleToken.Collection}>(from: collectionData.storagePath) {
            return
        }

        // Create a new empty collection
        let emptyCollection <- collectionData.createEmptyCollection()

        // save it to the account
        signer.storage.save(<-emptyCollection, to: collectionData.storagePath)

        // create a public capability for the collection
        signer.capabilities.unpublish(collectionData.publicPath)
        let collectionCap = signer.capabilities.storage.issue<&{NonFungibleToken.Collection}>(
                collectionData.storagePath
            )
        signer.capabilities.publish(collectionCap, at: collectionData.publicPath)
    }
}
