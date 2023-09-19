/// This transaction is what an account would run
/// to set itself up to receive NFTs

import NonFungibleToken from "NonFungibleToken"
import ExampleNFT from "ExampleNFT"
import MetadataViews from "MetadataViews"

transaction {

    prepare(signer: auth(BorrowValue, Capabilities) &Account) {
        // Return early if the account already has a collection
        if signer.storage.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath) != nil {
            return
        }

        // Create a new empty collection
        let collection <- ExampleNFT.createEmptyCollection()

        // save it to the account
        signer.storage.save(<-collection, to: ExampleNFT.CollectionStoragePath)

        // create a public capability for the collection
        let collectionCap = signer.capabilities.storage
            .issue<&{NonFungibleToken.CollectionPublic, ExampleNFT.ExampleNFTCollectionPublic, MetadataViews.ResolverCollection}>(
                ExampleNFT.CollectionStoragePath
            )

        signer.capabilities.publish(
            collectionCap,
            at: ExampleNFT.CollectionPublicPath,
        )
    }
}
