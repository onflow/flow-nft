import NonFungibleToken from "./NonFungibleToken-v2.cdc"

pub contract interface NonFungibleTokenInterface {

    /// Return the types that the contract defines
    pub fun getNFTTypes(): [Type] {
        post {
            result.length > 0: "Must indicate what non-fungible token types this contract defines"
        }
    }

    /// get a list of all the NFT collection types that the contract defines
    /// could include a post-condition that verifies that each Type is an NFT collection type
    pub fun getCollectionTypes(): [Type] {
        post {
            // verify that each type, if present, is a collection type?
        }
    }

    /// tells what collection type should be used for the specified NFT type
    /// return `nil` if no collection type exists for the specified NFT type
    pub fun getCollectionTypeForNftType(nftType: Type): Type?

    /// resolve a type to its CollectionData so you know where to store it
    /// Returns `nil` if no collection type exists for the specified NFT type
    pub fun getCollectionData(nftType: Type): MetadataViews.CollectionData?

    /// Returns the CollectionDisplay view for the NFT type that is specified 
    pub fun getCollectionDisplay(nftType: Type): MetadataViews.CollectionDisplay?
}