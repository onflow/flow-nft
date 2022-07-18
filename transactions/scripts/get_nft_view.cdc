import ExampleNFT from "../../contracts/ExampleNFT.cdc"
import MetadataViews from "../../contracts/MetadataViews.cdc"

pub struct NFTView {
    pub let id: UInt64
    pub let uuid: UInt64
    pub let name: String
    pub let description: String
    pub let thumbnail: String
    pub let royalties: [MetadataViews.Royalty]
    pub let externalURL: String
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
    pub let traits: MetadataViews.Traits

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

pub fun main(address: Address, id: UInt64): NFTView {
    let account = getAccount(address)

    let collection = account
        .getCapability(ExampleNFT.CollectionPublicPath)
        .borrow<&{MetadataViews.ResolverCollection}>()
        ?? panic("Could not borrow a reference to the collection")

    let viewResolver = collection.borrowViewResolver(id: id)!

    let nftView = MetadataViews.getNFTView(id: id, viewResolver : viewResolver)

    let collectionSocials: {String: String} = {}
    for key in nftView.collectionDisplay!.socials.keys {
        collectionSocials[key] = nftView.collectionDisplay!.socials[key]!.url
    }


    return NFTView(
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
}