/// This script checks all views from MetadataViews for
/// a given NFT. Used for testing only.

import "ExampleNFT"
import "MetadataViews"

pub struct NFT {
    pub let name: String
    pub let description: String
    pub let thumbnail: String
    pub let owner: Address
    pub let type: String
    pub let royalties: [MetadataViews.Royalty]
    pub let externalURL: String
    pub let serialNumber: UInt64
    pub let collectionPublicPath: PublicPath
    pub let collectionStoragePath: StoragePath
    pub let collectionProviderPath: PrivatePath
    pub let collectionPublic: String
    pub let collectionPublicLinkedType: String
    pub let collectionProviderLinkedType: String
    pub let collectionName: String
    pub let collectionDescription: String
    pub let collectionExternalURL: String
    pub let collectionSquareImage: String
    pub let collectionBannerImage: String
    pub let collectionSocials: {String: String}
    pub let edition: MetadataViews.Edition
    pub let traits: MetadataViews.Traits
    pub let medias: MetadataViews.Medias?
    pub let license: MetadataViews.License?
    pub let bridgedName: String
    pub let symbol: String
    pub let tokenURI: String

    init(
        name: String,
        description: String,
        thumbnail: String,
        owner: Address,
        nftType: String,
        royalties: [MetadataViews.Royalty],
        externalURL: String,
        serialNumber: UInt64,
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
        edition: MetadataViews.Edition,
        traits: MetadataViews.Traits,
        medias: MetadataViews.Medias?,
        license: MetadataViews.License?,
        bridgedName: String,
        symbol: String,
        tokenURI: String
    ) {
        self.name = name
        self.description = description
        self.thumbnail = thumbnail
        self.owner = owner
        self.type = nftType
        self.royalties = royalties
        self.externalURL = externalURL
        self.serialNumber = serialNumber
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
        self.edition = edition
        self.traits = traits
        self.medias = medias
        self.license = license
        self.bridgedName = bridgedName
        self.symbol = symbol
        self.tokenURI = tokenURI
    }
}

