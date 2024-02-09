/// This transaction is what an account would run
/// to set itself up to receive NFTs. This function
/// uses views to know where to set up the collection
/// in storage and to create the empty collection.

import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"

transaction(contractAddress: Address, contractName: String) {

    prepare(signer: auth(IssueStorageCapabilityController, PublishCapability, SaveValue) &Account) {
        // Borrow a reference to the nft contract deployed to the passed account
        let resolverRef = getAccount(contractAddress)
            .contracts.borrow<&NonFungibleToken>(name: contractName)
            ?? panic("Could not borrow a reference to the non-fungible token contract")

        // Use that reference to retrieve the NFTCollectionData view 
        let collectionData = resolverRef.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
            ?? panic("Could not resolve the NFTCollectionData view for the given non-fungible token contract")

        // Create a new empty collections
        let emptyCollection <- collectionData.createEmptyCollection()

        // save it to the account
        signer.storage.save(<-emptyCollection, to: collectionData.storagePath)

        // create a public capability for the collection
        let collectionCap = signer.capabilities.storage.issue<&{NonFungibleToken.Collection}>(
                collectionData.storagePath
            )
        signer.capabilities.publish(collectionCap, at: collectionData.publicPath)
    }
}
