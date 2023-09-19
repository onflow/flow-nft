/// This transaction is what an account would run
/// to set itself up to receive NFTs. This function
/// uses views to know where to set up the collection
/// in storage and to create the empty collection.

import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"
import ExampleNFT from "ExampleNFT"

transaction(address: Address, publicPath: PublicPath, id: UInt64) {

    prepare(signer: auth(Capabilities, Storage) &Account) {
        let collection = getAccount(address)
            .capabilities.borrow<&{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>(publicPath)
            ?? panic("Could not borrow a reference to the collection")

        let resolver = collection.borrowViewResolver(id: id)!
        let nftCollectionView = resolver.resolveView(Type<MetadataViews.NFTCollectionData>())! as! MetadataViews.NFTCollectionData

        // Create a new empty collections
        let emptyCollection <- nftCollectionView.createEmptyCollection()

        // save it to the account
        signer.storage.save(<-emptyCollection, to: nftCollectionView.storagePath)

        // create a public capability for the collection
        let collectionCap = signer.capabilities.storage
            .issue<&{NonFungibleToken.CollectionPublic, ExampleNFT.ExampleNFTCollectionPublic, MetadataViews.ResolverCollection}>(
                nftCollectionView.storagePath
            )

        signer.capabilities.publish(
            collectionCap,
            at: nftCollectionView.publicPath,
        )
    }
}
