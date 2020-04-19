import NonFungibleToken from 0x01
import ExampleNFT from 0x02

// This transaction allows an admin who owns the Minter resource
// to mint an NFT and deposit it to another user's collection.
transaction {

    // The reference to the Minter resource stored in account storage
    let minter: &ExampleNFT.NFTMinter

    prepare(signer: AuthAccount) {

        // Borrow a capability for the NFTMinter in storage
        self.minter = signer.borrow<&ExampleNFT.NFTMinter>(from: /storage/NFTMinter)!
    }

    execute {

        let recipient = getAccount(0x01)

        // Get the recipient's collection capability and borrow a reference
        let receiver = recipient
            .getCapability(/public/NFTReceiver)!
            .borrow<&{NonFungibleToken.Receiver}>()!

        // Use the minter reference to mint an NFT, which deposits
        // the NFT into the collection that is sent as a parameter.
        self.minter.mintNFT(recipient: receiver)
    }
}
