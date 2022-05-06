import ExampleNFT from "../../contracts/ExampleNFT.cdc"
import MetadataViews from "../../contracts/MetadataViews.cdc"

pub struct NFT {
    pub let name: String
    pub let description: String
    pub let thumbnail: String
    pub let owner: Address
    pub let type: String
    pub let royalties: [MetadataViews.Royalty]
    pub let collectionPublicPath: PublicPath
    pub let collectionStoragePath: StoragePath
    pub let collectionProviderPath: PrivatePath
    pub let collectionPublic: String
    pub let collectionPublicLinkedType: String
    pub let collectionProviderLinkedType: String

    init(
        name: String,
        description: String,
        thumbnail: String,
        owner: Address,
        nftType: String,
        royalties: [MetadataViews.Royalty],
        collectionPublicPath: PublicPath,
        collectionStoragePath: StoragePath,
        collectionProviderPath: PrivatePath,
        collectionPublic: String,
        collectionPublicLinkedType: String,
        collectionProviderLinkedType: String
    ) {
        self.name = name
        self.description = description
        self.thumbnail = thumbnail
        self.owner = owner
        self.type = nftType
        self.royalties = royalties
        self.collectionPublicPath = collectionPublicPath
        self.collectionStoragePath = collectionStoragePath
        self.collectionProviderPath = collectionProviderPath
        self.collectionPublic = collectionPublic
        self.collectionPublicLinkedType = collectionPublicLinkedType
        self.collectionProviderLinkedType = collectionProviderLinkedType
    }
}

pub fun main(address: Address, id: UInt64): NFT {
    let account = getAccount(address)

    let collection = account
        .getCapability(ExampleNFT.CollectionPublicPath)
        .borrow<&{ExampleNFT.ExampleNFTCollectionPublic}>()
        ?? panic("Could not borrow a reference to the collection")

    let nft = collection.borrowExampleNFT(id: id)!

    // Get the basic display information for this NFT
    let view = nft.resolveView(Type<MetadataViews.Display>())!

    // Get the royalty information for the given NFT
    let expectedRoyaltyView = nft.resolveView(Type<MetadataViews.Royalties>())!

    let royaltyView = expectedRoyaltyView as! MetadataViews.Royalties

    let display = view as! MetadataViews.Display

    let nftCollectionView = nft.resolveView(Type<MetadataViews.NFTCollectionData>())! as! MetadataViews.NFTCollectionData
    
    let owner: Address = nft.owner!.address!
    let nftType = nft.getType()

    return NFT(
        name: display.name,
        description: display.description,
        thumbnail: display.thumbnail.uri(),
        owner: owner,
        nftType: nftType.identifier,
        royalties: royaltyView.getRoyalties(),
        collectionPublicPath: nftCollectionView.publicPath,
        collectionStoragePath: nftCollectionView.storagePath,
        collectionProviderPath: nftCollectionView.providerPath,
        collectionPublic: nftCollectionView.publicCollection.identifier,
        collectionPublicLinkedType: nftCollectionView.publicLinkedType.identifier,
        collectionProviderLinkedType: nftCollectionView.providerLinkedType.identifier
    )
}
