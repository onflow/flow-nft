import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"
import ExampleNFT from "../contracts/ExampleNFT.cdc"
import NFTForwarding from "../contracts/utility/NFTForwarding.cdc"

/// This transaction is what an account would run
/// to link a collection to its public storage
/// after having configured its NFTForwarder

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
