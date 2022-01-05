import ExampleNFT from "../../contracts/ExampleNFT.cdc"

pub struct NFTResult {
    pub(set) var name: String
    pub(set) var description: String
    pub(set) var thumbnail: String
    pub(set) var owner: Address
    pub(set) var type: String

    init() {
        self.name = ""
        self.description = ""
        self.thumbnail = ""
        self.owner = 0x0
        self.type = ""
    }
}

pub fun main(address: Address, id: UInt64): NFTResult {
    let account = getAccount(address)

    let collection = account
        .getCapability(ExampleNFT.CollectionPublicPath)
        .borrow<&{ExampleNFT.ExampleNFTCollectionPublic}>()
        ?? panic("Could not borrow a reference to the collection")

    let nft = collection.borrowExampleNFT(id: id)!

    var data = NFTResult()

    // Get the basic display information for this NFT
    if let view = nft.resolveView(Type<MetadataViews.Display>()) {
        let display = view as! MetadataViews.Display

        data.name = display.name
        data.description = display.description
    }

    // Get the image thumbnail for this NFT (if it exists)
    if let view = nft.resolveView(Type<MetadataViews.HTTPThumbnail>()) {
        let thumbnail = view as! MetadataViews.HTTPThumbnail

        data.thumbnail = thumbnail.uri
    }

    // The owner is stored directly on the NFT object
    let owner: Address = nft.owner!.address!

    data.owner = owner

    // Inspect the type of this NFT to verify its origin
    let nftType = nft.getType()

    data.type = nftType.identifier
    // `data.type` is `A.f3fcd2c1a78f5eee.ExampleNFT.NFT`

    return data
}
