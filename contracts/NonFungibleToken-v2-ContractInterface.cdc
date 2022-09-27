import NonFungibleToken from "./NonFungibleToken-v2.cdc"
import MetadataViews from "./MetadataViews.cdc"

pub contract interface NonFungibleTokenInterface {

    /// Event that is emitted when a token is withdrawn,
    /// indicating the owner of the collection that it was withdrawn from.
    ///
    /// If the collection is not in an account's storage, `from` will be `nil`.
    ///
    pub event Withdraw(id: UInt64, from: Address?, type: Type)

    /// Event that emitted when a token is deposited to a collection.
    ///
    /// It indicates the owner of the collection that it was deposited to.
    ///
    pub event Deposit(id: UInt64, to: Address?, type: Type)

    /// Transfer
    ///
    /// The event that is emitted when tokens are transferred from one account to another
    pub event Transfer(id: UInt64, from: Address?, to: Address?, type: Type)

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
            // verify that each type, if present, is a collection type
            NonFungibleToken.verifyCollectionTypes(result): "One of the returned types is not a valid NFT collection type"
        }
    }

    /// tells what collection type should be used for the specified NFT type
    /// return `nil` if no collection type exists for the specified NFT type
    pub fun getCollectionTypeForNftType(nftType: Type): Type?

    /// resolve a type to its CollectionData so you know where to store it
    /// Returns `nil` if no collection type exists for the specified NFT type
    pub fun getCollectionData(nftType: Type): MetadataViews.NFTCollectionData?

    /// Returns the CollectionDisplay view for the NFT type that is specified 
    pub fun getCollectionDisplay(nftType: Type): MetadataViews.NFTCollectionDisplay?
}
 