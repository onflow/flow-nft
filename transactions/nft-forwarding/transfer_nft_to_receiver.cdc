import "NonFungibleToken"
import "ViewResolver"
import "MetadataViews"

/// This transaction is for transferring an NFT from one account to the recipient's Receiver
///
transaction(
    contractAddress: Address,
    contractName: String,
    recipient: Address,
    withdrawID: UInt64
) {

    // reference to the withdrawer's collection
    let withdrawRef: auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}
    // reference of the Receiver to deposit the NFT to
    let depositRef: &{NonFungibleToken.Receiver}

    prepare(signer: auth(BorrowValue) &Account) {

        // get the collection data from the NFT contract
        let nftContract = getAccount(contractAddress).contracts.borrow<&{ViewResolver}>(name: contractName)
            ?? panic("Could not borrow ViewResolver reference to the contract. Make sure the provided contract name "
                      .concat(contractName).concat(" and address ").concat(contractAddress.toString()).concat(" are correct!"))
            
        let collectionData = nftContract.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as MetadataViews.NFTCollectionData?
            ?? panic("Could not resolve NFTCollectionData view. The ".concat(contractName).concat(" contract needs to implement the NFTCollectionData Metadata view in order to execute this transaction"))

        // borrow a reference to the signer's NFT collection
        self.withdrawRef = signer.storage.borrow<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>(
                from: collectionData.storagePath
            ) ?? panic("The signer does not store a "
                        .concat(contractName)
                        .concat(".Collection object at the path ")
                        .concat(collectionData.storagePath.toString())
                        .concat("The signer must initialize their account with this collection first!"))

        // borrow a public reference to the recipient's Receiver
        self.depositRef = getAccount(recipient).capabilities.borrow<&{NonFungibleToken.Receiver}>(
                collectionData.publicPath
            ) ?? panic("The recipient does not have a NonFungibleToken Receiver at "
                        .concat(collectionData.publicPath.toString())
                        .concat(" that is capable of receiving a ")
                        .concat(contractName)
                        .concat(" NFT.")
                        .concat("The recipient must initialize their account with this collection and receiver first!"))
    }

    execute {

        // withdraw the NFT from the owner's collection
        let nft <- self.withdrawRef.withdraw(withdrawID: withdrawID)

        // Deposit the NFT in the recipient
        self.depositRef.deposit(token: <-nft)
    }

    post {
        !self.withdrawRef.getIDs().contains(withdrawID): "Original owner should not have the NFT anymore"
    }
}
