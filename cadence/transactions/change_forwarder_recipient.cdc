import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import ExampleNFT from "../contracts/ExampleNFT.cdc"
import NFTForwarding from "../contracts/utility/NFTForwarding.cdc"

/// This transaction is what an account would run
/// to change the NFTForwarder recipient

transaction(newRecipientAddress: Address) {

    prepare(signer: AuthAccount) {
        /// Borrow reference to NFTForwarder resource
        let forwarderRef = signer
            .borrow<&NFTForwarding.NFTForwarder>(from: NFTForwarding.NFTForwarderStoragePath)
            ?? panic("Could not borrow reference to NFTForwarder")

        /// Get Receiver Capability from the recipientAddress account
        let newRecipientCollection = getAccount(newRecipientAddress)
            .getCapability<&{NonFungibleToken.CollectionPublic}>(ExampleNFT.CollectionPublicPath)

        /// Make sure the CollectionPublic capability is valid before minting the NFT
        if !newRecipientCollection.check() { panic("CollectionPublic capability is not valid!") }

        /// Set new recipient
        forwarderRef.changeRecipient(newRecipient: newRecipientCollection)
    }
}
