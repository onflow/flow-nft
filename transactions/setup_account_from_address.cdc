import "NonFungibleToken"
import "MetadataViews"

#interaction (
  version: "1.0.0",
	title: "Generic FT Transfer with Contract Address and Name",
	description: "Transfer any Fungible Token by providing the contract address and name",
	language: "en-US",
)

/// This transaction is what an account would run
/// to set itself up to receive NFTs. This function
/// uses views to know where to set up the collection
/// in storage and to create the empty collection.
///
/// @param nftTypeIdentifier: The type identifier name of the NFT type you want to create a collection for
            /// Ex: "A.0b2a3299cc857e29.TopShot.NFT"

transaction(nftTypeIdentifier: String) {

    prepare(signer: auth(IssueStorageCapabilityController, PublishCapability, SaveValue) &Account) {
        let collectionData = MetadataViews.resolveContractViewFromTypeIdentifier(
            resourceTypeIdentifier: nftTypeIdentifier,
            viewType: Type<MetadataViews.NFTCollectionData>()
        ) as? MetadataViews.NFTCollectionData
            ?? panic("Could not construct valid NFT type and view from identifier \(nftTypeIdentifier)")

        // Create a new empty collections
        let emptyCollection <- collectionData.createEmptyCollection()

        // save it to the account
        signer.storage.save(<-emptyCollection, to: collectionData.storagePath)

        // create a public capability for the collection
        let collectionCap = signer.capabilities.storage.issue<&{NonFungibleToken.Collection}>(
                collectionData.storagePath
            )
        signer.capabilities.publish(collectionCap, at: collectionData.publicPath)
    }
}
