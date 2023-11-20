/// This script checks all the supported views from
/// the ExampleNFT contract. Used for testing only.

import "ExampleNFT"
import "MetadataViews"

pub fun main(): [Type] {
    return ExampleNFT.getViews()
}
