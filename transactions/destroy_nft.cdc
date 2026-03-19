/// This transaction withdraws an NFT from the signers collection and destroys it

import "NonFungibleToken"
import "MetadataViews"
import "ExampleNFT"
import "Burner"

transaction(id: UInt64) {

    /// Reference that will be used for the owner's collection
    let collectionRef: auth(NonFungibleToken.Withdraw) &ExampleNFT.Collection

    prepare(signer: auth(BorrowValue) &Account) {
        let collectionData = ExampleNFT.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("Could not resolve the NFTCollectionData view for ExampleNFT. The ExampleNFT contract needs to implement the NFTCollectionData metadata view in order to execute this transaction")
            
        // borrow a reference to the owner's collection
        self.collectionRef = signer.storage.borrow<auth(NonFungibleToken.Withdraw) &ExampleNFT.Collection>(
                from: collectionData.storagePath
            ) ?? panic("The signer does not store an ExampleNFT.Collection object at the path \(collectionData.storagePath). The signer must initialize their account with this collection first!")

    }

    execute {

        // withdraw the NFT from the owner's collection
        let nft <- self.collectionRef.withdraw(withdrawID: id)

        Burner.burn(<-nft)
    }

    post {
        !self.collectionRef.getIDs().contains(id): "The NFT with the specified ID should have been deleted."
    }
}
