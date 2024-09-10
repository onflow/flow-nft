/// This transaction is for transferring an ExampleNFT from one account to another

import "ViewResolver"
import "MetadataViews"
import "NonFungibleToken"

transaction(contractAddress: Address, contractName: String, recipient: Address, withdrawID: UInt64) {

    /// Reference to the withdrawer's collection
    let withdrawRef: auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}

    /// Reference of the collection to deposit the NFT to
    let receiverRef: &{NonFungibleToken.Receiver}

    prepare(signer: auth(BorrowValue) &Account) {

        // borrow the NFT contract as ViewResolver reference
        let viewResolver = getAccount(contractAddress).contracts.borrow<&{ViewResolver}>(name: contractName)
            ?? panic("Could not borrow ViewResolver reference to the contract. Make sure the provided contract name ("
                      .concat(contractName).concat(") and address (").concat(contractAddress.toString()).concat(") are correct!"))

        // resolve the NFT collection data from the NFT contract
        let collectionData = viewResolver.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("Could not resolve NFTCollectionData view. The ".concat(contractName).concat(" contract needs to implement the NFTCollectionData Metadata view in order to execute this transaction"))

        // borrow a reference to the signer's NFT collection
        self.withdrawRef = signer.storage.borrow<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>(
                from: collectionData.storagePath
            ) ?? panic("The signer does not store a "
                        .concat(contractName)
                        .concat(".Collection object at the path ")
                        .concat(collectionData.storagePath.toString())
                        .concat("The signer must initialize their account with this collection first!"))

        // get the recipients public account object
        let recipient = getAccount(recipient)

        // borrow a public reference to the receivers collection
        let receiverCap = recipient.capabilities.get<&{NonFungibleToken.Receiver}>(collectionData.publicPath)
        self.receiverRef = receiverCap.borrow()
            ?? panic("The recipient does not have a NonFungibleToken Receiver at "
                    .concat(collectionData.publicPath.toString())
                    .concat(" that is capable of receiving an NFT.")
                    .concat("The recipient must initialize their account with this collection and receiver first!"))
    }

    execute {

        let nft <- self.withdrawRef.withdraw(withdrawID: withdrawID)
        self.receiverRef.deposit(token: <-nft)

    }

    post {
        !self.withdrawRef.getIDs().contains(withdrawID): "Original owner should not have the NFT anymore"
    }
}
