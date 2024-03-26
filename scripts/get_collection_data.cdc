import MetadataViews from "MetadataViews"
import ExampleNFT from "ExampleNFT"

access(all) fun main(): MetadataViews.NFTCollectionData? {
    return ExampleNFT.getCollectionData(nftType: Type<@ExampleNFT.NFT>()) as MetadataViews.NFTCollectionData?
}