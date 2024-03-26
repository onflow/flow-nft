/// This script gets all the view-based metadata associated with the specified NFT
/// and returns it as a single struct

import "ExampleNFT"
import "MetadataViews"

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
    access(all) let collectionPublic: String
    access(all) let collectionPublicLinkedType: String
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
        collectionPublic: String,
        collectionPublicLinkedType: String,
        collectionName: String,
        collectionDescription: String,
        collectionExternalURL: String,
        collectionSquareImage: String,
        collectionBannerImage: String,
        collectionSocials: {String: String},
        edition: MetadataViews.Edition,
        traits: MetadataViews.Traits,
        medias:MetadataViews.Medias?,
        license:MetadataViews.License?
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
        self.collectionPublic = collectionPublic
        self.collectionPublicLinkedType = collectionPublicLinkedType
        self.collectionName = collectionName
        self.collectionDescription = collectionDescription
        self.collectionExternalURL = collectionExternalURL
        self.collectionSquareImage = collectionSquareImage
        self.collectionBannerImage = collectionBannerImage
        self.collectionSocials = collectionSocials
        self.edition = edition
        self.traits = traits
        self.medias=medias
        self.license=license
    }
}

access(all) fun main(address: Address, id: UInt64): NFT {
    let account = getAccount(address)

    let collectionData = ExampleNFT.resolveContractView(resourceType: nil, viewType: Type<MetadataViews.NFTCollectionData>()) as! MetadataViews.NFTCollectionData?
        ?? panic("ViewResolver does not resolve NFTCollectionData view")
    
    let collection = account.capabilities.borrow<&ExampleNFT.Collection>(
            collectionData.publicPath
        ) ?? panic("Could not borrow a reference to the collection")

    let nft = collection.borrowNFT(id)
        ?? panic("Could not borrow a reference to an NFT with the given ID")

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

    let medias=MetadataViews.getMedias(nft)
    let license=MetadataViews.getLicense(nft)

    return NFT(
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
        collectionPublic: nftCollectionView.publicCollection.identifier,
        collectionPublicLinkedType: nftCollectionView.publicLinkedType.identifier,
        collectionName: collectionDisplay.name,
        collectionDescription: collectionDisplay.description,
        collectionExternalURL: collectionDisplay.externalURL.url,
        collectionSquareImage: collectionDisplay.squareImage.file.uri(),
        collectionBannerImage: collectionDisplay.bannerImage.file.uri(),
        collectionSocials: collectionSocials,
        edition: nftEditionView.infoList[0],
        traits: traits,
        medias:medias,
        license:license
    )
}
