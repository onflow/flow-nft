import NonFungibleToken from 0x01
import ExampleNFT from 0x02

// This transaction transfers an NFT from one user's collection
// to another user's collection.
transaction {

    // The field that will hold the NFT as it is being
    // transferred to the other account
    let transferToken: @ExampleNFT.NFT

    prepare(signer: AuthAccount) {

        // Borrow a reference from the stored collection
        let collectionRef = signer.borrow<&ExampleNFT.Collection>(from: /storage/NFTCollection)!

        // Call the withdraw function on the sender's Collection
        // to move the NFT out of the collection
        self.transferToken <- collectionRef.withdraw(withdrawID: 1)
    }

    execute {
        // Get the recipient's public account object
        let recipient = getAccount(0x01)

        // Get the Collection reference for the receiver
        // getting the public capability and borrowing a reference from it
        let receiverRef = recipient
            .getCapability(/public/NFTReceiver)!
            .borrow<&{NonFungibleToken.Receiver}>()!

        // Deposit the NFT in the receivers collection
        receiverRef.deposit(token: <-self.transferToken)
    }
}