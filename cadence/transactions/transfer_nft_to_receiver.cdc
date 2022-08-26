import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import ExampleNFT from "../contracts/ExampleNFT.cdc"

/// This transaction is for transferring an NFT from
/// one account to another using the recipient's Receiver resource
/// which is more limited than a CollectionPublic Resource

transaction(recipient: Address, withdrawID: UInt64) {

    /// Reference to the withdrawer's collection
    let withdrawRef: &ExampleNFT.Collection

    /// Reference of the Receiver to deposit the NFT to
    let depositRef: &{NonFungibleToken.Receiver}

    prepare(signer: AuthAccount) {
        // borrow a reference to the signer's NFT collection
        self.withdrawRef = signer
            .borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)
            ?? panic("Account does not store an object at the specified path")

        // get the recipients public account object
        let recipient = getAccount(recipient)

        // borrow a public reference to the recipient's Receiver
        self.depositRef = recipient
            .getCapability(ExampleNFT.CollectionPublicPath)
            .borrow<&{NonFungibleToken.Receiver}>()
            ?? panic("Could not borrow a reference to the recipient's Receiver")
    }

    execute {

        // withdraw the NFT from the owner's collection
        let nft <- self.withdrawRef.withdraw(withdrawID: withdrawID)

        // Deposit the NFT in the recipient
        self.depositRef.deposit(token: <-nft)
    }

    post {
        !self.withdrawRef.getIDs().contains(withdrawID): "Original owner should not have the NFT anymore"
    }
}
