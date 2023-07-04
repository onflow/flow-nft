/// This transaction is what an account would run
/// to link a collection to its public storage
/// after having configured its NFTForwarder

import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"
import ExampleNFT from "ExampleNFT"
import NFTForwarding from "NFTForwarding"

transaction {

    prepare(signer: AuthAccount) {
        if signer.getCapability(ExampleNFT.CollectionPublicPath).check<&{ExampleNFT.ExampleNFTCollectionPublic}>() {
            log("Collection already configured for PublicPath")
            return
        }

        if signer.getCapability(ExampleNFT.CollectionPublicPath).check<&{NonFungibleToken.Receiver}>() {
            log("Unlinking NFTForwarder from PublicPath")
            signer.unlink(ExampleNFT.CollectionPublicPath)
        }

        // create a public capability for the collection
        signer.link<&{NonFungibleToken.CollectionPublic, ExampleNFT.ExampleNFTCollectionPublic, MetadataViews.ResolverCollection}>(
            ExampleNFT.CollectionPublicPath,
            target: ExampleNFT.CollectionStoragePath
        )
    }
}