pub fun main(address: Address, id: UInt64): Bool {
    let account = getAccount(address)

    let collection = account
        .getCapability(ExampleNFT.CollectionPublicPath)
        .borrow<&{ExampleNFT.ExampleNFTCollectionPublic}>()
        ?? panic("Could not borrow a reference to the collection")

    let nft = collection.borrowExampleNFT(id: id)!

    // Get the basic display information for this NFT
    let display = MetadataViews.getDisplay(nft)!

    // Get the royalty information for the given NFT
    let royaltyView = MetadataViews.getRoyalties(nft)!

    let externalURL = MetadataViews.getExternalURL(nft)!

    let collectionDisplay = MetadataViews.getNFTCollectionDisplay(nft)!
    let nftCollectionView = MetadataViews.getNFTCollectionData(nft)!

    let nftEditionView = MetadataViews.getEditions(nft)!
    let serialNumberView = MetadataViews.getSerial(nft)!

    let owner: Address = nft.owner!.address!
    let nftType = nft.getType()

    let collectionSocials: {String: String} = {}
    for key in collectionDisplay.socials.keys {
        collectionSocials[key] = collectionDisplay.socials[key]!.url
    }

    let traits = MetadataViews.getTraits(nft)!

    let medias = MetadataViews.getMedias(nft)
    let license = MetadataViews.getLicense(nft)

    let bridgedMetadata = MetadataViews.getEVMBridgedMetadata(nft)!

    let nftMetadata = NFT(
        name: display.name,
        description: display.description,
        thumbnail: display.thumbnail.uri(),
        owner: owner,
        nftType: nftType.identifier,
        royalties: royaltyView.getRoyalties(),
        externalURL: externalURL.url,
        serialNumber: serialNumberView.number,
        collectionPublicPath: nftCollectionView.publicPath,
        collectionStoragePath: nftCollectionView.storagePath,
        collectionProviderPath: nftCollectionView.providerPath,
        collectionPublic: nftCollectionView.publicCollection.identifier,
        collectionPublicLinkedType: nftCollectionView.publicLinkedType.identifier,
        collectionProviderLinkedType: nftCollectionView.providerLinkedType.identifier,
        collectionName: collectionDisplay.name,
        collectionDescription: collectionDisplay.description,
        collectionExternalURL: collectionDisplay.externalURL.url,
        collectionSquareImage: collectionDisplay.squareImage.file.uri(),
        collectionBannerImage: collectionDisplay.bannerImage.file.uri(),
        collectionSocials: collectionSocials,
        edition: nftEditionView.infoList[0],
        traits: traits,
        medias: medias,
        license: license,
        bridgedName: bridgedMetadata.name,
        symbol: bridgedMetadata.symbol,
        tokenURI: bridgedMetadata.uri.uri()
    )

    assert("NFT Name" == nftMetadata.name)
    assert("NFT Description" == nftMetadata.description)
    assert("NFT Thumbnail" == nftMetadata.thumbnail)
    assert(Address(0x0000000000000007) == nftMetadata.owner)
    assert("A.0000000000000007.ExampleNFT.NFT" == nftMetadata.type)
    assert("Creator Royalty" == nftMetadata.royalties[0].description)
    assert(Address(0x0000000000000007) == nftMetadata.royalties[0].receiver.address)
    assert(0.05 == nftMetadata.royalties[0].cut)
    assert("https://example-nft.onflow.org/0" == nftMetadata.externalURL)
    assert((0 as UInt64) == nftMetadata.serialNumber)
    assert(/public/exampleNFTCollection == nftMetadata.collectionPublicPath)
    assert(/storage/exampleNFTCollection == nftMetadata.collectionStoragePath)
    assert(/private/exampleNFTCollection == nftMetadata.collectionProviderPath)
    assert("&A.0000000000000007.ExampleNFT.Collection{A.0000000000000007.ExampleNFT.ExampleNFTCollectionPublic}" == nftMetadata.collectionPublic)
    assert("&A.0000000000000007.ExampleNFT.Collection{A.0000000000000007.ExampleNFT.ExampleNFTCollectionPublic,A.0000000000000001.NonFungibleToken.CollectionPublic,A.0000000000000001.NonFungibleToken.Receiver,A.0000000000000007.MetadataViews.ResolverCollection}" == nftMetadata.collectionPublicLinkedType)
    assert("&A.0000000000000007.ExampleNFT.Collection{A.0000000000000007.ExampleNFT.ExampleNFTCollectionPublic,A.0000000000000001.NonFungibleToken.CollectionPublic,A.0000000000000001.NonFungibleToken.Provider,A.0000000000000007.MetadataViews.ResolverCollection}" == nftMetadata.collectionProviderLinkedType)
    assert("The Example Collection" == nftMetadata.collectionName)
    assert("This collection is used as an example to help you develop your next Flow NFT." == nftMetadata.collectionDescription)
    assert("https://example-nft.onflow.org" == nftMetadata.collectionExternalURL)
    assert("https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg" == nftMetadata.collectionSquareImage)
    assert("https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg" == nftMetadata.collectionBannerImage)
    assert({"twitter": "https://twitter.com/flow_blockchain"} == nftMetadata.collectionSocials)
    assert("Example NFT Edition" == nftMetadata.edition.name)
    assert((0 as UInt64) == nftMetadata.edition.number)
    assert(nil == nftMetadata.edition.max)
    assert("Common" == nftMetadata.traits.traits[3]!.rarity!.description)
    assert(10.0 == nftMetadata.traits.traits[3]!.rarity!.score)
    assert(100.0 == nftMetadata.traits.traits[3]!.rarity!.max)
    assert(nil == nftMetadata.medias)
    assert(nil == nftMetadata.license)
    assert("ExampleNFT" == nftMetadata.bridgedName)
    assert("XMPL" == nftMetadata.symbol, message: "Symbol is ".concat(nftMetadata.symbol))
    assert("https://example-nft.onflow.org/token-metadata/".concat(id.toString()).concat(".json") == nftMetadata.tokenURI)

    let coll <- nftCollectionView.createEmptyCollection()
    assert(0 == coll.getIDs().length)
    destroy <- coll

    return true
}
