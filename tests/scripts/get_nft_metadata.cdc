/// This script checks all views from MetadataViews for
/// a given NFT. Used for testing only.

import ExampleNFT from "ExampleNFT"
import MetadataViews from "MetadataViews"

access(all) struct NFT {
    access(all) let name: String
    access(all) let description: String
    access(all) let thumbnail: String
    access(all) let owner: Address
    access(all) let type: String
    access(all) let royalties: [MetadataViews.Royalty]
    access(all) let externalURL: String
    access(all) let serialNumber: UInt64
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
    access(all) let edition: MetadataViews.Edition
    access(all) let traits: MetadataViews.Traits
    access(all) let medias: MetadataViews.Medias?
    access(all) let license: MetadataViews.License?

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
        license: MetadataViews.License?
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
    }
}

access(all) fun main(address: Address, id: UInt64): Bool {
    let account = getAccount(address)

    let collectionData = ExampleNFT.resolveView(Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
        ?? panic("ViewResolver does not resolve NFTCollectionData view")
    
    let collection = account.capabilities.borrow<&ExampleNFT.Collection>(
            collectionData.publicPath
        ) ?? panic("Could not borrow a reference to the collection")

    let nft = collection.borrowNFT(id)

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
        license: license
    )

    assert("NFT Name" == nftMetadata.name)
    assert("NFT Description" == nftMetadata.description)
    assert("NFT Thumbnail" == nftMetadata.thumbnail)
    // assert(Address(0x01cf0e2f2f715450) == nftMetadata.owner)
    // assert("A.01cf0e2f2f715450.ExampleNFT.NFT" == nftMetadata.type)
    assert("Creator Royalty" == nftMetadata.royalties[0].description)
    // assert(Address(0x01cf0e2f2f715450) == nftMetadata.royalties[0].receiver.address)
    assert(0.05 == nftMetadata.royalties[0].cut)
    assert("https://example-nft.onflow.org/".concat(id.toString()) == nftMetadata.externalURL)
    assert(nft.getID() == nftMetadata.serialNumber)
    assert(/public/cadenceExampleNFTCollection == nftMetadata.collectionPublicPath)
    assert(/storage/cadenceExampleNFTCollection == nftMetadata.collectionStoragePath)
    assert(/private/cadenceExampleNFTCollection == nftMetadata.collectionProviderPath)
    // assert("&A.01cf0e2f2f715450.ExampleNFT.Collection" == nftMetadata.collectionPublic)
    // assert("&A.01cf0e2f2f715450.ExampleNFT.Collection" == nftMetadata.collectionPublicLinkedType)
    // assert("&A.01cf0e2f2f715450.ExampleNFT.Collection" == nftMetadata.collectionProviderLinkedType)
    assert("The Example Collection" == nftMetadata.collectionName)
    assert("This collection is used as an example to help you develop your next Flow NFT." == nftMetadata.collectionDescription)
    assert("https://example-nft.onflow.org" == nftMetadata.collectionExternalURL)
    assert("https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg" == nftMetadata.collectionSquareImage)
    assert("https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg" == nftMetadata.collectionBannerImage)
    assert({"twitter": "https://twitter.com/flow_blockchain"} == nftMetadata.collectionSocials)
    assert("Example NFT Edition" == nftMetadata.edition.name)
    assert(nft.getID() == nftMetadata.edition.number)
    assert(nil == nftMetadata.edition.max)
    assert("Common" == nftMetadata.traits.traits[2]!.rarity!.description)
    assert(10.0 == nftMetadata.traits.traits[2]!.rarity!.score)
    assert(100.0 == nftMetadata.traits.traits[2]!.rarity!.max)
    assert(nil == nftMetadata.medias)
    assert(nil == nftMetadata.license)

    let coll <- nftCollectionView.createEmptyCollection()
    assert(0 == coll.getLength())
    destroy <- coll

    return true
}
