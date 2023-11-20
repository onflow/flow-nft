/// This script checks the NFTView from MetadataViews for
/// a given NFT. Used for testing only.

import "ExampleNFT"
import "MetadataViews"
import "ViewResolver"

access(all) struct NFTView {
    access(all) let id: UInt64
    access(all) let uuid: UInt64
    access(all) let name: String
    access(all) let description: String
    access(all) let thumbnail: String
    access(all) let royalties: [MetadataViews.Royalty]
    access(all) let externalURL: String
    access(all) let collectionPublicPath: PublicPath
    access(all) let collectionStoragePath: StoragePath
    access(all) let collectionProviderPath: PrivatePath
    access(all) let collectionPublic: String
    access(all) let collectionPublicLinkedType: String
    access(all) let collectionProviderLinkedType: String
    access(all) let collectionName: String
    access(all) let collectionDescription: String
    access(all) let collectionExternalURL: String
    access(all) let collectionSquareImage: String
    access(all) let collectionBannerImage: String
    access(all) let collectionSocials: {String: String}
    access(all) let traits: MetadataViews.Traits

    init(
        id: UInt64,
        uuid: UInt64,
        name: String,
        description: String,
        thumbnail: String,
        royalties: [MetadataViews.Royalty],
        externalURL: String,
        collectionPublicPath: PublicPath,
        collectionStoragePath: StoragePath,
        collectionProviderPath: PrivatePath,
        collectionPublic: String,
        collectionPublicLinkedType: String,
        collectionProviderLinkedType: String,
        collectionName: String,
        collectionDescription: String,
        collectionExternalURL: String,
        collectionSquareImage: String,
        collectionBannerImage: String,
        collectionSocials: {String: String},
        traits: MetadataViews.Traits
    ) {
        self.id = id
        self.uuid = uuid
        self.name = name
        self.description = description
        self.thumbnail = thumbnail
        self.royalties = royalties
        self.externalURL = externalURL
        self.collectionPublicPath = collectionPublicPath
        self.collectionStoragePath = collectionStoragePath
        self.collectionProviderPath = collectionProviderPath
        self.collectionPublic = collectionPublic
        self.collectionPublicLinkedType = collectionPublicLinkedType
        self.collectionProviderLinkedType = collectionProviderLinkedType
        self.collectionName = collectionName
        self.collectionDescription = collectionDescription
        self.collectionExternalURL = collectionExternalURL
        self.collectionSquareImage = collectionSquareImage
        self.collectionBannerImage = collectionBannerImage
        self.collectionSocials = collectionSocials
        self.traits = traits
    }
}

access(all) fun main(address: Address, id: UInt64): Bool {
    let account = getAccount(address)

    let collectionData = ExampleNFT.resolveView(Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
        ?? panic("ViewResolver does not resolve NFTCollectionData view")
    
    let collection = account.capabilities.borrow<&{ViewResolver.ResolverCollection}>(
            collectionData.publicPath
        ) ?? panic("Could not borrow a reference to the collection")

    let viewResolver = collection.borrowViewResolver(id: id)!

    let nftView = MetadataViews.getNFTView(id: id, viewResolver: viewResolver)

    let collectionSocials: {String: String} = {}
    for key in nftView.collectionDisplay!.socials.keys {
        collectionSocials[key] = nftView.collectionDisplay!.socials[key]!.url
    }


    let nftViewResult = NFTView(
        id: nftView.id,
        uuid: nftView.uuid,
        name: nftView.display!.name,
        description: nftView.display!.description,
        thumbnail: nftView.display!.thumbnail.uri(),
        royalties: nftView.royalties!.getRoyalties(),
        externalURL: nftView.externalURL!.url,
        collectionPublicPath: nftView.collectionData!.publicPath,
        collectionStoragePath: nftView.collectionData!.storagePath,
        collectionProviderPath: nftView.collectionData!.providerPath,
        collectionPublic: nftView.collectionData!.publicCollection.identifier,
        collectionPublicLinkedType: nftView.collectionData!.publicLinkedType.identifier,
        collectionProviderLinkedType: nftView.collectionData!.providerLinkedType.identifier,
        collectionName: nftView.collectionDisplay!.name,
        collectionDescription: nftView.collectionDisplay!.description,
        collectionExternalURL: nftView.collectionDisplay!.externalURL.url,
        collectionSquareImage: nftView.collectionDisplay!.squareImage.file.uri(),
        collectionBannerImage: nftView.collectionDisplay!.bannerImage.file.uri(),
        collectionSocials: collectionSocials,
        traits: nftView.traits!,
    )

    // assert((0 as UInt64) == nftViewResult.id)
    assert(nil != nftViewResult.uuid)
    assert("NFT Name" == nftViewResult.name)
    assert("NFT Description" == nftViewResult.description)
    assert("NFT Thumbnail" == nftViewResult.thumbnail)
    assert("Creator Royalty" == nftViewResult.royalties[0].description)
    assert(Address(0x0000000000000007) == nftViewResult.royalties[0].receiver.address)
    assert(0.05 == nftViewResult.royalties[0].cut)
    assert("https://example-nft.onflow.org/0" == nftViewResult.externalURL)
    assert(/public/exampleNFTCollection == nftViewResult.collectionPublicPath)
    assert(/storage/exampleNFTCollection == nftViewResult.collectionStoragePath)
    assert(/private/exampleNFTCollection == nftViewResult.collectionProviderPath)
    assert("&A.0000000000000007.ExampleNFT.Collection{A.0000000000000007.ExampleNFT.ExampleNFTCollectionPublic}" == nftViewResult.collectionPublic)
    assert("&A.0000000000000007.ExampleNFT.Collection{A.0000000000000007.ExampleNFT.ExampleNFTCollectionPublic,A.0000000000000001.NonFungibleToken.CollectionPublic,A.0000000000000001.NonFungibleToken.Receiver,A.0000000000000001.MetadataViews.ResolverCollection}" == nftViewResult.collectionPublicLinkedType)
    assert("&A.0000000000000007.ExampleNFT.Collection{A.0000000000000007.ExampleNFT.ExampleNFTCollectionPublic,A.0000000000000001.NonFungibleToken.CollectionPublic,A.0000000000000001.NonFungibleToken.Provider,A.0000000000000001.MetadataViews.ResolverCollection}" == nftViewResult.collectionProviderLinkedType)
    assert("The Example Collection" == nftViewResult.collectionName)
    assert("This collection is used as an example to help you develop your next Flow NFT." == nftViewResult.collectionDescription)
    assert("https://example-nft.onflow.org" == nftViewResult.collectionExternalURL)
    assert("https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg" == nftViewResult.collectionSquareImage)
    assert("https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg" == nftViewResult.collectionBannerImage)
    assert({"twitter": "https://twitter.com/flow_blockchain"} == nftViewResult.collectionSocials)
    assert("Common" == nftViewResult.traits.traits[2]!.rarity!.description)
    assert(10.0 == nftViewResult.traits.traits[2]!.rarity!.score)
    assert(100.0 == nftViewResult.traits.traits[2]!.rarity!.max)

    return true
}
