/// This script resolves all the supported views from
/// the ExampleNFT contract. Used for testing only.

import ExampleNFT from "ExampleNFT"
import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"

pub fun main(): Bool {
    // Call `resolveView` with invalid Type
    let view = ExampleNFT.resolveView(Type<String>())
    assert(nil == view)

    let collectionDisplay = (ExampleNFT.resolveView(
        Type<MetadataViews.NFTCollectionDisplay>()
    )as! MetadataViews.NFTCollectionDisplay?)!

    assert("The Example Collection" == collectionDisplay.name)
    assert("This collection is used as an example to help you develop your next Flow NFT." == collectionDisplay.description)
    assert("https://example-nft.onflow.org" == collectionDisplay.externalURL!.url)
    assert("https://twitter.com/flow_blockchain" == collectionDisplay.socials["twitter"]!.url)
    assert("https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg" == collectionDisplay.squareImage.file.uri())
    assert("https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg" == collectionDisplay.bannerImage.file.uri())

    let collectionData = (ExampleNFT.resolveView(
        Type<MetadataViews.NFTCollectionData>()
    ) as! MetadataViews.NFTCollectionData?)!

    assert(ExampleNFT.CollectionStoragePath == collectionData.storagePath)
    assert(ExampleNFT.CollectionPublicPath == collectionData.publicPath)
    assert(/private/exampleNFTCollection == collectionData.providerPath)
    assert(Type<&ExampleNFT.Collection{ExampleNFT.ExampleNFTCollectionPublic}>() == collectionData.publicCollection)
    assert(Type<&ExampleNFT.Collection{ExampleNFT.ExampleNFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>() == collectionData.publicLinkedType)
    assert(Type<&ExampleNFT.Collection{ExampleNFT.ExampleNFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Provider,MetadataViews.ResolverCollection}>() == collectionData.providerLinkedType)

    let coll <- collectionData.createEmptyCollection()
    assert(0 == coll.getIDs().length)

    destroy <- coll

    return true
}
