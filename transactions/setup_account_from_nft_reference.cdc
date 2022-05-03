import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"
import ExampleNFT from "../contracts/ExampleNFT.cdc"

transaction(address: Address, id: UInt64) {

    prepare(signer: AuthAccount) {
        let collection = getAccount(address)
            .getCapability(ExampleNFT.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>()
            ?? panic("Could not borrow a reference to the collection")

        let resolver = collection.borrowViewResolver(id: id)!
        let nftCollectionView = resolver.resolveView(Type<MetadataViews.NFTCollectionView>())! as! MetadataViews.NFTCollectionView

        // Create a new empty collections
        let emptyCollection <- nftCollectionView.createEmptyCollectionFunction()

        // save it to the account
        signer.save(<-emptyCollection, to: nftCollectionView.storagePath)

        // create a public capability for the collection
        signer.link<&{NonFungibleToken.CollectionPublic, ExampleNFT.ExampleNFTCollectionPublic}>(
            nftCollectionView.publicPath,
            target: nftCollectionView.storagePath
        )
    }
}
