/// This transaction is what an account would run
/// to unlink its collection from public storage

import NonFungibleToken from "NonFungibleToken"
import ExampleNFT from "ExampleNFT"
import NFTForwarding from "NFTForwarding"

transaction {

    prepare(signer: AuthAccount) {

        if signer.getCapability(ExampleNFT.CollectionPublicPath).check<&{ExampleNFT.ExampleNFTCollectionPublic}>() {
            log("Unlinking ExampleNFTCollectionPublic from PublicPath")
            signer.unlink(ExampleNFT.CollectionPublicPath)
        }

    }
}
