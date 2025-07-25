import "NonFungibleToken"
import "MetadataViews"

/// Can pass in any contract address and name and NFT type name
/// This lets you choose the token you want to send because
/// the transaction gets the metadata from the provided contract.
///
/// @param to: The address to transfer the token to
/// @param id: The id of token to transfer
/// @param nftTypeIdentifier: The type identifier name of the NFT type you want to transfer
            /// Ex: "A.0b2a3299cc857e29.TopShot.NFT"
///
transaction(to: Address, id: UInt64, nftTypeIdentifier: String) {

    // The NFT resource to be transferred
    let tempNFT: @{NonFungibleToken.NFT}

    // NFTCollectionData struct to get paths from
    let collectionData: MetadataViews.NFTCollectionData

    prepare(signer: auth(BorrowValue) &Account) {

        self.collectionData = MetadataViews.resolveContractViewFromTypeIdentifier(
            resourceTypeIdentifier: nftTypeIdentifier,
            viewType: Type<MetadataViews.NFTCollectionData>()
        ) as? MetadataViews.NFTCollectionData
            ?? panic("Could not construct valid NFT type and view from identifier \(nftTypeIdentifier)")

        // borrow a reference to the signer's NFT collection
        let withdrawRef = signer.storage.borrow<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>(
                from: self.collectionData.storagePath
            ) ?? panic("The signer does not store a NFT Collection object at the path \(self.collectionData.storagePath)"
                        .concat("The signer must initialize their account with this collection first!"))

        self.tempNFT <- withdrawRef.withdraw(withdrawID: id)

        assert(
            self.tempNFT.getType().identifier == nftTypeIdentifier,
            message: "The NFT that was withdrawn to transfer is not the type that was requested <\(nftTypeIdentifier)>."
        )
    }

    execute {
        // get the recipients public account object
        let recipient = getAccount(to)

        // borrow a public reference to the receivers collection
        let receiverRef = recipient.capabilities.borrow<&{NonFungibleToken.Receiver}>(self.collectionData.publicPath)
            ?? panic("The recipient does not have a NonFungibleToken Receiver at \(self.collectionData.publicPath.toString())"
                        .concat(" that is capable of receiving a \(nftTypeIdentifier)."))

        // Deposit the NFT to the receiver
        receiverRef.deposit(token: <-self.tempNFT)
    }
}