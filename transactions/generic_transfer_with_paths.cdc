import "NonFungibleToken"

/// Can pass in any storage path and receiver path instead of just the default.
/// This lets you choose the token you want to send as well the capability you want to send it to.
///
/// Any token path can be passed as an argument here, so wallets should
/// should check argument values to make sure the intended token path is passed in
///
transaction(to: Address, id: UInt64, senderPathIdentifier: String, receiverPathIdentifier: String) {

    // The NFT resource to be transferred
    let tempNFT: @{NonFungibleToken.NFT}

    prepare(signer: auth(BorrowValue) &Account) {

        let storagePath = StoragePath(identifier: senderPathIdentifier)
            ?? panic("Could not construct a storage path from the provided path identifier string")

        // borrow a reference to the signer's NFT collection
        let withdrawRef = signer.storage.borrow<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>(
                from: storagePath
            ) ?? panic("Account does not store a collection object at the specified path")

        self.tempNFT <- withdrawRef.withdraw(withdrawID: id)
    }

    execute {
        let publicPath = PublicPath(identifier: receiverPathIdentifier)
            ?? panic("Could not construct a public path from the provided path identifier string")

        // get the recipients public account object
        let recipient = getAccount(to)

        // borrow a public reference to the receivers collection
        let receiverRef = recipient.capabilities.borrow<&{NonFungibleToken.Receiver}>(publicPath)
            ?? panic("Could not borrow reference to the recipient's receiver")

        // Deposit the NFT to the receiver
        receiverRef.deposit(token: <-self.tempNFT)
    }
}