import ExampleNFT from "ExampleNFT"
import MetadataViews from "MetadataViews"

pub fun main(address: Address, id: UInt64): Bool {
    let account = getAccount(address)

    let collection = account
        .getCapability(ExampleNFT.CollectionPublicPath)
        .borrow<&{ExampleNFT.ExampleNFTCollectionPublic}>()
        ?? panic("Could not borrow a reference to the collection")

    let nft = collection.borrowExampleNFT(id: id)!

    // Get the NFTLicense information for this NFT
    let nftLicense = MetadataViews.getNFTLicense(nft)!

    if nftLicense.equals(MetadataViews.nlpVoteMerch()) { return false }

    return nftLicense.equals(MetadataViews.nlpUtil())
}