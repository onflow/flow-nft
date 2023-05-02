import NonFungibleToken from "./NonFungibleToken-v2.cdc"

/// This interface specifies functions that a contract might want to implement
/// if it defines multiple NFT types and/or multiple collection types

pub contract interface MultipleNFT {

    /// Return the types that the contract defines
    pub fun getNFTTypes(): [Type] {
        post {
            result.length > 0: "Must indicate what non-fungible token types this contract defines"
        }
    }

    /// get a list of all the NFT collection types that the contract defines
    /// could include a post-condition that verifies that each Type is an NFT collection type
    pub fun getCollectionTypes(): [Type] {
        return []
    }

    /// tells what collection type should be used for the specified NFT type
    /// return `nil` if no collection type exists for the specified NFT type
    pub fun getCollectionTypeForNftType(nftType: Type): Type? {
        return nil
    }

    /// createEmptyCollection creates an empty Collection
    /// and returns it to the caller so that they can own NFTs
    pub fun createEmptyCollection(collectionType: Type): @{NonFungibleToken.Collection} {
        post {
            result.getIDs().length == 0: "The created collection must be empty!"
            result.getType() == collectionType: "The created collection is of the wrong type"
        }
    }
}