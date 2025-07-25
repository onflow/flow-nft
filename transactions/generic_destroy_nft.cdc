/// This transaction withdraws one or more NFTs from the signers collection and destroys them
/// The NFTs must all be of the same type

/// Imports to replace with "from {Address}"
import "NonFungibleToken"
import "MetadataViews"
import "Burner"

/// @param nftTypeIdentifier: The type identifier name of the NFT type you want to destroy.
///                    
/// @param ids: An array of ID of the NFTs you would like to destroy

/// Example (With Top Shot):
/// transaction(nftTypeIdentifier: "A.0b2a3299cc857e29.TopShot.NFT", ids: [14337, 337282, 3722711]) {

transaction(nftTypeIdentifier: String, ids: [UInt64]) {

    /// Reference to the owner's collection to destroy NFTs from
    let withdrawRef: auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}

    prepare(signer: auth(BorrowValue) &Account) {

        let collectionData = MetadataViews.resolveContractViewFromTypeIdentifier(
            resourceTypeIdentifier: nftTypeIdentifier,
            viewType: Type<MetadataViews.NFTCollectionData>()
        ) as? MetadataViews.NFTCollectionData
            ?? panic("Could not construct valid NFT type and view from identifier \(nftTypeIdentifier)")

        // borrow a reference to the signer's NFT collection
        self.withdrawRef = signer.storage.borrow<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>(
                from: collectionData.storagePath
            ) ?? panic("The signer does not store an NFT Collection object at the path "
                        .concat(collectionData.storagePath.toString())
                        .concat("The signer must initialize their account with this collection first!"))
    }

    execute {

        // iterate through the ids and burn each one
        for id in ids {

            if self.withdrawRef.borrowNFT(id) == nil { continue }

            let tempNFT <- self.withdrawRef.withdraw(withdrawID: id)

            assert(
                tempNFT.getType().identifier == nftTypeIdentifier,
                message: "The type NFT that was withdrawn to destroy <\(tempNFT.getType().identifier)"
                        .concat("> is not the type that was requested <\(nftTypeIdentifier)>.")
            )

            Burner.burn(<-tempNFT)
        }
    }
}
