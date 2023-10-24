/// This transaction is for transferring an ExampleNFT from one account to another

import ViewResolver from "ViewResolver"
import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"

transaction(contractAddress: Address, contractName: String, recipient: Address, withdrawID: UInt64) {

    /// Reference to the withdrawer's collection
    let withdrawRef: auth(NonFungibleToken.Withdrawable) &{NonFungibleToken.Collection}

    /// Reference of the collection to deposit the NFT to
    let receiverCap: Capability<&{NonFungibleToken.Receiver}>

    prepare(signer: auth(BorrowValue) &Account) {

        // borrow the NFT contract as ViewResolver reference
        let viewResolver = getAccount(contractAddress).contracts.borrow<&ViewResolver>(name: contractName)
            ?? panic("Could not borrow ViewResolver of given name from address")

        // resolve the NFT collection data from the NFT contract
        let collectionData = viewResolver.resolveView(Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("ViewResolver does not resolve NFTCollectionData view")

        // borrow a reference to the signer's NFT collection
        self.withdrawRef = signer.storage.borrow<auth(NonFungibleToken.Withdrawable) &{NonFungibleToken.Collection}>(
                from: collectionData.storagePath
            ) ?? panic("Account does not store an object at the specified path")

        // get the recipients public account object
        let recipient = getAccount(recipient)

        // borrow a public reference to the receivers collection
        self.receiverCap = recipient.capabilities.get<&{NonFungibleToken.Receiver}>(collectionData.publicPath)
            ?? panic("Could not get the recipient's the Receiver Capability")

    }

    execute {

        // Transfer the NFT between the accounts - returns true if error, false if successful
        let error = self.withdrawRef.transfer(id: withdrawID, receiver: self.receiverCap)
        assert(error == false, message: "Problem executing transfer")

    }

    post {
        !self.withdrawRef.getIDs().contains(withdrawID): "Original owner should not have the NFT anymore"
    }
}
