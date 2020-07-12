import NonFungibleToken from 0xNFTADDRESS
import ExampleNFT from 0xNFTCONTRACTADDRESS
// This transaction is what an account would run
// to set itself up to receive NFTs

transaction {
    prepare(acct: AuthAccount) {

        // If the account doesn't already have a collection
        if acct.borrow<&ExampleNFT.Collection>(from: /storage/NFTCollection) == nil {

            // Create a new empty collection
            let collection <- ExampleNFT.createEmptyCollection() as! @ExampleNFT.Collection
            
            // save it to the account
            acct.save(<-collection, to: /storage/NFTCollection)

            // create a public capability for the collection
            acct.link<&{NonFungibleToken.CollectionPublic}>(/public/NFTCollection, target: /storage/NFTCollection)
        }
    }
}
