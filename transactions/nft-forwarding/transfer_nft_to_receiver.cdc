import NonFungibleToken from "NonFungibleToken"
import ViewResolver from "ViewResolver"
import MetadataViews from "MetadataViews"

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
        let nftContract = getAccount(contractAddress).contracts.borrow<&ViewResolver>(name: contractName)
            ?? panic("Could not borrow ViewResolver reference to the contract")
            
        let collectionData = nftContract.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as MetadataViews.NFTCollectionData?
            ?? panic("Could not resolve NFTCollectionData view")

        // borrow a reference to the signer's NFT collection
        self.withdrawRef = signer.storage.borrow<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>(
                from: collectionData.storagePath
            ) ?? panic("Account does not store an object at the specified path")

        // borrow a public reference to the recipient's Receiver
        self.depositRef = getAccount(recipient).capabilities.borrow<&{NonFungibleToken.Receiver}>(
                collectionData.publicPath
            ) ?? panic("Could not borrow a reference to the recipient's Receiver")
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
