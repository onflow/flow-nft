/// This transaction withdraws an NFT from the signers collection and destroys it

import NonFungibleToken from "NonFungibleToken"
import ExampleNFT from "ExampleNFT"

transaction(id: UInt64) {

    /// Reference that will be used for the owner's collection
    let collectionRef: &ExampleNFT.Collection

    prepare(signer: auth(BorrowValue) &Account) {
        // borrow a reference to the owner's collection
        self.collectionRef = signer.storage.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)
            ?? panic("Account does not store an object at the specified path")
    }

    execute {
        // withdraw the NFT from the owner's collection
        let nft <- self.collectionRef.withdraw(withdrawID: id)

        destroy nft
    }

    post {
        !self.collectionRef.getIDs().contains(id): "The NFT with the specified ID should have been deleted"
    }
}
