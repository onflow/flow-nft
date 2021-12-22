import ExampleNFT from "../../contracts/ExampleNFT.cdc"
import Metadata from "../../contracts/Metadata.cdc"

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
        .getCapability(/public/NFTCollection)
        .borrow<&{ExampleNFT.ExampleNFTCollectionPublic}>()
        ?? panic("Could not borrow a reference to the collection")

    let nft = collection.borrowExampleNFT(id: id)!

    var r = NFTResult()

    // Get the basic display information for this NFT
    if let view = nft.resolveView(Type<Metadata.Display>()) {
        let display = view as! Metadata.Display

        r.name = display.name
        r.description = display.description
    }

    // Get the image thumbnail for this NFT (if it exists)
    if let view = nft.resolveView(Type<Metadata.Thumbnail>()) {
        let thumbnail = view as! Metadata.Thumbnail

        r.thumbnail = thumbnail.uri
    }

    // The owner is stored directly on the NFT object
    let owner: Address = nft.owner!.address!

    r.owner = owner

    // Inspect the type of this NFT to verify its origin
    let nftType = nft.getType()

    r.type = nftType.identifier
    // `r.type` is `A.f3fcd2c1a78f5eee.ExampleNFT.NFT`

    return r
}
