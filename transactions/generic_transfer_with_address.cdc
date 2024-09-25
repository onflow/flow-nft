import "NonFungibleToken"
import "MetadataViews"

#interaction (
  version: "1.0.0",
	title: "Generic NFT Transfer with Contract Address and Name",
	description: "Transfer any Non-Fungible Token by providing the contract address and name",
	language: "en-US",
)

/// Can pass in any contract address and name
/// This lets you choose the token you want to send because
/// the transaction gets the metadata from the provided contract.
///
/// @param to: The address to transfer the token to
/// @param id: The id of token to transfer
/// @param contractAddress: The address of the contract that defines the token being transferred
/// @param contractName: The name of the contract that defines the token being transferred. Ex: "ExampleNFT"
///
/// This transaction only works with NFTs that have the type name "NFT"
/// A different transaction is required for NFTs with a different type name
///
transaction(to: Address, id: UInt64, contractAddress: Address, contractName: String) {

    // The NFT resource to be transferred
    let tempNFT: @{NonFungibleToken.NFT}

    // NFTCollectionData struct to get paths from
    let collectionData: MetadataViews.NFTCollectionData

    prepare(signer: auth(BorrowValue) &Account) {

        // Borrow a reference to the nft contract deployed to the passed account
        let resolverRef = getAccount(contractAddress)
            .contracts.borrow<&{NonFungibleToken}>(name: contractName)
                ?? panic("Could not borrow NonFungibleToken reference to the contract. Make sure the provided contract name ("
                          .concat(contractName).concat(") and address (").concat(contractAddress.toString()).concat(") are correct!"))

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
                        .concat(". The signer must initialize their account with this collection first!"))

        self.tempNFT <- withdrawRef.withdraw(withdrawID: id)

        // Get the string representation of the address without the 0x
        var addressString = contractAddress.toString()
        if addressString.length == 18 {
            addressString = addressString.slice(from: 2, upTo: 18)
        }
        let typeString: String = "A.".concat(addressString).concat(".").concat(contractName).concat(".NFT")
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
            message: "The NFT that was withdrawn to transfer is not the type that was requested <"
                     .concat(typeString).concat(">.")
        )
    }

    execute {
        // get the recipients public account object
        let recipient = getAccount(to)

        // borrow a public reference to the receivers collection
        let receiverRef = recipient.capabilities.borrow<&{NonFungibleToken.Receiver}>(self.collectionData.publicPath)
            ?? panic("The recipient does not have a NonFungibleToken Receiver at "
                        .concat(self.collectionData.publicPath.toString())
                        .concat(" that is capable of receiving a ")
                        .concat(contractName)
                        .concat(" NFT.")
                        .concat("The recipient must initialize their account with this collection and receiver first!"))

        // Deposit the NFT to the receiver
        receiverRef.deposit(token: <-self.tempNFT)
    }
}