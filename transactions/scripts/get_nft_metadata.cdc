import ExampleNFT from "../../contracts/ExampleNFT.cdc"
import MetadataViews from "../../contracts/MetadataViews.cdc"

pub struct NFT {
    pub let name: String
    pub let description: String
    pub let thumbnail: String
    pub let owner: Address
    pub let type: String
    pub let royalties: [MetadataViews.Royalty]
    pub let collectionName: String
    pub let collectionDescription: String
    pub let collectionSquareImage: String
    pub let collectionBannerImage: String

    init(
        name: String,
        description: String,
        thumbnail: String,
        owner: Address,
        nftType: String,
        royalties: [MetadataViews.Royalty],
        collectionName: String,
        collectionDescription: String,
        collectionSquareImage: String,
        collectionBannerImage: String
    ) {
        self.name = name
        self.description = description
        self.thumbnail = thumbnail
        self.owner = owner
        self.type = nftType
        self.royalties = royalties
        self.collectionName = collectionName
        self.collectionDescription = collectionDescription
        self.collectionSquareImage = collectionSquareImage
        self.collectionBannerImage = collectionBannerImage
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

    let collectionDisplay = nft.resolveView(Type<MetadataViews.NFTCollectionDisplay>())! as! MetadataViews.NFTCollectionDisplay
    
    let owner: Address = nft.owner!.address!
    let nftType = nft.getType()

    return NFT(
        name: display.name,
        description: display.description,
        thumbnail: display.thumbnail.uri(),
        owner: owner,
        nftType: nftType.identifier,
        royalties: royaltyView.getRoyalties(),
        collectionName: collectionDisplay.name,
        collectionDescription: collectionDisplay.description,
        collectionSquareImage: collectionDisplay.squareImage.file.uri(),
        collectionBannerImage: collectionDisplay.bannerImage.file.uri()
    )
}
