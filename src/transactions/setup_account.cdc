import NonFungibleToken from 0x02
import ExampleNFT from 0x03

// This transaction is what an account would run
// to set itself up to receive NFTs

transaction {

    prepare(signer: AuthAccount) {

        // Create a new empty NFT Collection resource and save it in storage
        let collection <- ExampleNFT.createEmptyCollection()
        signer.save(<-collection, to: /storage/NFTCollection)

        // Create a public capability for the stored collection.
        // Including the CollectionBorrow interface is optional,
        // in case a user doesn't want to expose their metadata
        //
        signer.link<&{NonFungibleToken.Receiver, ExampleNFT.CollectionBorrow}>(
            /public/NFTReceiver,
            target: /storage/NFTCollection
        )
    }
}
