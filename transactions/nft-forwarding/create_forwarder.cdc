import "NonFungibleToken"
import "MetadataViews"
import "NFTForwarding"

/// This transaction is what an account would run to set itself up to forward NFTs to a designated recipient's 
/// NFT.Collection assuming the recipient is configured for the given NFT Collection
///
transaction(recipientAddress: Address, collectionPublicPath: PublicPath) {

    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {
        
        // get Collection Capability from the recipientAddress account
        let recipientCollectionCap = getAccount(recipientAddress).capabilities.get<&{NonFungibleToken.Collection}>(
            collectionPublicPath
        )

        if !recipientCollectionCap.check() {
            panic("The Recipient has not configured their account with an NFT Collection at the given public path=".concat(collectionPublicPath.toString()))
        }

        // create a new NFTForwarder resource & save in storage, forwarding to the recipient's Collection
        let forwarder <- NFTForwarding.createNewNFTForwarder(recipient: recipientCollectionCap)
        signer.storage.save(<-forwarder, to: NFTForwarding.StoragePath)

        // unpublish existing Collection capabilities from PublicPath
        signer.capabilities.unpublish(collectionPublicPath)

        // create & publish a capability for the forwarder where the collection would normally be
        let forwarderReceiverCap = signer.capabilities.storage.issue<&{NonFungibleToken.Receiver}>(NFTForwarding.StoragePath)
        signer.capabilities.publish(forwarderReceiverCap, at: collectionPublicPath)

    }
}
