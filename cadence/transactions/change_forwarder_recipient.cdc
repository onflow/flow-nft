import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import ExampleNFT from "../contracts/ExampleNFT.cdc"
import NFTForwarding from "../contracts/utility/NFTForwarding.cdc"

/// This transaction is what an account would run
/// to change the NFTForwarder recipient

transaction(newRecipientAddress: Address) {

    /// Reference to the NFTFowarder Resource
    let forwarderRef: &NFTForwarding.NFTForwarder
    /// Collection we will designate as forwarding recipient
    let newRecipientCollection: Capability<&{NonFungibleToken.CollectionPublic}>

    prepare(signer: AuthAccount) {
        // Borrow reference to NFTForwarder resource
        self.forwarderRef = signer
            .borrow<&NFTForwarding.NFTForwarder>(from: NFTForwarding.StoragePath)
            ?? panic("Could not borrow reference to NFTForwarder")

        // Get Receiver Capability from the recipientAddress account
        self.newRecipientCollection = getAccount(newRecipientAddress)
            .getCapability<&{NonFungibleToken.CollectionPublic}>(ExampleNFT.CollectionPublicPath)

        // Make sure the CollectionPublic capability is valid before minting the NFT
        if !self.newRecipientCollection.check() {
            panic("CollectionPublic capability is not valid!")
        }
    }

    execute {
        // Set new recipient
        self.forwarderRef.changeRecipient(newRecipient: self.newRecipientCollection)
    }
}
