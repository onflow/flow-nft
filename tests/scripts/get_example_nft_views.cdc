/// This script checks all the supported views from
/// the ExampleNFT contract. Used for testing only.

import ExampleNFT from "ExampleNFT"
import MetadataViews from "MetadataViews"

pub fun main(): Bool {
    let views = ExampleNFT.getViews()

    let expected = [
        Type<MetadataViews.NFTCollectionData>(),
        Type<MetadataViews.NFTCollectionDisplay>()
    ]
    assert(expected == views)

    return true
}
