import NonFungibleToken from 0xNFTADDRESS
import ExampleNFT from 0xNFTCONTRACTADDRESS
// This transaction is what an account would run
// to set itself up to receive NFTs

transaction {
    prepare(acct: AuthAccount) {

        if acct.borrow<&ExampleNFT.Collection>(from: /storage/NFTCollection) == nil {

            let collection <- ExampleNFT.createEmptyCollection() as! @ExampleNFT.Collection
            
            acct.save(<-collection, to: /storage/NFTCollection)

            acct.link<&{NonFungibleToken.CollectionPublic}>(/public/NFTCollection, target: /storage/NFTCollection)
        }
    }
}
