import "NonFungibleToken"
import "NFTForwarding"

/// This transaction updates the NFTForwarder recipient to the one given at the specified PublicPath
///
transaction(newRecipientAddress: Address, collectionPublicPath: PublicPath) {

    // reference to the NFTFowarder Resource
    let forwarderRef: auth(NFTForwarding.Mutable) &NFTForwarding.NFTForwarder
    // Collection we will designate as forwarding recipient
    let newRecipientCollection: Capability<&{NonFungibleToken.Collection}>

    prepare(signer: auth(BorrowValue) &Account) {
        // borrow reference to NFTForwarder resource
        self.forwarderRef = signer.storage.borrow<auth(NFTForwarding.Mutable) &NFTForwarding.NFTForwarder>(
                from: NFTForwarding.StoragePath
            ) ?? panic("Could not borrow reference to NFTForwarder in the signer's account at path=".concat(NFTForwarding.StoragePath.toString()))

        // get Collection Capability from the recipientAddress account
        self.newRecipientCollection = getAccount(newRecipientAddress).capabilities.get<&{NonFungibleToken.Collection}>(
                collectionPublicPath
            )

    }

    execute {
        // set new recipient
        self.forwarderRef.changeRecipient(self.newRecipientCollection)
    }
}
