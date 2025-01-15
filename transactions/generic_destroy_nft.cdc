/// This transaction withdraws one or more NFTs from the signers collection and destroys them
/// The NFTs must all be of the same type

/// Imports to replace with "from {Address}"
import "NonFungibleToken"
import "MetadataViews"
import "Burner"

/// @param contractAddress: The address of the contract for the NFTs you want to destroy
///                         Example: For Top Shot on mainnet, 0x0b2a3299cc857e29
/// @param contractName: The name of the contract for the NFTs you want to destroy.
///                      Example: "TopShot", "AllDay", etc
/// @param nftTypeName: The name of the NFT type you want to destroy.
///                     99% of the time it is "NFT"
/// @param ids: An array of ID of the NFTs you would like to destroy

/// Replace each instance of the params above with the values that you want to use
/// Example (With Top Shot):
/// transaction(contractAddress: 0x0b2a3299cc857e29, contractName: "TopShot", nftTypeName: "NFT", ids: [14337, 337282, 3722711]) {

transaction(contractAddress: Address, contractName: String, nftTypeName: String, ids: [UInt64]) {

    /// The string representation of the NFT type
    let typeString: String

    /// The NFT type to be destroyed
    let type: Type?

    /// NFTCollectionData struct to get paths from
    let collectionData: MetadataViews.NFTCollectionData

    /// Reference to the owner's collection to destroy NFTs from
    let withdrawRef: auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}

    prepare(signer: auth(BorrowValue) &Account) {
        // Borrow a reference to the nft contract deployed to the passed account
        let resolverRef = getAccount(contractAddress)
            .contracts.borrow<&{NonFungibleToken}>(name: contractName)
                ?? panic("Could not borrow NonFungibleToken reference to the contract. Make sure the provided contract name "
                          .concat(contractName).concat(" and address ").concat(contractAddress.toString()).concat(" are correct!"))

        // Get the string representation of the address without the 0x
        var addressString = contractAddress.toString()
        if addressString.length == 18 {
            addressString = addressString.slice(from: 2, upTo: 18)
        }

        self.typeString = "A.".concat(addressString).concat(".").concat(contractName).concat(".").concat(nftTypeName)
        self.type = CompositeType(self.typeString)
        
        assert(
            self.type != nil,
            message: "Could not create a type out of the contract name "
                    .concat(contractName)
                    .concat(" and address ")
                    .concat(addressString)
                    .concat("!")
        )

        // Use that reference to retrieve the NFTCollectionData view 
        self.collectionData = resolverRef.resolveContractView(resourceType: self.type!, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("Could not resolve NFTCollectionData view. The ".concat(contractName).concat(" contract needs to implement the NFTCollectionData Metadata view in order to execute this transaction"))

        // borrow a reference to the signer's NFT collection
        self.withdrawRef = signer.storage.borrow<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>(
                from: self.collectionData.storagePath
            ) ?? panic("The signer does not store a "
                        .concat(contractName)
                        .concat(" Collection object at the path ")
                        .concat(self.collectionData.storagePath.toString())
                        .concat("The signer must initialize their account with this collection first!"))
    }

    execute {

        // iterate through the ids and burn each one
        for id in ids {

            if self.withdrawRef.borrowNFT(id) == nil { continue }

            let tempNFT <- self.withdrawRef.withdraw(withdrawID: id)

            assert(
                tempNFT.getType() == self.type!,
                message: "The type NFT that was withdrawn to destroy <"
                        .concat(tempNFT.getType().identifier)
                        .concat("> is not the type that was requested <")
                        .concat(self.typeString).concat(">.")
            )

            Burner.burn(<-tempNFT)
        }
    }
}
