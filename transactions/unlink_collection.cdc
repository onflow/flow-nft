/// This transaction is what an account would run
/// to unlink its collection from public storage

import NonFungibleToken from "NonFungibleToken"
import ExampleNFT from "ExampleNFT"
import NFTForwarding from "NFTForwarding"

transaction {

    prepare(signer: auth(BorrowValue) &Account) {

        if let cap = signer.capabilities.get<&{ExampleNFT.ExampleNFTCollectionPublic}>(ExampleNFT.CollectionPublicPath) {
            if cap.check() {
                log("Unpublishing ExampleNFTCollectionPublic from PublicPath")
                signer.capabilities.unpublish(ExampleNFT.CollectionPublicPath)
            }
        }
    }
}
