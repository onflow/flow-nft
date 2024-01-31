/// This transaction is for transferring an ExampleNFT from one account to another

import "ViewResolver"
import "MetadataViews"
import "NonFungibleToken"
import "ExampleNFT"

transaction(contractAddress: Address, contractName: String, recipient: Address, withdrawID: UInt64) {

    /// Reference to the withdrawer's collection
    let withdrawRef: auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}

    /// Reference of the collection to deposit the NFT to
    let receiverRef: &{NonFungibleToken.Receiver}

    prepare(signer: auth(BorrowValue) &Account) {

        // borrow the NFT contract as ViewResolver reference
        let viewResolver = getAccount(contractAddress).contracts.borrow<&ViewResolver>(name: contractName)
            ?? panic("Could not borrow ViewResolver of given name from address")

        // resolve the NFT collection data from the NFT contract
        let collectionData = viewResolver.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("ViewResolver does not resolve NFTCollectionData view")

        // borrow a reference to the signer's NFT collection
        self.withdrawRef = signer.storage.borrow<auth(NonFungibleToken.Withdraw) &{NonFungibleToken.Collection}>(
                from: collectionData.storagePath
            ) ?? panic("Account does not store an object at the specified path")

        // get the recipients public account object
        let recipient = getAccount(recipient)

        // borrow a public reference to the receivers collection
        let receiverCap = recipient.capabilities.get<&{NonFungibleToken.Receiver}>(collectionData.publicPath)
            ?? panic("Could not get the recipient's Receiver Capability")

        self.receiverRef = receiverCap.borrow()
            ?? panic("Could not borrow reference to the recipient's receiver")

    }

    execute {

        let nft <- self.withdrawRef.withdraw(withdrawID: withdrawID)
        self.receiverRef.deposit(token: <-nft)

    }

    post {
        !self.withdrawRef.getIDs().contains(withdrawID): "Original owner should not have the NFT anymore"
    }
}
