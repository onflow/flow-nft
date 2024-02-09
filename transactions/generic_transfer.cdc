import NonFungibleToken from "NonFungibleToken"

/// Can pass in any storage path and receiver path instead of just the default.
/// This lets you choose the token you want to send as well the capability you want to send it to.
///
/// Any token path can be passed as an argument here, so wallets should
/// should check argument values to make sure the intended token path is passed in
///
transaction(id: UInt64, to: Address, senderPath: StoragePath, receiverPath: PublicPath) {

    // The NFT resource to be transferred
    let tempNFT: @{NonFungibleToken.NFT}

    prepare(signer: auth(BorrowValue) &Account) {

        // borrow a reference to the signer's NFT collection
        let withdrawRef = signer.storage.borrow<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>(
                from: senderPath
            ) ?? panic("Account does not store a collection object at the specified path")

        self.tempNFT <- withdrawRef.withdraw(withdrawID: id)
    }

    execute {
        // get the recipients public account object
        let recipient = getAccount(to)

        // borrow a public reference to the receivers collection
        let receiverCap = recipient.capabilities.get<&{NonFungibleToken.Receiver}>(receiverPath)
            ?? panic("Could not get the recipient's Receiver Capability")

        let receiverRef = receiverCap.borrow()
            ?? panic("Could not borrow reference to the recipient's receiver")

        // Deposit the NFT to the receiver
        receiverRef.deposit(token: <-self.tempNFT)
    }
}