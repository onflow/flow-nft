
import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"
import NFTForwarding from "NFTForwarding"

// This transaction replaces NFTForwarder Receiver Capabilities with a collection to its public storage after having configured
// its NFTForwarder
///
transaction(collectionStoragePath: StoragePath, receiverPublicPath: PublicPath) {

    prepare(signer: auth(IssueStorageCapabilityController, PublishCapability, UnpublishCapability) &Account) {
        
        // a collection is already published, do nothing - remember .NFTForwarder only conforms to NFT.Receiver
        if signer.capabilities.get<&{NonFungibleToken.Collection}>(receiverPublicPath) != nil {
            return
        }

        // otherwise, unpublish the published Capability
        signer.capabilities.unpublish(receiverPublicPath)

        // create & publish a capability for the collection
        let collectionCap = signer.capabilities.storage.issue<&{NonFungibleToken.Collection}>(collectionStoragePath)
        signer.capabilities.publish(collectionCap, at: receiverPublicPath)

    }
}
