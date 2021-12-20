import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import ExampleNFT from "../contracts/ExampleNFT.cdc"

transaction(id: UInt64) {
    prepare(signer: AuthAccount) {
        let collectionRef = signer.borrow<&ExampleNFT.Collection>(from: /storage/NFTCollection)
            ?? panic("Could not borrow a reference to the owner's collection")

        // withdraw the NFT from the owner's collection
        let nft <- collectionRef.withdraw(withdrawID: id)

        destroy nft
    }
}
