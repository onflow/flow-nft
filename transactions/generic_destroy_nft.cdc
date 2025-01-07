/// This transaction withdraws an NFT from the signers collection and destroys it

/// Imports to replace with "from {Address}"
import "NonFungibleToken"
import "MetadataViews"
import "Burner"

/// @param contractAddress: The address of the contract for the NFT you want to destroy
///                         Example: For Top Shot on mainnet, 0x0b2a3299cc857e29
/// @param contractName: The name of the contract for the NFT you want to destroy.
///                      Example: "TopShot", "AllDay", etc
/// @param nftTypeName: The name of the NFT type you want to destroy.
///                     99% of the time it is "NFT"
/// @param id: The ID of the NFT you would like to destroy

/// Replace each instance of the params above with the values that you want to use

transaction(contractAddress: Address, contractName: String, nftTypeName: String, id: UInt64) {

    // The NFT resource to be transferred
    let tempNFT: @{NonFungibleToken.NFT}

    // NFTCollectionData struct to get paths from
    let collectionData: MetadataViews.NFTCollectionData

    prepare(signer: auth(BorrowValue) &Account) {
        // Borrow a reference to the nft contract deployed to the passed account
        let resolverRef = getAccount(contractAddress)
            .contracts.borrow<&{NonFungibleToken}>(name: contractName)
                ?? panic("Could not borrow NonFungibleToken reference to the contract. Make sure the provided contract name "
                          .concat(contractName).concat(" and address ").concat(contractAddress.toString()).concat(" are correct!"))

        // Use that reference to retrieve the NFTCollectionData view 
        self.collectionData = resolverRef.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("Could not resolve NFTCollectionData view. The ".concat(contractName).concat(" contract needs to implement the NFTCollectionData Metadata view in order to execute this transaction"))

        // borrow a reference to the signer's NFT collection
        let withdrawRef = signer.storage.borrow<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>(
                from: self.collectionData.storagePath
            ) ?? panic("The signer does not store a "
                        .concat(contractName)
                        .concat(" Collection object at the path ")
                        .concat(self.collectionData.storagePath.toString())
                        .concat("The signer must initialize their account with this collection first!"))

                self.tempNFT <- withdrawRef.withdraw(withdrawID: id)

        // Get the string representation of the address without the 0x
        var addressString = contractAddress.toString()
        if addressString.length == 18 {
            addressString = addressString.slice(from: 2, upTo: 18)
        }
        let typeString: String = "A.".concat(addressString).concat(".").concat(contractName).concat(".").concat(nftTypeName)
        let type = CompositeType(typeString)
        assert(
            type != nil,
            message: "Could not create a type out of the contract name "
                      .concat(contractName)
                      .concat(" and address ")
                      .concat(addressString)
                      .concat("!")
        )

        assert(
            self.tempNFT.getType() == type!,
            message: "The type NFT that was withdrawn to destroy <"
                     .concat(self.tempNFT.getType().identifier)
                     .concat("> is not the type that was requested <")
                     .concat(typeString).concat(">.")
        )
    }

    execute {

        Burner.burn(<-self.tempNFT)
    }

    post {
        !self.collectionRef.getIDs().contains(id): "The NFT with the specified ID should have been destroyed."
    }
}
