import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import ExampleNFT from "../contracts/ExampleNFT.cdc"
import NFTForwarding from "../contracts/utility/NFTForwarding.cdc"

/// This transaction is what an account would run
/// to unlink its collection from public storage

transaction {

    prepare(signer: AuthAccount) {

        if signer.getCapability(ExampleNFT.CollectionPublicPath).check<&{ExampleNFT.ExampleNFTCollectionPublic}>() {
            log("Unlinking ExampleNFTCollectionPublic from PublicPath")
            signer.unlink(ExampleNFT.CollectionPublicPath)
        }

    }
}
