/// This transaction is what an account would run
/// to set itself up to receive NFTs. This function
/// uses views to know where to set up the collection
/// in storage and to create the empty collection.

import "NonFungibleToken"
import "MetadataViews"

transaction(address: Address, publicPath: PublicPath, id: UInt64) {

    prepare(signer: auth(IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {
        let collection = getAccount(address).capabilities.borrow<&{NonFungibleToken.Collection}>(publicPath)
            ?? panic("setup_account_from_nft_reference: Could not borrow a reference to the NonFungibleToken Collection for the account \(address) at the path \(publicPath). The account needs to set up their collection first")

        let nftRef = collection.borrowNFT(id)
            ?? panic("setup_account_from_nft_reference: Could not borrow a reference to the NFT with ID \(id) from the collection at \(publicPath)")

        let collectionData = nftRef.resolveView(Type<MetadataViews.NFTCollectionData>()) as? MetadataViews.NFTCollectionData
            ?? panic("setup_account_from_nft_reference: The NFT with ID \(id) does not support the NFTCollectionData metadata view")

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
