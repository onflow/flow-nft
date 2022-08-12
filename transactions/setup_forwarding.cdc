import NonFungibleToken from 0x02
import MetadataViews from 0x03
import ExampleNFT from 0x04
import NFTForwarding from 0x05

/// This transaction is what an account would run
/// to set itself up to receive NFTs

transaction(recipientAddress: Address) {

    prepare(signer: AuthAccount) {
        // Return early if the account already has an NFTForwarder
        if signer.borrow<&NFTForwarding.NFTForwarder>(from: NFTForwarding.NFTForwarderStoragePath) != nil {
            return
        }

        // Get Receiver Capability from the recipientAddress account
        let forwardingRecipient = getAccount(recipientAddress)
        let receiverCapability = forwardingRecipient.getCapability(ExampleNFT.CollectionPublicPath)

        // Create a new NFTForwarder resource
        let forwarder <- NFTForwarding.createNewNFTForwarder(recipient: receiverCapability)

        // save it to the account
        signer.save(<-forwarder, to: NFTForwarding.NFTForwarderStoragePath)

        if signer.getCapability(ExampleNFT.CollectionPublicPath).check<&{NonFungibleToken.CollectionPublic}>() {
            signer.unlink(ExampleNFT.CollectionPublicPath)
        }

        // create a public capability for the forwarder where the collection would be
        signer.link<&{NonFungibleToken.CollectionPublic}>(
            ExampleNFT.CollectionPublicPath,
            target: NFTForwarding.NFTForwarderStoragePath
        )
    }
}