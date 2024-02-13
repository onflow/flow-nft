import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"

/// Can pass in any contract address and name
/// This lets you choose the token you want to send because
/// the transaction gets the metadata from the provided contract.
///
transaction(to: Address, id: UInt64, contractAddress: Address, contractName: String) {

    // The NFT resource to be transferred
    let tempNFT: @{NonFungibleToken.NFT}

    // NFTCollectionData struct to get paths from
    let collectionData: MetadataViews.NFTCollectionData

    prepare(signer: auth(BorrowValue) &Account) {

        // Borrow a reference to the nft contract deployed to the passed account
        let resolverRef = getAccount(contractAddress)
            .contracts.borrow<&NonFungibleToken>(name: contractName)
            ?? panic("Could not borrow a reference to the non-fungible token contract")

        // Use that reference to retrieve the NFTCollectionData view 
        self.collectionData = resolverRef.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("Could not resolve the NFTCollectionData view for the given non-fungible token contract")


        // borrow a reference to the signer's NFT collection
        let withdrawRef = signer.storage.borrow<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>(
                from: self.collectionData.storagePath
            ) ?? panic("Account does not store a collection object at the specified path")

        self.tempNFT <- withdrawRef.withdraw(withdrawID: id)
    }

    execute {
        // get the recipients public account object
        let recipient = getAccount(to)

        // borrow a public reference to the receivers collection
        let receiverCap = recipient.capabilities.get<&{NonFungibleToken.Receiver}>(self.collectionData.publicPath)
            ?? panic("Could not get the recipient's Receiver Capability")

        let receiverRef = receiverCap.borrow()
            ?? panic("Could not borrow reference to the recipient's receiver")

        // Deposit the NFT to the receiver
        receiverRef.deposit(token: <-self.tempNFT)
    }
}